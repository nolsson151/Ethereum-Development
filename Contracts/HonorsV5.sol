pragma solidity^0.5.5;

contract HonorsV5 {
    address manager;
    mapping (address => Student) studentMappings;
    address[] studentAccts;
    mapping(bytes32 => Record)  recordMappings;
    
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
        uint recordCount;
    }
    //Modifier to require contract creator only.
    modifier restricted() { 
        require(msg.sender == manager); 
        _;
    }
    
    //Creates a record and assigns the details to a corressponding student
    //and add it to their personal record array. Record is also added to
    //a record array of all created records. 
    function addRecord(address _holderAddress, string memory _title, string memory _dateOfIssue,
    string memory _ipfsHash) public restricted returns (bool){
        bytes32 randomHash = random(_holderAddress, _title, _dateOfIssue, _ipfsHash);
        Record storage r = recordMappings[randomHash];
        
        r.issuerAddress = msg.sender;
        r.holderAddress = _holderAddress;
        r.title = _title;
        r.dateOfIssue = _dateOfIssue;
        r.recipientFullName = getStudentName(_holderAddress);
        r.ipfsHash = _ipfsHash;
        addRecordToStudent(randomHash, _holderAddress);
        
    }
    
    function addRecordToStudent(bytes32 _recordID ,address _studentAddress) private {
        Student storage s = studentMappings[_studentAddress];
        s.records.push(_recordID) -1;
        s.recordCount++;
    }
    
    function deleteRecord(address _address, bytes32 _recordID) public restricted returns (bool){
        Student storage s = studentMappings[_address];
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
                    return true;
                }
                else{
                    index++;
                }
            }
            return false;
            }
    }
    
    function addStudent(address _address, string memory _fullName, string memory _dateOfBirth, 
    string memory _studentID) public restricted  returns (bool){
        Student storage s = studentMappings[_address];

        s.fullName = _fullName;
        s.dateOfBirth = _dateOfBirth;
        s.studentID = _studentID;
        s.recordCount = 0;
        studentAccts.push(_address) -1;
        return true;
    }
    
    function deleteStudent(address _address) public restricted returns(bool){
        if(studentAccts.length == 0){
            return false;
        }
        else{
            uint index = 0;
         
            for(uint i =0; i<= studentAccts.length; i++){
                if (_address == studentAccts[index]){
                    studentAccts[index] = studentAccts[studentAccts.length -1];
                    delete studentAccts[studentAccts.length -1];
                    studentAccts.length -- ;
                    delete (studentMappings[_address]);
                    return true;
                }
                else {
                    index ++;
                }
             
            }
            return false;
        }
    }
    
    function getStudents() view public returns(address[] memory) {
        return studentAccts;
    }
    
    function getStudentName(address _address) private view returns (string memory){
       return (studentMappings[_address].fullName);
    }
    
    function getStudentDetails(address _address) public view  returns 
    (string memory,string memory,string memory,bytes32[] memory) {
        return (studentMappings[_address].fullName,
        studentMappings[_address].dateOfBirth,
        studentMappings[_address].studentID, 
        studentMappings[_address].records);
    }
    
    function getRecordDetails(bytes32  _bytes32) public view returns 
    (address, address, string memory, string memory, string memory, string memory){
        return (recordMappings[_bytes32].holderAddress, 
        recordMappings[_bytes32].issuerAddress, 
        recordMappings[_bytes32].dateOfIssue, 
        recordMappings[_bytes32].title, 
        recordMappings[_bytes32].recipientFullName, 
        recordMappings[_bytes32].ipfsHash);
    }
    
    function setStudentName(address _address, string memory _newName) public restricted returns(bool){
        studentMappings[_address].fullName = _newName;
        return true;
    }
    
    function setDateOfBirth(address _address, string memory _newDOB) public restricted returns(bool){
        studentMappings[_address].dateOfBirth = _newDOB;
        return true;
    }
    function setStudentID(address _address, string memory _newID) public restricted returns(bool){
        studentMappings[_address].studentID = _newID;
        return true;
    }
    
    function countStudents() view public returns (uint) {
        return studentAccts.length;
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