// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title AchievementNFT
 * @dev NFT contract for tournament achievements and badges
 */
contract AchievementNFT is ERC721, ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    struct Achievement {
        string achievementType;
        uint256 tournamentId;
        address recipient;
        uint256 mintedAt;
        string metadata;
    }

    mapping(uint256 => Achievement) public achievements;
    mapping(address => uint256[]) public userAchievements;
    mapping(string => string) public achievementURIs;

    event AchievementMinted(
        uint256 indexed tokenId,
        address indexed recipient,
        string achievementType,
        uint256 tournamentId
    );

    constructor() ERC721("TournamentFlow Achievement", "TFA") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        
        // Set default achievement URIs
        _setDefaultAchievementURIs();
    }

    /**
     * @dev Mint achievement NFT for tournament winner
     */
    function mintAchievement(
        address to,
        string memory achievementType,
        uint256 tournamentId
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        _safeMint(to, tokenId);
        
        string memory tokenURI = achievementURIs[achievementType];
        if (bytes(tokenURI).length == 0) {
            tokenURI = achievementURIs["DEFAULT"];
        }
        _setTokenURI(tokenId, tokenURI);
        
        achievements[tokenId] = Achievement({
            achievementType: achievementType,
            tournamentId: tournamentId,
            recipient: to,
            mintedAt: block.timestamp,
            metadata: ""
        });
        
        userAchievements[to].push(tokenId);
        
        emit AchievementMinted(tokenId, to, achievementType, tournamentId);
        return tokenId;
    }

    /**
     * @dev Batch mint achievements for multiple winners
     */
    function batchMintAchievements(
        address[] memory recipients,
        string[] memory achievementTypes,
        uint256 tournamentId
    ) external onlyRole(MINTER_ROLE) {
        require(recipients.length == achievementTypes.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            mintAchievement(recipients[i], achievementTypes[i], tournamentId);
        }
    }

    /**
     * @dev Set achievement URI for specific type
     */
    function setAchievementURI(string memory achievementType, string memory uri) 
        external onlyRole(DEFAULT_ADMIN_ROLE) {
        achievementURIs[achievementType] = uri;
    }

    /**
     * @dev Get user's achievements
     */
    function getUserAchievements(address user) external view returns (uint256[] memory) {
        return userAchievements[user];
    }

    /**
     * @dev Get achievement details
     */
    function getAchievement(uint256 tokenId) external view returns (Achievement memory) {
        require(_exists(tokenId), "Achievement does not exist");
        return achievements[tokenId];
    }

    /**
     * @dev Check if user has specific achievement type
     */
    function hasAchievementType(address user, string memory achievementType) 
        external view returns (bool) {
        uint256[] memory userTokens = userAchievements[user];
        
        for (uint256 i = 0; i < userTokens.length; i++) {
            if (keccak256(bytes(achievements[userTokens[i]].achievementType)) == 
                keccak256(bytes(achievementType))) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Set default achievement URIs
     */
    function _setDefaultAchievementURIs() internal {
        achievementURIs["TOURNAMENT_WINNER"] = "ipfs://QmTournamentWinner";
        achievementURIs["TOURNAMENT_RUNNER_UP"] = "ipfs://QmTournamentRunnerUp";
        achievementURIs["TOURNAMENT_PARTICIPANT"] = "ipfs://QmTournamentParticipant";
        achievementURIs["FIRST_TOURNAMENT"] = "ipfs://QmFirstTournament";
        achievementURIs["TOURNAMENT_STREAK"] = "ipfs://QmTournamentStreak";
        achievementURIs["DEFAULT"] = "ipfs://QmDefaultAchievement";
    }

    // Required overrides
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}