pragma solidity ^0.4.16;

interface CarInstant{
    function getRepairInfo(uint _number,uint _count) public view returns(address _from, string _repairInfo, bool _isRepaired);
}

contract check{
    CarInstant public carInstant;

    constructor (address carAddress) public {
        carInstant = CarInstant(carAddress);
    }
    
}
