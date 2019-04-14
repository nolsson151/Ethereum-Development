pragma solidity^0.5.5;

contract StudentContract{
    
    address studentAddress;
    address issuerAddress;
    IssuerContract issuer;
    
    constructor(address _studentAddress, address _issuerAddress ) public{
        studentAddress = _studentAddress;
        issuerAddress = _issuerAddress;
        issuer = IssuerContract(_issuerAddress);
    }
    
    modifier restricted(){
        require(msg.sender == studentAddress);
        _;
    }
    
    function getStudentDetails() public view restricted  returns
    (string memory,string memory,string memory,address, bytes32[] memory) {
        return issuer.getStudentDetails(studentAddress);
    }
    
    function getRecordDetails(bytes32 _recordID) public view restricted returns
    (address, address, string memory, string memory, string memory, string memory){
        return issuer.getRecordDetails(_recordID);
    }
}


contract IssuerContract {
    address private manager;
    mapping (address => Student) private studentMappings;
    mapping (address => bool) private isStudent;
    address[] private studentAccts;
    mapping(address => address) private studentContracts;
    mapping(bytes32 => Record) private recordMappings;
    mapping(bytes32 => bool) private isRecord;
    
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
        r.recipientFullName = getStudentName(_holderAddress);
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
    
    
    function deleteRecord(address _address, bytes32 _recordID) public restricted returns (bool){
        if(studentExists(_address) == false){
            return false;
        }
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
    
    function addStudent(address _address, string memory _fullName, string memory _dateOfBirth, 
    string memory _studentID) public restricted  returns (bool){
        if(studentExists(_address) == true){
            return false;
        }
        Student storage s = studentMappings[_address];
        isStudent[_address] = true;

        s.fullName = _fullName;
        s.dateOfBirth = _dateOfBirth;
        s.studentID = _studentID;
        s.recordCount = 0;
        
        studentContracts[_address] = createStudentContract(_address);
        studentAccts.push(_address) -1;
        isStudent[_address] = true;
        return true;
    }
    
    function createStudentContract(address _studentAddress) private restricted returns (address){
        return address(new StudentContract(_studentAddress, address(this)));
    }
    
    // function deleteStudent(address _address) public restricted returns(bool){
    //     if(studentExists(_address) == false){
    //         return false;
    //     }
    //     if(studentAccts.length == 0){
    //         return false;
    //     }
    //     else{
    //         uint index = 0;
    //         for(uint i =0; i<= studentAccts.length; i++){
    //             if (_address == studentAccts[index]){
    //                 studentAccts[index] = studentAccts[studentAccts.length -1];
    //                 delete studentAccts[studentAccts.length -1];
    //                 studentAccts.length -- ;
    //                 uint recordIndex = studentMappings[_address].recordCount;
    //                 for(uint i=recordIndex; i>=0; i--){
    //                     bytes32[] storage recordsToDelete = studentMappings[_address].records;
    //                     isRecord[recordsToDelete[recordIndex]] = false; 
    //                     delete(recordMappings[recordsToDelete[recordIndex-1]]);
    //                     recordIndex--;
    //                 }
    //                 delete (studentMappings[_address]);
    //                 isStudent[_address] = false;
    //                 return true;
    //             }
    //             else {
    //                 index ++;
    //             }
             
    //         }
    //         return false;
    //     }
    // }
    
    
    function getStudents() view public returns(address[] memory) {
        return studentAccts;
    }
    
    function getStudentContracts(address _studentWallet) public view restricted returns(address){
        return studentContracts[_studentWallet];
    }
    
    function getStudentName(address _address) private view returns (string memory){
       return (studentMappings[_address].fullName);
    }
    
    function getStudentDetails(address _address) public view  returns 
    (string memory,string memory,string memory, address, bytes32[] memory) {
        return (studentMappings[_address].fullName,
        studentMappings[_address].dateOfBirth,
        studentMappings[_address].studentID,
        studentContracts[_address],
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
    

    
    function setRecordHolder(bytes32 _bytes32, address _oldStudent, address _newStudent) 
    public restricted returns(bool){
        if(studentExists(_oldStudent) == false && studentExists(_newStudent) == false){
            return false;
        }
        else if(recordExists(_bytes32) == false){
            return false;
        }
            Record storage oldRecord = recordMappings[_bytes32];
            bytes32 randomHash = random(_newStudent, oldRecord.title, oldRecord.dateOfIssue, oldRecord.ipfsHash);
            Record storage newRecord = recordMappings[randomHash];
            newRecord.holderAddress = _newStudent;
            newRecord.issuerAddress = manager;
            newRecord.dateOfIssue = oldRecord.dateOfIssue;
            newRecord.title = oldRecord.dateOfIssue;
            newRecord.recipientFullName = getStudentName(_newStudent);
            newRecord.ipfsHash = oldRecord.ipfsHash;
            addRecordToStudent(randomHash, _newStudent);
            deleteRecord(_oldStudent, _bytes32);
            return true;
    }
    
    function setDateOfIssue(bytes32 _bytes32, string memory _dateOfIssue) public restricted returns(bool){
        if(recordExists(_bytes32) == false){
            return false;
        }
        recordMappings[_bytes32].dateOfIssue = _dateOfIssue;
        return true;
    }
    
    function setRecordTitle(bytes32 _bytes32, string memory _title) public restricted returns(bool){
        if(recordExists(_bytes32) == false){
            return false;
        }
        recordMappings[_bytes32].title = _title;
        return true;
    }
    
    function setRecipientName(bytes32 _bytes32, string memory _name) public restricted returns(bool){
        if(recordExists(_bytes32) == false){
            return false;
        }
        recordMappings[_bytes32].recipientFullName = _name;
        return true;
    }
    
    function setIpfsHash(bytes32 _bytes32, string memory _ipfsHash) public restricted returns(bool){
        if(recordExists(_bytes32) == false){
            return false;
        }
        recordMappings[_bytes32].ipfsHash = _ipfsHash;
        return true;
    }
    
    
    function studentExists(address  _address) private restricted view returns(bool){
        return isStudent[_address];
    }
    
    function recordExists(bytes32 _bytes32) private restricted view returns(bool){
        return isRecord[_bytes32];
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