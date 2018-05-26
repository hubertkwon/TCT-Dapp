pragma solidity ^0.4.16;

contract test{
    struct SimpleData{
        string name;
        uint256 data;
        
    }
    struct personInfo{
        string name;
        string phoneNumber;
        uint[] carlist;
    }

    struct carInfo{
        string model;
        address owner;
        string[] repairList;
    }


    mapping(address => bool) public person;
    //등록된 사람인지 확인
    mapping(uint => bool) public car;
    //등록된 차량인지 확인

    mapping(address => personInfo) public personDetail;
    //사람의 정보 저장
    mapping(uint => carInfo) public carDetail;
    //차량과 관련된 정보 저장
  

    event repairUpdate(address from, uint number, string data);
    
  

    function setPerson(string _name, string _phoneNumber) public{
        person[msg.sender] = true;
        personDetail[msg.sender].name = _name;
        personDetail[msg.sender].phoneNumber = _phoneNumber;
    }


    function setCar(uint _number, string _model, address _owner) public{
        require(!car[_number]);
        require(person[_owner]);
        carDetail[_number].model = _model;
        carDetail[_number].owner = _owner;
        car[_number] = true;
        personDetail[_owner].carlist.push(_number);
    }

    function repairInfo(uint _number, string _data) public{
        require(person[msg.sender]);
        require(car[_number]);
        carDetail[_number].repairList.push(_data);
        emit repairUpdate(msg.sender,_number,_data);
    }


}