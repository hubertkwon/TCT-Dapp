pragma solidity ^0.4.9;

 /* New ERC223 contract interface */
 
contract ERC223 {
    uint public totalSupply;
    function balanceOf(address who) public view returns (uint);
  
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function decimals() public view returns (uint8 _decimals);
    function totalSupply() public view returns (uint256 _supply);

    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes data) public returns (bool ok);
    function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);
  
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

 /*
 * Contract that is working with ERC223 tokens
 */
 
contract contractReceiver{
    function tokenFallback(address _from, uint _value) external;
}

contract FallbackTest{
    mapping (address => uint) public balanceOf;
    uint public count;

    function FallbackTest(uint _count) public {
        count = _count;
    }

    function tokenFallback(address _from, uint _value) public returns (bool result)
    { 
        balanceOf[_from] += _value;

        return true;
    }

}

