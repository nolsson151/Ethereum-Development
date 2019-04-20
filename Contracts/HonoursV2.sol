pragma solidity ^0.5.5;

contract HonoursV2 {

    function setHash(string x) public{
        ipfsHash = x;
    }

    
    function getHash() public view returns (string x){
        return ipfsHash;
    }
}