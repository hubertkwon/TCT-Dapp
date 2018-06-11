pragma solidity ^0.4.21;

contract testContract {
    
    struct PersonInfo{
        string name;
        string phoneNumber;
        uint[] carList;
    }//사람정보

    struct CarInfo{
        string model;
        address owner;
    }//차량 초기 정보

    
    struct repairRecipt{
        address from;
        string repairInfo;
        bool isRepaired;
    }//수리 정보    


    //등록된 사람인지 확인
    mapping(address => bool) public isPerson;
    //등록된 차량인지 확인
    mapping(uint => bool) public isCar;


    //주소당 사람 정보 저장
    mapping(address => PersonInfo) public personDetail;
    //차량 정보 저장
    mapping(uint => CarInfo) public carDetail;
    
    //차량 수리 이력 카운트
    mapping(uint => uint) public repairCount;
    //차량 수리 이력
    mapping(uint => mapping(uint => repairRecipt)) repairList;
    
    //수리 정보 등록시 이벤트 등록
    event repairUpdate(address from, uint number, string data);
    //주인 변경 이벤트
    event changeOwner(address from, address to, uint number);
    //사람 등록 이벤트
    event personRegister(address _who, string _name, string _phoneNumber);
    //차량 등록 이벤트
    event carRegister(address _who, uint _number, string _model);

    function getCarOwner(uint _number)public view returns(address){
        return(carDetail[_number].owner);
    }

    //사람 등록
    function setPerson(string _name, string _phoneNumber) public{
        isPerson[msg.sender] = true;
        personDetail[msg.sender].name = _name;
        personDetail[msg.sender].phoneNumber = _phoneNumber;
        emit personRegister(msg.sender,_name,_phoneNumber);
    }

    /*
    //초기 사람 등록(mainAccount)
    function setPerson(address addr, string _name, string _phoneNumber)public {
        isPerson[addr] = true;
        personDetail[addr].name = _name;
        personDetail[addr].phoneNumber = _phoneNumber;
    }*/

    //초기 차량 등록
    function setCar(uint _number,string _model)public {
        require(!isCar[_number]);
        require(isPerson[msg.sender]);
        carDetail[_number].model = _model;
        carDetail[_number].owner = msg.sender;
        personDetail[msg.sender].carList.push(_number);
        isCar[_number] = true;
        emit carRegister(msg.sender,_number,_model);
    }

    /*
    //초기 차량 등록(mainAccount)
    function setCar(uint _number, string _model, address _owner) public{
        require(!isCar[_number]);
        require(isPerson[_owner]);
        carDetail[_number].model = _model;
        carDetail[_number].owner = _owner;
        personDetail[_owner].carList.push(_number);
        isCar[_number] = true;
    }
    */
    
    //수리이력 등록
    function setRepairInfo(uint _to,string _repairInfo,bool _isRepaired)public {
        require(isPerson[msg.sender]);
        require(isCar[_to]);

        uint count = repairCount[_to];
        repairList[_to][count] = repairRecipt(msg.sender,_repairInfo,_isRepaired);
        
        repairCount[_to]++;

        emit repairUpdate(msg.sender,_to,_repairInfo);
    }

    /*
    //수리이력 등록(mainAccount)
    function setRepairInfo(address _from,uint _to, string _repairInfo, bool _isRepaired) public {
        require(isPerson[_from]);
        require(isCar[_to]);

        uint count = repairCount[_to];
        repairList[_to][count] = repairRecipt(_from,_repairInfo,_isRepaired);
        
        repairCount[_to]++;

        emit repairUpdate(_from,_to,_repairInfo);
    }
    */
    
    function getRepairInfo(uint _number,uint _index) public view returns(address _from, string _repairInfo, bool _isRepaired){
        require(repairCount[_number] > _index);
        _from = repairList[_number][_index].from;
        _repairInfo = repairList[_number][_index].repairInfo;
        _isRepaired = repairList[_number][_index].isRepaired;
        return(_from,_repairInfo,_isRepaired);
    }
    
    function getMyCarList() public view returns(uint[]) {
        return(personDetail[msg.sender].carList);
    }

    function getPersonDetail(address _who) public view returns(string name, string phoneNumber, uint[] carList){
        return(personDetail[_who].name,personDetail[_who].phoneNumber,personDetail[_who].carList);
    }

    //주인 변경
    function ownerChange(address _to, uint _number) public returns(bool){
        require(carDetail[_number].owner == msg.sender);
        require(isPerson[_to]);
        carDetail[_number].owner = _to;
        emit changeOwner(msg.sender,_to,_number);
        return true;
    }
    
    //주인 변경(mainAccount)
    function ownerChange(address _from, address _to, uint _number) public returns(bool){
        require(carDetail[_number].owner == _from);
        require(isPerson[_to]);
        carDetail[_number].owner = _to;
        emit changeOwner(_from,_to,_number);
        return true;
    }
}