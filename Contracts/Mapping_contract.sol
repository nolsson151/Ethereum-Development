pragma solidity^0.4.25;

contract Courses {
    
    struct Record {
        address holder;
        address issuer;
        bytes32 id;
        string title;
        address insitution;
        string ipfsHash;
    }

    mapping(bytes32 => Record) public recordMappings;
    bytes32[] public recordIndex;
    
    struct Student {
        string date;
        string sName;
        
    }

    // function setRecord(address _holder, address _issuer, ) {
        
    // }
    
    mapping (address => Student) students;
    address[] public studentAccts;
    
    function setStudent(address _address, string _sName) public {
        var student = students[_address];

        student.sName = _sName;
        
        studentAccts.push(_address) -1;
    }
    
    function getStudents() view public returns(address[]) {
        return studentAccts;
    }
    
    function getStudent(address _address) view public returns (string) {
        return (students[_address].sName);
    }
    
    function countStudents() view public returns (uint) {
        return studentAccts.length;
    }
    
}