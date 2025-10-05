// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract QuestController {
    event QuestCompleted(address indexed userAddress, uint256 questId);

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero address");
        owner = newOwner;
    }

    // Example entry-point that a frontend button can call on Base Sepolia
    function completeQuest(uint256 questId) external {
        emit QuestCompleted(msg.sender, questId);
    }
}



