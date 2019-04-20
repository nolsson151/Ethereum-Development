pragma solidity ^0.5.5;

contract HonorsV2 {

    function setHash(string x) public{
        ipfsHash = x;
    }

    
    function getHash() public view returns (string x){
        return ipfsHash;
    }
}