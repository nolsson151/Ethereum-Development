pragma solidity^0.4.25;

contract HonorsV4 {
    address manager;
    mapping (address => Student) students;
    address[] studentAccts;
    mapping(bytes32 => Record)  recordMappings;
    // bytes32[] recordIndex;
    
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
    
    modifier restricted() { //MODIFIER TO ONLY REQUIRE ONLY CONTRACT CREATOR
        require(msg.sender == manager); 
        _;
    }
    
    //Creates a record and assigns the details to a corressponding student
    //and add it to their personal record array. Record is also added to
    //a record array of all created records. 
    function addRecord(address _holderAddress, string _title, string _dateOfIssue, string _ipfsHash) public restricted{
        var randomHash = random(_holderAddress, _title, _dateOfIssue, _ipfsHash);
        Record storage record = recordMappings[randomHash];
        
        record.issuerAddress = msg.sender;
        record.holderAddress = _holderAddress;
        record.title = _title;
        record.dateOfIssue = _dateOfIssue;
        record.recipientFullName = getStudentName(_holderAddress);
        record.ipfsHash = _ipfsHash;
        
        // recordIndex.push(randomHash) -1;
        addRecordToStudent(randomHash, _holderAddress);
        
    }
    
    function deleteRecord(bytes32 _recordID, address _address) public restricted returns(bytes32){
        var student = students[_address];
        
        return (students[_address].records[1]);
        // student.records[_recordID]=  student.records[student.records.length -1];
        
        // delete(recordMappings[_recordID]);
    }
    
    function addStudent(address _address, string _fullName, string _dateOfBirth, string _studentID) public restricted {
        Student storage student = students[_address];

        student.fullName = _fullName;
        student.dateOfBirth = _dateOfBirth;
        student.studentID = _studentID;
        
        studentAccts.push(_address) -1;
    }
    
    //Add created record to student personal record array
    function addRecordToStudent(bytes32 _recordID ,address _studentAddress) private {
        var student = students[_studentAddress];
        student.records.push(_recordID) -1;
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
    function getStudentName(address _address) private view returns (string){
       return (students[_address].fullName);
    }
    
    function getStudentDetails(address _address) public view  returns 
    (string,string,string,bytes32[]) {
        return (students[_address].fullName,
        students[_address].dateOfBirth,
        students[_address].studentID, 
        students[_address].records);
    }
    
    function setStudentName(address _studentAddress, string _newName) public restricted{
        Student storage student = students[_studentAddress];
        student.fullName = _newName;
        
    }
    
    
    
    function countStudents() view public returns (uint) {
        return studentAccts.length;
    }
    
    function random(address _address, string _string1, string _string2, string _string3) private returns (bytes32) {
        return bytes32(keccak256(abi.encodePacked(_address, _string1, _string2, _string3)));
    }
    
}