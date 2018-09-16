pragma solidity ^0.4.24;

//lib SafeMath
library SafeMath {

      /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
        return 0;
    }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
contract owned {
    address public owner;
    
    constructor() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    //조건을 설정해 놓고 나중에 재사용 하기 위한 용도인것 같음
    //여기서는 msg.sender == owner랑 같아야지만 사용할 수 있게 해놨음


    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    //Owner 변경하는 용도
}
contract Token{
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract TCTDapp is owned{
    using SafeMath for uint;

    //carData
    struct PersonInfo{
        string name;
        string phoneNumber;
    }//사람정보
    
    struct CarInfo{
        string model;
        address owner;
    }//차량 초기 정보
    
    struct repairRecipt{
        address from;
        string repairInfo;
        bool isRepaired;
    }//수리 정보

    struct Escrow{
        uint balance;               //balance
        
        uint number;                //Car Number
        uint price;                 //price
        
        address seller;             //판매자
        address buyer;              //구매자

        bool deposited;             //입금 여부
        bool buyerApprove;          //구매자 승인
        bool sellerApprove;         //판매자 승인

        uint start;                  //startTime;
        bool lived;                 //취소, 거래종료 등 -> true
    }//Escrow

    //등록된 사람인지 확인
    mapping(address => bool) public isPerson;
    //등록된 차량인지 확인
    mapping(uint => bool) public isCar;

    //주소당 사람 정보 저장
    mapping(address => PersonInfo) public personDetail;
    //차량 정보 저장
    mapping(uint => CarInfo) public carDetail;

    //차량 수리 이력 카운트
    mapping(uint => uint) public repairCount;
    //차량 수리 이력
    mapping(uint => mapping(uint => repairRecipt)) public repairList;
    //Escrow
    mapping(uint => Escrow) public escrows;

    //수리 정보 등록시 이벤트 등록
    event repairUpdate(address from, uint number, string data);
    //주인 변경 이벤트
    event changeOwner(address from, address to, uint number);
    //사람 등록 이벤트
    event personRegister(address _who, string _name, string _phoneNumber);
    //차량 등록 이벤트
    event carRegister(address _who, uint _number, string _model);
    //입금
    event Deposit(uint _orderNumber, address  _buyer);                             
    //거래 영수증
    event Receipt(uint _orderNumber, address _seller,address _buyer,uint number ,uint price);
    //취소          
    event Cancel(uint _orderNumber, address _seller, address _buyer);
    //TimeOut 
    event TimeOut(uint _orderNumber,address _seller,address _buyer, uint _time);      

    address tokenAddress;
    Token tokenInstance;
    uint orderCount;
    Escrow escrow;
    uint public feeAmount;
    

    modifier afterDeadline(uint _orderNumber) {
        if(now >= escrows[_orderNumber].start + 30 days) 
            escrows[_orderNumber].lived = false;
        _;
    }

    modifier isLived(uint _orderNumber){
        require(escrows[_orderNumber].lived);
        _;
    }

    constructor(address _tokenAddress) public{
        tokenAddress = _tokenAddress;
        tokenInstance = Token(_tokenAddress);
        orderCount = 0;
    }


    function changeCurrent(address _tokenAddress) onlyOwner public{
        tokenAddress = _tokenAddress;
        tokenInstance = Token(_tokenAddress);
    }

    function getCarOwner(uint _number)public view returns(address){
        return(carDetail[_number].owner);
    }

    function getRepairInfo(uint _number,uint _index) public view returns(address _from, string _repairInfo, bool _isRepaired){
        require(repairCount[_number] > _index);
        _from = repairList[_number][_index].from;
        _repairInfo = repairList[_number][_index].repairInfo;
        _isRepaired = repairList[_number][_index].isRepaired;
        return(_from,_repairInfo,_isRepaired);
    }

    function getBalance(uint _orderNumber) public view returns(uint){
        return(escrows[_orderNumber].balance);
    }

    function nowCurrent() public view returns(address){
        return(tokenAddress);
    }

    //사람 등록
    function setPerson(string _name, string _phoneNumber) public{
        require(!isPerson[msg.sender]);
        isPerson[msg.sender] = true;
        personDetail[msg.sender].name = _name;
        personDetail[msg.sender].phoneNumber = _phoneNumber;
        emit personRegister(msg.sender,_name,_phoneNumber);
    }

    //초기 차량 등록
    function setCar(uint _number,string _model)public {
        require(!isCar[_number]);
        require(isPerson[msg.sender]);
        carDetail[_number].model = _model;
        carDetail[_number].owner = msg.sender;
        isCar[_number] = true;
        emit carRegister(msg.sender,_number,_model);
    }

    //수리이력 등록
    function setRepairInfo(uint _to,string _repairInfo,bool _isRepaired)public {
        require(isPerson[msg.sender]);
        require(isCar[_to]);

        uint count = repairCount[_to];
        repairList[_to][count] = repairRecipt(msg.sender,_repairInfo,_isRepaired);
        
        repairCount[_to]++;

        emit repairUpdate(msg.sender,_to,_repairInfo);
    }

    //Escrow 생성
    function create(uint _number, uint _price, address _buyer) public returns(uint){
        require(msg.sender == getCarOwner(_number));
        orderCount++;
        escrows[orderCount] = Escrow(0, _number, _price, msg.sender, _buyer, false,false,false,now,true);

        return orderCount;
    }

    function deposit(uint _orderNumber) public afterDeadline(_orderNumber) isLived(_orderNumber){
        require(tokenInstance.balanceOf(msg.sender) >= escrows[_orderNumber].price);
        require(address(escrows[_orderNumber].buyer) == msg.sender);
        tokenInstance.transferFrom(msg.sender,address(this),escrows[_orderNumber].price);
        escrows[_orderNumber].balance = escrows[_orderNumber].balance.add(escrows[_orderNumber].price);
        escrows[_orderNumber].deposited = true;
        emit Deposit(_orderNumber,msg.sender);
    }

    function Approve(uint _orderNumber) public isLived(_orderNumber){
        require(msg.sender == escrows[_orderNumber].seller || msg.sender == escrows[_orderNumber].buyer);

        if(msg.sender == escrows[_orderNumber].seller && escrows[_orderNumber].deposited)
            escrows[_orderNumber].sellerApprove = true;
        
        if(msg.sender == escrows[_orderNumber].buyer)
            escrows[_orderNumber].buyerApprove = true;

        if(escrows[_orderNumber].sellerApprove && escrows[_orderNumber].buyerApprove){
            //Pay and Exchange;
            if(!payAndExchange(_orderNumber)){
                revert();
            }
            //Transfer Token
            emit Receipt(_orderNumber,escrows[_orderNumber].seller,escrows[_orderNumber].buyer,escrows[_orderNumber].number,escrows[_orderNumber].price);
        }
        else if(escrows[_orderNumber].buyerApprove && !escrows[_orderNumber].sellerApprove && now > escrows[_orderNumber].start + 30 days){
            tokenInstance.transfer(escrows[_orderNumber].buyer,escrows[_orderNumber].balance);
            emit TimeOut(_orderNumber,escrows[_orderNumber].seller,escrows[_orderNumber].buyer,now);
            emit Cancel(_orderNumber,escrows[_orderNumber].seller,escrows[_orderNumber].buyer);
            escrows[_orderNumber].lived = false;
        }
    }
    
    function ownerChange(address _from, address _to, uint _number) internal returns(bool){
        require(carDetail[_number].owner == _from);
        require(isPerson[_to]);
        carDetail[_number].owner = _to;
        emit changeOwner(_from,_to,_number);
        return true;
    }

    function payAndExchange(uint _orderNumber) internal returns (bool){
        uint fees;
        fees = escrows[_orderNumber].balance.div(100);
        feeAmount = feeAmount.add(fees);
        escrows[_orderNumber].balance = escrows[_orderNumber].balance.sub(fees);
        if(!tokenInstance.transfer(escrows[_orderNumber].seller,escrows[_orderNumber].balance))
            revert();
        ownerChange(escrows[_orderNumber].seller,escrows[_orderNumber].buyer,escrows[_orderNumber].number);
        escrows[_orderNumber].balance = 0;
        escrows[_orderNumber].lived = false;   //거래 종료
        return true;
    }

    function cancel(uint _orderNumber) public isLived(_orderNumber){
        if(escrows[_orderNumber].seller == msg.sender){
            escrows[_orderNumber].sellerApprove = false;
        }
        else if(msg.sender == escrows[_orderNumber].buyer){
            escrows[_orderNumber].buyerApprove = false;
        }
        if(!escrows[_orderNumber].sellerApprove && !escrows[_orderNumber].buyerApprove){
            if(escrows[_orderNumber].deposited){
                if(!tokenInstance.transfer(escrows[_orderNumber].buyer,escrows[_orderNumber].balance)) revert();
            }
            emit Cancel(_orderNumber,escrows[_orderNumber].seller,escrows[_orderNumber].buyer);
            escrows[_orderNumber].lived = false;
        }
    }
    
    function withdraw(address addr,uint _value) onlyOwner public{
        if(!tokenInstance.transfer(addr,_value)) revert();
    }

}