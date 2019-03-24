pragma solidity^0.5.5;

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
    function addRecord(address _holderAddress, string memory _title, string memory _dateOfIssue,
    string memory _ipfsHash) public restricted{
        bytes32 randomHash = random(_holderAddress, _title, _dateOfIssue, _ipfsHash);
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
    
    function deleteRecord(address _address, bytes32 _recordID) public restricted returns (bool success){
        // bytes32[] storage structRecords = students[_address].records;
        uint index = 0;
        
        for(uint i = 0; i<= students[_address].records.length; i++){
            if( compareBytes32(_recordID, students[_address].records[index]) == true ){
                students[_address].records[index] = students[_address].records[students[_address].records.length -1];
                delete students[_address].records[students[_address].records.length -1];
                students[_address].records.length --;
                delete(recordMappings[_recordID]);
                return success = true;
            }
            else{
                index++;
            }
        }
        return success = false;
        
        // return (students[_address].records[1]);
        // student.records[_recordID]=  student.records[student.records.length -1];
    }
    
    function addStudent(address _address, string memory _fullName, string memory _dateOfBirth, 
    string memory _studentID) public restricted {
        Student storage student = students[_address];

        student.fullName = _fullName;
        student.dateOfBirth = _dateOfBirth;
        student.studentID = _studentID;
        
        studentAccts.push(_address) -1;
    }
    
    //Add created record to student personal record array
    function addRecordToStudent(bytes32 _recordID ,address _studentAddress) private {
        Student storage student = students[_studentAddress];
        student.records.push(_recordID) -1;
    }
    
    //Returns all created records by "unique" identifier
    // function getRecords() view public returns(bytes32[]){
    //     return recordIndex;
    // }
    // function countRecords() view public returns (uint) {
    //     return recordIndex.length;
    // }
    
    function getRecordDetails(bytes32  _bytes32) public view returns 
    (address, address, string memory, string memory, string memory, string memory){
        return (recordMappings[_bytes32].holderAddress, 
        recordMappings[_bytes32].issuerAddress, 
        recordMappings[_bytes32].dateOfIssue, 
        recordMappings[_bytes32].title, 
        recordMappings[_bytes32].recipientFullName, 
        recordMappings[_bytes32].ipfsHash);
    }
    
    function getStudents() view public returns(address[] memory) {
        return studentAccts;
    }
    function getStudentName(address _address) private view returns (string memory){
       return (students[_address].fullName);
    }
    
    function getStudentDetails(address _address) public view  returns 
    (string memory,string memory,string memory,bytes32[] memory) {
        return (students[_address].fullName,
        students[_address].dateOfBirth,
        students[_address].studentID, 
        students[_address].records);
    }
    
    function setStudentName(address _studentAddress, string memory _newName) public restricted returns(bool success){
        Student storage student = students[_studentAddress];
        student.fullName = _newName;
        
        return true;
    
    }
    
    
    
    function countStudents() view public returns (uint) {
        return studentAccts.length;
    }
    
    function random(address _address, string memory _string1, string memory _string2, 
    string memory _string3)  private pure returns (bytes32) {
        return bytes32(keccak256(abi.encodePacked(_address, _string1, _string2, _string3)));
    }
    
    function compareBytes32(bytes32  _bytes1, bytes32  _bytes2) private pure returns (bool){
        return keccak256(abi.encodePacked(_bytes1)) == keccak256(abi.encodePacked(_bytes2));
    }
    
}