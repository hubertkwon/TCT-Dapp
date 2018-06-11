pragma solidity ^0.4.9;
 
 /* New ERC23 contract interface */
 
 contract contractReceiver{
     function tokenFallback(address, uint, bytes) public returns (bool);
 }

contract ERC23 {
  uint public totalSupply;
  function balanceOf(address who) constant public returns (uint);
  
  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
}


 /*
 * ERC23 token by Dexaran
 *
 * https://github.com/Dexaran/ERC23-tokens
 */
 
contract ERC23Asset is ERC23 {

  mapping(address => uint) public balances;
  mapping (address => mapping (address => uint)) public allowed;
  

    string public name = "TEST_Coin2.0";
    uint8  public decimals = 0;
    string public symbol = "Asset_2";
    uint public totalSupply=10000;
    address public owner;
  
  function ERC23Asset() public
  {
      owner=msg.sender;
      balances[msg.sender]=10000;
  }

  //function that is called when a user or another contract wants to transfer funds
  function transfer(address _to, uint _value, bytes _data) returns (bool success) {
    //filtering if the target is a contract with bytecode inside it
    if(isContract(_to)) {
        transferToContract(_to, _value, _data);
    }
    else {
        transferToAddress(_to, _value, _data);
    }
    return true;
  }
  
  function transfer(address _to, uint _value) returns (bool success) {
      
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes emptyData;
    if(isContract(_to)) {
        transferToContract(_to, _value, emptyData);
    }
    else {
        transferToAddress(_to, _value, emptyData);
    }
    return true;
  }

  //function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
  //function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    contractReceiver reciever = contractReceiver(_to);
    reciever.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
      uint length;
      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        if(length>0) {
            return true;
        }
        else {
            return false;
        }
    }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];
    
    if(_value > _allowance) {
        throw;
    }

    balances[_to] += _value;
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
} 