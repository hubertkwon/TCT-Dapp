pragma solidity ^0.4.21;

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
    
    struct CarInfo{
        address owner;
        string model;
    }//차량 초기 정보
    
    struct repairRecipt{
        address from;
        string repairInfo;
        bool isRepaired;
    }//수리 정보

    struct Escrow{
        uint balance;               //balance
        
        string _carNumber;                //Car Number
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
    mapping(address => string) public personName;
    //등록된 차량인지 확인
    mapping(bytes32 => bool) isCar;
    //차량 정보 저장
    mapping(bytes32 => CarInfo) carDetail;
    //차량 수리 이력 카운트
    mapping(bytes32 => uint) repairCount;
    //차량 수리 이력
    mapping(bytes32 => mapping(uint => repairRecipt)) repairList;
    //Escrow
    mapping(uint => Escrow) public escrows;

    //수리 정보 등록시 이벤트 등록
    event repairUpdate(address from, string _carNumber, string data);
    //주인 변경 이벤트
    event changeOwner(address from, address to, string _carNumber);
    //사람 등록 이벤트
    event personRegister(address _who);
    //차량 등록 이벤트
    event carRegister(address _who, string _carNumber, string _model);
    //입금
    event Deposit(uint _orderNumber, address  _buyer);                             
    //거래 영수증
    event Receipt(uint _orderNumber, address _seller,address _buyer,string _carNumber ,uint price);
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
//getter
    function getIsCar(string _carNumber) public view returns(bool){
        bytes32 carNumber = stringToBytes32(_carNumber);
        return(isCar[carNumber]);
    }

    function getCarOwner(string _carNumber)public view returns(address){
        bytes32 carNumber = stringToBytes32(_carNumber);
        return(carDetail[carNumber].owner);
    }

    function getCardetail(string _carNumber) public view returns(address,string){
        bytes32 carNumber = stringToBytes32(_carNumber);
        return(carDetail[carNumber].owner,carDetail[carNumber].model);
    }

    function getRepairCount(string _carNumber) public view returns(uint){
        bytes32 carNumber = stringToBytes32(_carNumber);
        return(repairCount[carNumber]);
    }

    function getRepairInfo(string _carNumber,uint _index) public view returns(address _from, string _repairInfo, bool _isRepaired){
        require(bytes(_carNumber).length <= 32);
        bytes32 carNumber = stringToBytes32(_carNumber);
        require(repairCount[carNumber] > _index);
        _from = repairList[carNumber][_index].from;
        _repairInfo = repairList[carNumber][_index].repairInfo;
        _isRepaired = repairList[carNumber][_index].isRepaired;
        return(_from,_repairInfo,_isRepaired);
    }
//end getter

    function nowCurrent() public view returns(address){
        return(tokenAddress);
    }

    //사람 등록
    function setPerson(string name) public returns(bool){
        require(!isPerson[msg.sender]);
        isPerson[msg.sender] = true;
        personName[msg.sender] = name;
        emit personRegister(msg.sender);
        return true;
    }

    //초기 차량 등록
    function setCar(string _carNumber,string _model)public {
        require(bytes(_carNumber).length <= 32);
        bytes32 carNumber = stringToBytes32(_carNumber);
        require(!isCar[carNumber]);
        require(isPerson[msg.sender]);
        carDetail[carNumber].model = _model;
        carDetail[carNumber].owner = msg.sender;
        isCar[carNumber] = true;
        emit carRegister(msg.sender,_carNumber,_model);
    }

    //수리이력 등록
    function setRepairInfo(string _carNumber,string _repairInfo,bool _isRepaired)public {
        require(isPerson[msg.sender]);
        require(bytes(_carNumber).length <= 32);
        bytes32 carNumber = stringToBytes32(_carNumber);
        require(isCar[carNumber]);

        uint count = repairCount[carNumber];
        repairList[carNumber][count] = repairRecipt(msg.sender,_repairInfo,_isRepaired);
        
        repairCount[carNumber]++;

        emit repairUpdate(msg.sender,_carNumber,_repairInfo);
    }

    //Escrow 생성
    function escrowCreate(string _carNumber, uint _price, address _buyer) public returns(uint){
        require(msg.sender == getCarOwner(_carNumber));
        orderCount++;
        escrows[orderCount] = Escrow(0, _carNumber, _price, msg.sender, _buyer, false,false,false,now,true);

        return orderCount;
    }

    function deposit(uint _orderNumber) public afterDeadline(_orderNumber) isLived(_orderNumber){
        require(tokenInstance.balanceOf(msg.sender) >= escrows[_orderNumber].price);
        require(address(escrows[_orderNumber].buyer) == msg.sender);
        require(!escrows[_orderNumber].deposited);
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
            emit Receipt(_orderNumber,escrows[_orderNumber].seller,escrows[_orderNumber].buyer,escrows[_orderNumber]._carNumber,escrows[_orderNumber].price);
        }
        else if(escrows[_orderNumber].buyerApprove && !escrows[_orderNumber].sellerApprove && now > escrows[_orderNumber].start + 30 days){
            tokenInstance.transfer(escrows[_orderNumber].buyer,escrows[_orderNumber].balance);
            emit TimeOut(_orderNumber,escrows[_orderNumber].seller,escrows[_orderNumber].buyer,now);
            emit Cancel(_orderNumber,escrows[_orderNumber].seller,escrows[_orderNumber].buyer);
            escrows[_orderNumber].lived = false;
        }
    }
    
    function ownerChange(address _from, address _to, string _carNumber) internal returns(bool){
        require(bytes(_carNumber).length <= 32);
        bytes32 carNumber = stringToBytes32(_carNumber);
        require(carDetail[carNumber].owner == _from);
        require(isPerson[_to]);
        carDetail[carNumber].owner = _to;
        emit changeOwner(_from,_to,_carNumber);
        return true;
    }

    function payAndExchange(uint _orderNumber) internal returns (bool){
        uint fees;
        fees = escrows[_orderNumber].balance.div(100);
        feeAmount = feeAmount.add(fees);
        escrows[_orderNumber].balance = escrows[_orderNumber].balance.sub(fees);
        if(!tokenInstance.transfer(escrows[_orderNumber].seller,escrows[_orderNumber].balance))
            revert();
        ownerChange(escrows[_orderNumber].seller,escrows[_orderNumber].buyer,escrows[_orderNumber]._carNumber);
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
    
    //Fees withdraw
    function withdraw(address addr,uint _value) onlyOwner public{
        if(!tokenInstance.transfer(addr,_value)) revert();
    }   

    //string to Bytes32
    function stringToBytes32(string memory source) pure internal returns(bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

}