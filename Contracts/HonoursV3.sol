pragma solidity^0.5.5;

contract HonoursV3 {
    address manager;
    mapping (address => Student) students;
    address[] studentAccts;
    mapping(bytes32 => Record)  recordMappings;
    bytes32[] recordIndex;
    
    constructor() public{
        manager = msg.sender;
    }
    struct Record {
        address issuerAddress;
        address holderAddress;
        string dateOfIssue;
        string title;
        string recipientFullName;
        string ipfsHash;
    }
    
    struct Student {
        string fullName;
        string dateOfBirth;
        string studentID;
        bytes32[] records;
        
    }
    
    modifier restricted() {
        require(msg.sender == manager); 
        _;
    }
    

    function addRecord(address _holderAddress, string _title, string _dateOfIssue, string _ipfsHash) public restricted{
        var randomHash = random(_holderAddress, _title, _dateOfIssue, _ipfsHash);
        var record = recordMappings[randomHash];
        
        record.issuerAddress = msg.sender;
        record.holderAddress = _holderAddress;
        record.title = _title;
        record.dateOfIssue = _dateOfIssue;
        record.recipientFullName = getStudentName(_holderAddress);
        record.ipfsHash = _ipfsHash;
        
        recordIndex.push(randomHash) -1;
        addRecordToStudent(randomHash, _holderAddress);
        
    }
    
    function addStudent(address _address, string _fullName, string _dateOfBirth, string _studentID) public {
        var student = students[_address];

        student.fullName = _fullName;
        student.dateOfBirth = _dateOfBirth;
        student.studentID = _studentID;
        
        studentAccts.push(_address) -1;
    }
    
    //Add created record to student personal record array
    function addRecordToStudent(bytes32 _recordID ,address _studentAddress) private{
        var student = students[_studentAddress];
        student.records.push(_recordID) -1;
    }
    
    //Returns all created records by "unique" identifier
    function getRecords() view public returns(bytes32[]){
        return recordIndex;
    }
    function countRecrods() view public returns (uint) {
        return recordIndex.length;
    }
    
    function getRecordDetails(bytes32 _bytes32) public view returns 
    (address, address, string, string, string, string){
        return (recordMappings[_bytes32].holderAddress, 
        recordMappings[_bytes32].issuerAddress, 
        recordMappings[_bytes32].dateOfIssue, 
        recordMappings[_bytes32].title, 
        recordMappings[_bytes32].recipientFullName, 
        recordMappings[_bytes32].ipfsHash);
    }
    
    
    
    function getStudents() view public returns(address[]) {
        return studentAccts;
    }
    function getStudentName(address _address) view public returns (string){
       return (students[_address].fullName);
    }
    
    function getStudentAndRecords(address _address) view public returns (string,bytes32[]) {
        return (students[_address].fullName, students[_address].records);
    }
    function setStudentName(address _studentAddress, string _newName) public restricted{
        var student = students[_studentAddress];
        student.fullName = _newName;
    }
    
    function countStudents() view public returns (uint) {
        return studentAccts.length;
    }
    
    function random(address _address, string _string1, string _string2, string _string3) private returns (bytes32) {
        return bytes32(keccak256(abi.encodePacked(_address, _string1, _string2, _string3)));
    }
    
}