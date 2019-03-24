pragma solidity ^0.4.25;

contract HonorsV2 {
    struct IpfsFile{
        string hash;
        string title;
        address student;
    }
    
    IpfsFile[] public ipfsFiles;
    string public ipfsHash;
    address public issuer;
    
    modifier restricted(){
        require(msg.sender == issuer);
        _;
    }
    
    constructor() public{
        issuer = msg.sender;
        
    }
    
    function createIpfsFile(string hash, string title, address student) public restricted{
        IpfsFile memory newIpfsFile = IpfsFile({
            hash: hash,
            title: title,
            student: student
        });
        ipfsFiles.push(newIpfsFile);
    }
    
    
    function setHash(string x) public{
        ipfsHash = x;
    }

    
    function getMessage() public view returns (string x){
        return ipfsHash;
    }
}