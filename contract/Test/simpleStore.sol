pragma solidity ^0.4.16;

contract simpleStore{

    struct SimpleData{
        string name;
        uint256 data;
    }


    mapping(address => mapping(uint256 => SimpleData)) public dataBlock;
    mapping(address => uint256) public count;
    SimpleData s1;

    function insertData(string _name, uint256 _data) public{
        uint256 nowCount = count[msg.sender];
        s1 = SimpleData(_name,_data);
        
        dataBlock[msg.sender][nowCount] = s1;
    }

    function getData() public returns (string name, uint256 data){
        uint256 nowCount = count[msg.sender];
        s1 = dataBlock[msg.sender][nowCount];
        
        return(s1.name, s1.data);
    }

}