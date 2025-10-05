// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EpicNFT is ERC721URIStorage, Ownable {
    mapping(address => bool) public isMinter;

    constructor() ERC721("Epic Loot Box", "EPICLOOT") Ownable(msg.sender) {}

    function setMinter(address account, bool allowed) external onlyOwner {
        isMinter[account] = allowed;
    }

    // Safe mint that Kwala will call with a designated signer
    function safeMint(address to, uint256 tokenId) external {
        require(isMinter[msg.sender], "not minter");
        _safeMint(to, tokenId);
    }
}



