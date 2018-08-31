pragma solidity ^0.4.16;

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
