// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TournamentManager
 * @dev Manages decentralized gaming tournaments with automated Kwala workflows
 */
contract TournamentManager is ReentrancyGuard, Ownable {
    struct Tournament {
        uint256 id;
        string name;
        address creator;
        uint256 maxPlayers;
        uint256 entryFee;
        uint256 prizePool;
        uint256 registeredPlayers;
        bool isActive;
        bool isCompleted;
        address winner;
        uint256 createdAt;
        uint256 startedAt;
        uint256 completedAt;
    }

    struct Player {
        address playerAddress;
        string username;
        uint256 registeredAt;
        bool isEliminated;
    }

    mapping(uint256 => Tournament) public tournaments;
    mapping(uint256 => mapping(address => Player)) public tournamentPlayers;
    mapping(uint256 => address[]) public tournamentPlayersList;
    
    uint256 public nextTournamentId = 1;
    uint256 public platformFeePercent = 5; // 5% platform fee
    
    event TournamentCreated(
        uint256 indexed tournamentId,
        address indexed creator,
        string name,
        uint256 maxPlayers,
        uint256 entryFee
    );
    
    event PlayerRegistered(
        uint256 indexed tournamentId,
        address indexed player,
        string username
    );
    
    event TournamentStarted(
        uint256 indexed tournamentId,
        uint256 playerCount
    );
    
    event MatchCompleted(
        uint256 indexed tournamentId,
        address indexed winner,
        address indexed loser,
        uint256 round
    );
    
    event TournamentCompleted(
        uint256 indexed tournamentId,
        address indexed winner,
        uint256 prizeAmount
    );
    
    event PrizeDistributed(
        uint256 indexed tournamentId,
        address indexed recipient,
        uint256 amount,
        string position
    );

    constructor() {}

    /**
     * @dev Create a new tournament
     */
    function createTournament(
        string memory _name,
        uint256 _maxPlayers,
        uint256 _entryFee
    ) external returns (uint256) {
        require(_maxPlayers >= 2, "Minimum 2 players required");
        require(_maxPlayers <= 256, "Maximum 256 players allowed");
        require(bytes(_name).length > 0, "Tournament name required");
        
        uint256 tournamentId = nextTournamentId++;
        
        tournaments[tournamentId] = Tournament({
            id: tournamentId,
            name: _name,
            creator: msg.sender,
            maxPlayers: _maxPlayers,
            entryFee: _entryFee,
            prizePool: 0,
            registeredPlayers: 0,
            isActive: true,
            isCompleted: false,
            winner: address(0),
            createdAt: block.timestamp,
            startedAt: 0,
            completedAt: 0
        });
        
        emit TournamentCreated(tournamentId, msg.sender, _name, _maxPlayers, _entryFee);
        return tournamentId;
    }

    /**
     * @dev Register for a tournament
     */
    function registerForTournament(
        uint256 _tournamentId,
        string memory _username
    ) external payable nonReentrant {
        Tournament storage tournament = tournaments[_tournamentId];
        
        require(tournament.isActive, "Tournament not active");
        require(!tournament.isCompleted, "Tournament completed");
        require(tournament.registeredPlayers < tournament.maxPlayers, "Tournament full");
        require(msg.value == tournament.entryFee, "Incorrect entry fee");
        require(tournamentPlayers[_tournamentId][msg.sender].playerAddress == address(0), "Already registered");
        require(bytes(_username).length > 0, "Username required");
        
        // Register player
        tournamentPlayers[_tournamentId][msg.sender] = Player({
            playerAddress: msg.sender,
            username: _username,
            registeredAt: block.timestamp,
            isEliminated: false
        });
        
        tournamentPlayersList[_tournamentId].push(msg.sender);
        tournament.registeredPlayers++;
        tournament.prizePool += msg.value;
        
        emit PlayerRegistered(_tournamentId, msg.sender, _username);
        
        // Auto-start tournament when full
        if (tournament.registeredPlayers == tournament.maxPlayers) {
            _startTournament(_tournamentId);
        }
    }

    /**
     * @dev Start tournament (internal)
     */
    function _startTournament(uint256 _tournamentId) internal {
        Tournament storage tournament = tournaments[_tournamentId];
        tournament.startedAt = block.timestamp;
        
        emit TournamentStarted(_tournamentId, tournament.registeredPlayers);
    }

    /**
     * @dev Report match result (called by Kwala workflow or authorized oracle)
     */
    function reportMatchResult(
        uint256 _tournamentId,
        address _winner,
        address _loser,
        uint256 _round
    ) external {
        // In production, this would have proper authorization
        require(tournaments[_tournamentId].isActive, "Tournament not active");
        require(!tournaments[_tournamentId].isCompleted, "Tournament completed");
        
        // Mark loser as eliminated
        tournamentPlayers[_tournamentId][_loser].isEliminated = true;
        
        emit MatchCompleted(_tournamentId, _winner, _loser, _round);
        
        // Check if tournament is complete (only one player left)
        uint256 activePlayers = _getActivePlayerCount(_tournamentId);
        if (activePlayers == 1) {
            _completeTournament(_tournamentId, _winner);
        }
    }

    /**
     * @dev Complete tournament and distribute prizes
     */
    function _completeTournament(uint256 _tournamentId, address _winner) internal {
        Tournament storage tournament = tournaments[_tournamentId];
        tournament.isCompleted = true;
        tournament.winner = _winner;
        tournament.completedAt = block.timestamp;
        
        // Calculate prize distribution
        uint256 totalPrize = tournament.prizePool;
        uint256 platformFee = (totalPrize * platformFeePercent) / 100;
        uint256 winnerPrize = totalPrize - platformFee;
        
        // Distribute prizes
        payable(_winner).transfer(winnerPrize);
        payable(owner()).transfer(platformFee);
        
        emit TournamentCompleted(_tournamentId, _winner, winnerPrize);
        emit PrizeDistributed(_tournamentId, _winner, winnerPrize, "1st Place");
    }

    /**
     * @dev Get active player count
     */
    function _getActivePlayerCount(uint256 _tournamentId) internal view returns (uint256) {
        uint256 count = 0;
        address[] memory players = tournamentPlayersList[_tournamentId];
        
        for (uint256 i = 0; i < players.length; i++) {
            if (!tournamentPlayers[_tournamentId][players[i]].isEliminated) {
                count++;
            }
        }
        return count;
    }

    /**
     * @dev Get tournament details
     */
    function getTournament(uint256 _tournamentId) external view returns (Tournament memory) {
        return tournaments[_tournamentId];
    }

    /**
     * @dev Get tournament players
     */
    function getTournamentPlayers(uint256 _tournamentId) external view returns (address[] memory) {
        return tournamentPlayersList[_tournamentId];
    }

    /**
     * @dev Check if player is registered
     */
    function isPlayerRegistered(uint256 _tournamentId, address _player) external view returns (bool) {
        return tournamentPlayers[_tournamentId][_player].playerAddress != address(0);
    }

    /**
     * @dev Update platform fee (owner only)
     */
    function updatePlatformFee(uint256 _newFeePercent) external onlyOwner {
        require(_newFeePercent <= 10, "Fee cannot exceed 10%");
        platformFeePercent = _newFeePercent;
    }

    /**
     * @dev Emergency tournament cancellation (owner only)
     */
    function cancelTournament(uint256 _tournamentId) external onlyOwner {
        Tournament storage tournament = tournaments[_tournamentId];
        require(tournament.isActive, "Tournament not active");
        require(!tournament.isCompleted, "Tournament already completed");
        
        tournament.isActive = false;
        
        // Refund all players
        address[] memory players = tournamentPlayersList[_tournamentId];
        for (uint256 i = 0; i < players.length; i++) {
            payable(players[i]).transfer(tournament.entryFee);
        }
    }
}