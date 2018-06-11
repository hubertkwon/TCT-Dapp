pragma solidity ^0.4.21;

interface testContract{
    function ownerChange(address _from, address _to, uint _number) public;
}

contract check{

    function plz(address contractAddr,address _from, address _to, uint _number) public {
        
        testContract t1 = testContract(contractAddr);
        
        t1.ownerChange(_from,_to,_number);
    }
}