pragma solidity^0.5.5;

contract StudentContract{
    
    address studentAddress;
    address universityAddress;
    University university;
    
    constructor(address _studentAddress, address _universityAddress) public{
        studentAddress = _studentAddress;
        universityAddress = _universityAddress;
        university = University(_universityAddress);
    }
    
    modifier restricted(){
        require(msg.sender == studentAddress);
        _;
    }
    
    function getStudentDetails() public view restricted  returns
    (string memory,string memory,string memory,address, bytes32[] memory) {
        return university.getStudentDetails(studentAddress);
    }
    
    function getRecordDetails(bytes32 _recordID) public view restricted returns
    (address, address, string memory, string memory, string memory, string memory){
        return university.getRecordDetails(_recordID);
    }
}


contract University {
    address private universityAddress;
    mapping (address => Student) private studentMappings;
    mapping (address => bool) private isStudent;
    address[] private listOfStudents;
    mapping(address => address) private studentContracts;
    mapping(bytes32 => Record) private recordMappings;
    mapping(bytes32 => bool) private isRecord;
    
    constructor() public{
        universityAddress = msg.sender;
    }
    struct Record {
        address issuerAddress;
        address holderAddress;
        string dateOfIssue;
        string title;
        string studentFullName;
        string ipfsHash;
    }
    
    struct Student {
        string fullName;
        string dateOfBirth;
        string studentID;
        bytes32[] records;
        uint recordCount;
    }
    //Modifier to require contract creator only.
    modifier restricted() { 
        require(msg.sender == universityAddress); 
        _;
    }
    
    //Creates a record and assigns the details to a corressponding student
    //and add it to their personal record array. Record is also added to
    //a record array of all created records. 
    function addRecord(address _holderAddress, string memory _title, string memory _dateOfIssue,
    string memory _ipfsHash) public restricted returns (bool){
        if(studentExists(_holderAddress) == false){
            return false;
        }
        
        bytes32 randomHash = random(_holderAddress, _title, _dateOfIssue, _ipfsHash);
        if(recordExists(randomHash) == true){
            return false;
        }
        Record storage r = recordMappings[randomHash];
        r.issuerAddress = msg.sender;
        r.holderAddress = _holderAddress;
        r.title = _title;
        r.dateOfIssue = _dateOfIssue;
        r.studentFullName = getStudentName(_holderAddress);
        r.ipfsHash = _ipfsHash;
        addRecordToStudent(randomHash, _holderAddress);
        isRecord[randomHash] = true;
        return true;
    }
    
    function addRecordToStudent(bytes32 _recordID ,address _studentAddress) private {
        Student storage s = studentMappings[_studentAddress];
        s.records.push(_recordID) -1;
        s.recordCount++;
    }
    
    
    function deleteRecord(address _studentAddress, bytes32 _recordID) public restricted returns (bool){
        if(studentExists(_studentAddress) == false){
            return false;
        }
        Student storage s = studentMappings[_studentAddress];
        if(s.records.length == 0){
            return false;
        
        }
        else{
            uint index = 0;
        
            for(uint i = 0; i<= s.records.length; i++){
                if( compareBytes32(_recordID, s.records[index]) == true ){
                    s.records[index] = s.records[s.records.length -1];
                    delete s.records[s.records.length -1];
                    s.records.length --;
                    s.recordCount--;
                    delete(recordMappings[_recordID]);
                    isRecord[_recordID] = false;
                    return true;
                }
                else{
                    index++;
                }
            }
            return false;
            }
    }
    
    function addStudent(address _studentAddress, string memory _fullName, string memory _dateOfBirth, 
    string memory _studentID) public restricted  returns (bool){
        if(studentExists(_studentAddress) == true){
            return false;
        }
        Student storage s = studentMappings[_studentAddress];
        isStudent[_studentAddress] = true;

        s.fullName = _fullName;
        s.dateOfBirth = _dateOfBirth;
        s.studentID = _studentID;
        s.recordCount = 0;
        
        studentContracts[_studentAddress] = createStudentContract(_studentAddress);
        listOfStudents.push(_studentAddress) -1;
        isStudent[_studentAddress] = true;
        return true;
    }
    
    function createStudentContract(address _studentAddress) private restricted returns (address){
        return address(new StudentContract(_studentAddress, address(this)));
    }
    
    function getStudents() view public returns(address[] memory) {
        return listOfStudents;
    }
    
    function getStudentContract(address _studentAddress) public view restricted returns(address){
        return studentContracts[_studentAddress];
    }
    
    function getStudentName(address _address) private view returns (string memory){
       return (studentMappings[_address].fullName);
    }
    
    function getStudentDetails(address _studentAddress) public view  returns 
    (string memory,string memory,string memory, address, bytes32[] memory) {
        return (studentMappings[_studentAddress].fullName,
        studentMappings[_studentAddress].dateOfBirth,
        studentMappings[_studentAddress].studentID,
        studentContracts[_studentAddress],
        studentMappings[_studentAddress].records);
    }
    
    function getRecordDetails(bytes32  _recordID) public view returns 
    (address, address, string memory, string memory, string memory, string memory){
        return (recordMappings[_recordID].holderAddress, 
        recordMappings[_recordID].issuerAddress, 
        recordMappings[_recordID].dateOfIssue, 
        recordMappings[_recordID].title, 
        recordMappings[_recordID].studentFullName, 
        recordMappings[_recordID].ipfsHash);
    }
    
    function setStudentName(address _studentAddress, string memory _newName) public restricted returns(bool){
        studentMappings[_studentAddress].fullName = _newName;
        return true;
    }
    
    function setDateOfBirth(address _studentAddress, string memory _newDOB) public restricted returns(bool){
        studentMappings[_studentAddress].dateOfBirth = _newDOB;
        return true;
    }
    function setStudentID(address _studentAddress, string memory _newID) public restricted returns(bool){
        studentMappings[_studentAddress].studentID = _newID;
        return true;
    }
    
    function countStudents() view public returns (uint) {
        return listOfStudents.length;
    }
    

    
    function setRecordHolder(bytes32 _recordID, address _oldStudent, address _newStudent) 
    public restricted returns(bool){
        if(studentExists(_oldStudent) == false && studentExists(_newStudent) == false){
            return false;
        }
        else if(recordExists(_recordID) == false){
            return false;
        }
            Record storage oldRecord = recordMappings[_recordID];
            bytes32 randomHash = random(_newStudent, oldRecord.title, oldRecord.dateOfIssue, oldRecord.ipfsHash);
            Record storage newRecord = recordMappings[randomHash];
            newRecord.holderAddress = _newStudent;
            newRecord.issuerAddress = universityAddress;
            newRecord.dateOfIssue = oldRecord.dateOfIssue;
            newRecord.title = oldRecord.dateOfIssue;
            newRecord.studentFullName = getStudentName(_newStudent);
            newRecord.ipfsHash = oldRecord.ipfsHash;
            addRecordToStudent(randomHash, _newStudent);
            deleteRecord(_oldStudent, _recordID);
            return true;
    }
    
    function setDateOfIssue(bytes32 _recordID, string memory _dateOfIssue) public restricted returns(bool){
        if(recordExists(_recordID) == false){
            return false;
        }
        recordMappings[_recordID].dateOfIssue = _dateOfIssue;
        return true;
    }
    
    function setRecordTitle(bytes32 _recordID, string memory _title) public restricted returns(bool){
        if(recordExists(_recordID) == false){
            return false;
        }
        recordMappings[_recordID].title = _title;
        return true;
    }
    
    function setRecipientName(bytes32 _recordID, string memory _name) public restricted returns(bool){
        if(recordExists(_recordID) == false){
            return false;
        }
        recordMappings[_recordID].studentFullName = _name;
        return true;
    }
    
    function setIpfsHash(bytes32 _recordID, string memory _ipfsHash) public restricted returns(bool){
        if(recordExists(_recordID) == false){
            return false;
        }
        recordMappings[_recordID].ipfsHash = _ipfsHash;
        return true;
    }
    
    
    function studentExists(address  _studentAddress) private restricted view returns(bool){
        return isStudent[_studentAddress];
    }
    
    function recordExists(bytes32 _recordID) private restricted view returns(bool){
        return isRecord[_recordID];
    }
    
    // ################# Ulitity functions 
    
    function random(address _address, string memory _string1, string memory _string2, 
    string memory _string3)  private pure returns (bytes32) {
        return bytes32(keccak256(abi.encodePacked(_address, _string1, _string2, _string3)));
    }
    
    function compareBytes32(bytes32  _bytes1, bytes32  _bytes2) private pure returns (bool){
        return keccak256(abi.encodePacked(_bytes1)) == keccak256(abi.encodePacked(_bytes2));
    }
}