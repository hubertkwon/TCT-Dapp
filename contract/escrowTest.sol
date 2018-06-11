pragma solidity ^0.4.16;



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

    function owned() public {
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


interface CarInstant{
    function getCarOwner(uint _number) external view returns(address);
    function getRepairInfo(uint _number,uint _count) external view returns(address _from, string _repairInfo, bool _isRepaired);
    function ownerChange(address _from, address _to, uint _number) external returns(bool success);
}

contract CarEscrow is owned{
    using SafeMath for uint256;
    address tokenAddress;          //current
    address carDataAddress;
    struct Escrow{
        uint balance;       //balance
        
        uint number;        //Car Number
        uint price;         //price
        
        address seller;     //판매자
        address buyer;      //구매자

        bool deposited;      //입금 여부
        bool buyerApprove;   //구매자 승인
        bool sellerApprove;  //판매자 승인
    }

    mapping(address => address) public tradingPartner;
    mapping(address => Escrow) public escrows;
    mapping(address => uint) private start;

    event Deposit(address indexed _seller, address indexed _buyer, uint tokens);    //입금
    event Receipt(address _seller,address _buyer,uint number ,uint price);          //거래 성공
    event Cancel(address _seller, address _buyer);
    event TimeOut(address _seller,address _buyer, uint _time);
    Escrow escrow;
    ERC20 token;
    CarInstant carInstant;


    //생성자 Test 용도
    function CarEscrow () public {
        tokenAddress = 0x94aC33dDC4587492DDb1D30a0D8F36cf9A4ea46C;
        carDataAddress = 0x0936A246D4587559379473bb7D198E3337175bDf;
        token = ERC20(tokenAddress);
        carInstant = CarInstant(carDataAddress);
        owner = msg.sender;
    }

    //생성자
/*
    function CarEscrow(address _tokenAddress, address _carDataAddress){
        tokenAddress = _tokenAddress;
        carDataAddress = _carDataAddress;
        token = ERC20(tokenAddress);
        carInstant = CarInstant(carDataAddress);
        owner = msg.sender;
    }
*/
    modifier afterDeadline(address _seller) { if(now >= start[_seller] + 30 days) _; }


    //Escrow 생성
    function create(uint _number, uint _price, address _buyer) public{
        require(msg.sender == getCarOwner(_number));
        
        escrows[msg.sender] = Escrow(0, _number, _price, msg.sender, _buyer, false,false,false);
        start[msg.sender] = now;
        tradingPartner[msg.sender] = _buyer;
    }

    function getCarOwner(uint _number)public view returns (address){
        return(carInstant.getCarOwner(_number));
    }
    

    function Approve(address _seller) public{
        escrow = escrows[_seller];

        if(msg.sender == escrow.seller && escrow.deposited)
            escrow.sellerApprove = true;
        else if(msg.sender == escrow.buyer)
            escrow.buyerApprove = true;
        
        if(escrow.sellerApprove && escrow.buyerApprove){
            //Pay and Exchange;
            if(!payAndExchange(_seller)){
                revert();
            }
            //Transfer Token
            emit Receipt(escrow.seller,escrow.buyer,escrow.number,escrow.price);
        }
        else if(escrow.buyerApprove && !escrow.sellerApprove && now > start[_seller] + 30 days){
            token.transfer(escrow.buyer,escrow.balance);
            emit TimeOut(escrow.seller,escrow.buyer,now);
            delete escrows[_seller];
        }
    }

    function payAndExchange(address _seller) internal returns (bool){
        escrow = escrows[_seller];
        
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
        return true;
    }

    function cancel(address _seller) public{
        escrow = escrows[_seller];

        if(msg.sender == escrow.seller){
            escrow.sellerApprove = false;
        }
        else if(msg.sender == escrow.buyer){
            escrow.buyerApprove = false;
        }

        if(!escrow.sellerApprove && !escrow.buyerApprove){
            if(escrow.deposited){
                if(!token.transferFrom(this,msg.sender,escrow.balance)) revert();
            }
            emit Cancel(escrow.seller,escrow.buyer);
            delete escrows[_seller];
        }
    }
    function getBalance(address _address) public view returns(uint){
        return(escrows[_address].balance);
    }

    function deposit(address _seller, uint _value) public afterDeadline(_seller){
        escrow = escrows[_seller];
        require(msg.sender == escrow.buyer);
        if(!token.transferFrom(msg.sender,this,_value)) revert();
        escrow.balance = escrow.balance.add(_value);
        if(escrow.balance >= escrow.price){
            escrow.deposited = true;
        }
        emit Deposit(_seller,msg.sender,_value);
    }

    function fee(address _seller) internal{
        
    }

    function withdraw() public onlyOwner{

    }
}