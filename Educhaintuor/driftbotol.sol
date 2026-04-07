// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DriftBottle {

    struct BlobInfo {
        string ipfsHash;     
    }

    struct BottleInfo {
        uint256 id;
        address from;
        uint256 fromTime;
        bool isOpen;
        address to;
        uint256 replyTime;    
        BlobInfo[] msgs;              
    }
    
    BottleInfo[] public allBottles;
    uint256 public totalBottles;
    
    mapping(address => uint256[]) public bottleOwned;
    mapping(uint256 => BottleInfo) public idToBottle;
    
    event BottleCreated(uint256 indexed bottleId, address indexed from);
    event BottleReplied(uint256 indexed bottleId, address indexed to);    
    
    function createBottle(string[] memory ipfsHashs) external {
        require(ipfsHashs.length > 0, "Blob cannot be empty");
        uint256 _id = totalBottles + 1; 
        
        BottleInfo storage newBottle = idToBottle[_id];
        newBottle.id = _id;
        newBottle.from = msg.sender;
        newBottle.fromTime = block.timestamp;
        newBottle.isOpen = false;
        newBottle.to = address(0);
        newBottle.replyTime = 0;
        
        for (uint256 i = 0; i < ipfsHashs.length; i++) {
            newBottle.msgs.push(BlobInfo({ipfsHash: ipfsHashs[i]}));
        }
        
        allBottles.push(newBottle);
        bottleOwned[msg.sender].push(_id);      		
        totalBottles ++;        
        
        emit BottleCreated(_id, msg.sender);       
    }
    
    function openAndReplyBottle(uint256 _id, string[] memory ipfsHashs) external {
        require(ipfsHashs.length > 0, "Blob cannot be empty");
        
        BottleInfo storage bottle = idToBottle[_id];
        require(bottle.isOpen == false, "Bottle already opened");
        
        for (uint256 i = 0; i < ipfsHashs.length; i++) {
             bottle.msgs.push(BlobInfo({ipfsHash: ipfsHashs[i]}));
        }
        
        bottle.isOpen = true;
        bottle.to = msg.sender;
        bottle.replyTime = block.timestamp;    
        
        uint256 index = _id-1;
        allBottles[index] = bottle;
        emit BottleReplied(_id, msg.sender);   
    }
    
    function getAllBottles() external view returns (BottleInfo[] memory) {
        return allBottles;
    }  
    
    function getBottleMessages(uint256 _id) public view returns (BlobInfo[] memory){
        return idToBottle[_id].msgs;    
    }                    
}