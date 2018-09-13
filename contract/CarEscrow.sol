pragma solidity ^0.4.23;
//Escrow 거래 기능 컨트랙트

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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
    constructor() public {
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
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
interface CarData{
    function getCarOwner(uint _number) external view returns(address);
    function getRepairInfo(uint _number,uint _count) external view returns(address _from, string _repairInfo, bool _isRepaired);
    function ownerChange(address _from, address _to, uint _number) external returns(bool success);
}

contract CarEscrow{
    using SafeMath for uint256;     //SafeMath
    address tokenAddress;           //current
    address carDataAddress;         //Car Data Address
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
    }

    mapping(uint => Escrow) public escrows;

    event Deposit(uint _orderNumber, address  _buyer, uint tokens);      //입금
    event Receipt(uint _orderNumber, address _seller,address _buyer,uint number ,uint price);          //거래 영수증
    event Cancel(uint _orderNumber, address _seller, address _buyer);                  //취소
    event TimeOut(uint _orderNumber,address _seller,address _buyer, uint _time);      //TimeOut

    Escrow escrow;
    ERC20 token;
    CarData carInstant;
    uint orderCount;
    uint balance;

    //생성자 Test 용도
    constructor() public {
        tokenAddress = 0x90AE6774df0454F41F6E933A5c6E6feEFF07E29F;
        carDataAddress = 0x1E27FBc85b562905B0Bba710f37a39e5941B8f72;
        token = ERC20(tokenAddress);
        carInstant = CarData(carDataAddress);
        orderCount = 0;
    }

    //생성자
/*
    function CarEscrow(address _tokenAddress, address _carDataAddress){
        tokenAddress = _tokenAddress;
        carDataAddress = _carDataAddress;
        token = ERC20(tokenAddress);
        carInstant = CarInstant(carDataAddress);
        owner = msg.sender;
        orderCount = 0;
    }
*/
    modifier afterDeadline(uint _orderNumber) {
        if(now >= escrows[_orderNumber].start + 30 days) 
            escrows[_orderNumber].lived = false;
        _;
    }

    modifier isLived(uint _orderNumber){
        require(escrows[_orderNumber].lived);
        _;
    }

    //Escrow 생성
    function create(uint _number, uint _price, address _buyer) public returns(uint){
        require(msg.sender == getCarOwner(_number));
        
        orderCount++;
        escrows[orderCount] = Escrow(0, _number, _price, msg.sender, _buyer, false,false,false,now,true);

        return orderCount;
    }

    function getCarOwner(uint _number)public view returns (address){
        return(carInstant.getCarOwner(_number));
    }
    

    function Approve(uint _orderNumber) public isLived(_orderNumber){
        escrow = escrows[_orderNumber];

        require(msg.sender == escrow.seller || msg.sender == escrow.buyer);
        if(msg.sender == escrow.seller && escrow.deposited)
            escrows[_orderNumber].sellerApprove = true;
        else if(msg.sender == escrow.buyer)
            escrows[_orderNumber].buyerApprove = true;

        if(escrow.sellerApprove && escrow.buyerApprove){
            //Pay and Exchange;
            if(!payAndExchange(_orderNumber)){
                revert();
            }
            //Transfer Token
            emit Receipt(_orderNumber,escrow.seller,escrow.buyer,escrow.number,escrow.price);
        }
        else if(escrow.buyerApprove && !escrow.sellerApprove && now > escrow.start + 30 days){
            token.transfer(escrow.buyer,escrow.balance);
            emit TimeOut(_orderNumber,escrow.seller,escrow.buyer,now);
            emit Cancel(_orderNumber,escrow.seller,escrow.buyer);
            escrows[_orderNumber].lived = false;
        }
    }

    function payAndExchange(uint _orderNumber) internal returns (bool){
        escrow = escrows[_orderNumber];
        
        if(!carInstant.ownerChange(escrow.seller,escrow.buyer,escrow.number))
            revert();
        
        if(!token.transferFrom(this,escrow.seller,escrow.price))
            revert();
        escrow.balance.sub(escrow.price);

        if(escrow.balance > 0){
            if(!token.transferFrom(this,escrow.buyer,escrow.balance))
                revert();
            escrow.balance.sub(escrow.balance);
        }

        escrows[_orderNumber].lived = false;   //거래 종료
        return true;
    }

    function cancel(uint _orderNumber) public isLived(_orderNumber){
        escrow = escrows[_orderNumber];

        if(msg.sender == escrow.seller){
            escrows[_orderNumber].sellerApprove = false;
        }
        else if(msg.sender == escrow.buyer){
            escrows[_orderNumber].buyerApprove = false;
        }

        if(!escrow.sellerApprove && !escrow.buyerApprove){
            if(escrow.deposited){
                if(!token.transferFrom(this,msg.sender,escrow.balance)) revert();
            }
            emit Cancel(_orderNumber,escrow.seller,escrow.buyer);
            escrows[_orderNumber].lived = false;
        }
    }

    function getBalance(uint _orderNumber) public view returns(uint){
        return(escrows[_orderNumber].balance);
    }

    function deposit(uint _orderNumber, uint _value) public afterDeadline(_orderNumber) isLived(_orderNumber){
        escrow = escrows[_orderNumber];
        require(msg.sender == escrow.buyer);
        if(!token.transferFrom(msg.sender,this,_value)) {revert();}
        escrows[_orderNumber].balance = escrows[_orderNumber].balance.add(_value);
        if(escrow.balance >= escrow.price){
            escrows[_orderNumber].deposited = true;
        }
        emit Deposit(_orderNumber,msg.sender,_value);
    }

/*
    function fee() internal{
        this.balance;
    }

    function withdraw() public onlyOwner{

    }
*/

}