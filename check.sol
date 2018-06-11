pragma solidity ^0.4.16;

contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) public returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}


contract Check{

    address tokenAddress = 0x23c9A9fc2FF739C5430aaba481166aa8b9152c5c;
    mapping(address => uint256) public tokenBalance;
    event Deposit(address token, address user, uint256 amount, uint256 balance);

    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
    
    function depositToken(address token, uint256 amount) {
        tokenBalance[msg.sender] = safeAdd(tokenBalance[msg.sender], amount);
        if (!Token(token).transferFrom(msg.sender, this, amount)) revert();
        Deposit(token, msg.sender, amount, tokenBalance[msg.sender]);
    }

    function deposit() payable {
        tokenBalance[msg.sender] = safeAdd(tokenBalance[msg.sender], msg.value);
        Deposit(address(0), msg.sender, msg.value, tokenBalance[msg.sender]);
  }
    function balanceOf(address user) constant returns (uint256) {
        return tokenBalance[user];
    }
}
