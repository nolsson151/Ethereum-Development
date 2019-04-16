pragma solidity^0.5.5;

contract StudentContract{
    
    address private studentAddress;
    address private universityAddress;
    UniversityContract private universityContract;
    
    constructor(address _studentAddress, address _universityAddress) public{
        studentAddress = _studentAddress;
        universityAddress = _universityAddress;
        universityContract = UniversityContract(_universityAddress);
    }
    
    modifier restricted(){
        require(msg.sender == studentAddress);
        _;
    }
    
    function getStudentDetails() public view restricted  returns
    (string memory,string memory,string memory,address, bytes32[] memory) {
        return universityContract.getStudentDetails(studentAddress);
    }
    
    function getAwardDetails(bytes32 _awardID) public view restricted returns
    (address, address, string memory, string memory, string memory, string memory){
        return universityContract.getAwardDetails(_awardID);
    }
}


contract UniversityContract {
    address private universityAddress;
    mapping (address => Student) private studentMappings;
    mapping (address => bool) private isStudent;
    address[] private listOfStudents;
    mapping (address => address) private studentContracts;
    mapping (bytes32 => Award) private awardMappings;
    mapping (bytes32 => bool) private isAward;
    

    struct Award {
        address universityIssuerAddress;
        address studentAddress;
        string dateOfIssue;
        string title;
        string studentFullName;
        string ipfsHash;
    }
    
    struct Student {
        string fullName;
        string dateOfBirth;
        string studentID;
        bytes32[] awards;
        uint awardCount;
    }
    
    constructor() public{
        universityAddress = msg.sender;
    }
    //Modifier to require contract creator only.
    modifier restricted() { 
        require(msg.sender == universityAddress); 
        _;
    }
    
    //Creates a award and assigns the details to a corressponding student
    //and add it to their personal award array. Award is also added to
    //a award array of all created awards. 
    function addAward(address _studentAddress, string memory _title, string memory _dateOfIssue,
    string memory _ipfsHash) public restricted returns (bool){
        if(studentExists(_studentAddress) == false){
            return false;
        }
        
        bytes32 randomHash = random(_studentAddress, _title, _dateOfIssue, _ipfsHash);
        if(awardExists(randomHash) == true){
            return false;
        }
        Award storage r = awardMappings[randomHash];
        r.universityIssuerAddress = msg.sender;
        r.studentAddress = _studentAddress;
        r.title = _title;
        r.dateOfIssue = _dateOfIssue;
        r.studentFullName = getStudentName(_studentAddress);
        r.ipfsHash = _ipfsHash;
        addAwardToStudent(_studentAddress, randomHash);
        isAward[randomHash] = true;
        return true;
    }
    
    function addAwardToStudent(address _studentAddress, bytes32 _awardID) private {
        Student storage s = studentMappings[_studentAddress];
        s.awards.push(_awardID) -1;
        s.awardCount++;
    }
    
    
    function deleteAward(address _studentAddress, bytes32 _awardID) public restricted returns (bool){
        if(studentExists(_studentAddress) == false){
            return false;
        }
        Student storage s = studentMappings[_studentAddress];
        if(s.awards.length == 0){
            return false;
        
        }
        else{
            uint index = 0;
        
            for(uint i = 0; i<= s.awards.length; i++){
                if( compareBytes32(_awardID, s.awards[index]) == true ){
                    s.awards[index] = s.awards[s.awards.length -1];
                    delete s.awards[s.awards.length -1];
                    s.awards.length --;
                    s.awardCount--;
                    delete(awardMappings[_awardID]);
                    isAward[_awardID] = false;
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
        s.awardCount = 0;
        
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
    
    function getStudentName(address _studentAddress) private view returns (string memory){
       return (studentMappings[_studentAddress].fullName);
    }
    
    function getStudentDetails(address _studentAddress) public view  returns 
    (string memory,string memory,string memory, address, bytes32[] memory) {
        return (studentMappings[_studentAddress].fullName,
        studentMappings[_studentAddress].dateOfBirth,
        studentMappings[_studentAddress].studentID,
        studentContracts[_studentAddress],
        studentMappings[_studentAddress].awards);
    }
    
    
    function getAwardDetails(bytes32  _awardID) public view returns 
    (address, address, string memory, string memory, string memory, string memory){
        return (awardMappings[_awardID].studentAddress, 
        awardMappings[_awardID].universityIssuerAddress, 
        awardMappings[_awardID].dateOfIssue, 
        awardMappings[_awardID].title, 
        awardMappings[_awardID].studentFullName, 
        awardMappings[_awardID].ipfsHash);
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
    

    
    function setAwardHolder(bytes32 _awardID, address _oldStudent, address _newStudent) 
    public restricted returns(bool){
        if(studentExists(_oldStudent) == false && studentExists(_newStudent) == false){
            return false;
        }
        else if(awardExists(_awardID) == false){
            return false;
        }
            Award storage oldAward = awardMappings[_awardID];
            bytes32 randomHash = random(_newStudent, oldAward.title, oldAward.dateOfIssue, oldAward.ipfsHash);
            Award storage newAward = awardMappings[randomHash];
            newAward.studentAddress = _newStudent;
            newAward.universityIssuerAddress = universityAddress;
            newAward.dateOfIssue = oldAward.dateOfIssue;
            newAward.title = oldAward.dateOfIssue;
            newAward.studentFullName = getStudentName(_newStudent);
            newAward.ipfsHash = oldAward.ipfsHash;
            addAwardToStudent(_newStudent, randomHash);
            deleteAward(_oldStudent, _awardID);
            return true;
    }
    
    function setDateOfIssue(bytes32 _awardID, string memory _newDOI) public restricted returns(bool){
        if(awardExists(_awardID) == false){
            return false;
        }
        awardMappings[_awardID].dateOfIssue = _newDOI;
        return true;
    }
    
    function setAwardTitle(bytes32 _awardID, string memory _newTitle) public restricted returns(bool){
        if(awardExists(_awardID) == false){
            return false;
        }
        awardMappings[_awardID].title = _newTitle;
        return true;
    }
    
    function setRecipientName(bytes32 _awardID, string memory _newName) public restricted returns(bool){
        if(awardExists(_awardID) == false){
            return false;
        }
        awardMappings[_awardID].studentFullName = _newName;
        return true;
    }
    
    function setIpfsHash(bytes32 _awardID, string memory _newIfsHash) public restricted returns(bool){
        if(awardExists(_awardID) == false){
            return false;
        }
        awardMappings[_awardID].ipfsHash = _newIfsHash;
        return true;
    }
    
    
    function studentExists(address  _studentAddress) private restricted view returns(bool){
        return isStudent[_studentAddress];
    }
    
    function awardExists(bytes32 _awardID) private restricted view returns(bool){
        return isAward[_awardID];
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