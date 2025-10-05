// Tournament Data Management System
class TournamentDataManager {
  constructor() {
    this.tournaments = new Map();
    this.payouts = [];
    this.players = new Map();
    this.loadFromStorage();
  }

  // Load data from localStorage
  loadFromStorage() {
    try {
      const tournamentsData = localStorage.getItem('tournamentflow_tournaments');
      const payoutsData = localStorage.getItem('tournamentflow_payouts');
      const playersData = localStorage.getItem('tournamentflow_players');

      if (tournamentsData) {
        const tournaments = JSON.parse(tournamentsData);
        tournaments.forEach(t => this.tournaments.set(t.id, t));
      }

      if (payoutsData) {
        this.payouts = JSON.parse(payoutsData);
      }

      if (playersData) {
        const players = JSON.parse(playersData);
        players.forEach(p => this.players.set(p.address, p));
      }
    } catch (error) {
      console.warn('Failed to load tournament data from storage:', error);
    }
  }

  // Save data to localStorage
  saveToStorage() {
    try {
      localStorage.setItem('tournamentflow_tournaments', JSON.stringify(Array.from(this.tournaments.values())));
      localStorage.setItem('tournamentflow_payouts', JSON.stringify(this.payouts));
      localStorage.setItem('tournamentflow_players', JSON.stringify(Array.from(this.players.values())));
    } catch (error) {
      console.warn('Failed to save tournament data to storage:', error);
    }
  }

  // Create a new tournament
  createTournament(tournamentData) {
    const tournament = {
      id: tournamentData.id || this.generateId(),
      name: tournamentData.name,
      creator: tournamentData.creator,
      maxPlayers: tournamentData.maxPlayers,
      entryFee: tournamentData.entryFee,
      gameType: tournamentData.gameType,
      status: 'filling', // filling, active, completed
      registeredPlayers: [],
      prizePool: 0,
      createdAt: Date.now(),
      startedAt: null,
      completedAt: null,
      winner: null,
      bracket: null
    };

    this.tournaments.set(tournament.id, tournament);
    this.saveToStorage();
    this.notifyListeners('tournament_created', tournament);
    return tournament;
  }

  // Register a player for a tournament
  registerPlayer(tournamentId, playerData) {
    const tournament = this.tournaments.get(tournamentId);
    if (!tournament) throw new Error('Tournament not found');
    
    if (tournament.registeredPlayers.length >= tournament.maxPlayers) {
      throw new Error('Tournament is full');
    }

    if (tournament.registeredPlayers.some(p => p.address === playerData.address)) {
      throw new Error('Player already registered');
    }

    const player = {
      address: playerData.address,
      username: playerData.username || `Player_${playerData.address.slice(-4)}`,
      registeredAt: Date.now(),
      isEliminated: false
    };

    tournament.registeredPlayers.push(player);
    tournament.prizePool += parseFloat(tournament.entryFee);

    // Store player info
    this.players.set(player.address, {
      ...this.players.get(player.address),
      address: player.address,
      username: player.username,
      tournamentsPlayed: (this.players.get(player.address)?.tournamentsPlayed || 0) + 1
    });

    // Check if tournament should start
    if (tournament.registeredPlayers.length === tournament.maxPlayers) {
      this.startTournament(tournamentId);
    }

    this.saveToStorage();
    this.notifyListeners('player_registered', { tournament, player });
    return tournament;
  }

  // Start a tournament
  startTournament(tournamentId) {
    const tournament = this.tournaments.get(tournamentId);
    if (!tournament) throw new Error('Tournament not found');

    tournament.status = 'active';
    tournament.startedAt = Date.now();
    tournament.bracket = this.generateBracket(tournament.registeredPlayers);

    this.saveToStorage();
    this.notifyListeners('tournament_started', tournament);
    return tournament;
  }

  // Complete a tournament
  completeTournament(tournamentId, winnerId) {
    const tournament = this.tournaments.get(tournamentId);
    if (!tournament) throw new Error('Tournament not found');

    const winner = tournament.registeredPlayers.find(p => p.address === winnerId);
    if (!winner) throw new Error('Winner not found in tournament');

    tournament.status = 'completed';
    tournament.completedAt = Date.now();
    tournament.winner = winner;

    // Calculate prize distribution (90% to winner, 10% platform fee)
    const winnerPrize = tournament.prizePool * 0.9;
    const platformFee = tournament.prizePool * 0.1;

    // Create payout record
    const payout = {
      id: this.generateId(),
      tournamentId: tournament.id,
      tournamentName: tournament.name,
      winner: winner,
      prizeAmount: winnerPrize,
      position: '1st Place',
      transactionHash: this.generateTxHash(),
      timestamp: Date.now(),
      gameType: tournament.gameType
    };

    this.payouts.unshift(payout); // Add to beginning

    // Update player stats
    const playerStats = this.players.get(winner.address) || {};
    playerStats.tournamentsWon = (playerStats.tournamentsWon || 0) + 1;
    playerStats.totalEarnings = (playerStats.totalEarnings || 0) + winnerPrize;
    this.players.set(winner.address, playerStats);

    this.saveToStorage();
    this.notifyListeners('tournament_completed', { tournament, payout });
    return { tournament, payout };
  }

  // Generate tournament bracket
  generateBracket(players) {
    const shuffled = [...players].sort(() => Math.random() - 0.5);
    const rounds = [];
    let currentRound = shuffled;

    while (currentRound.length > 1) {
      const matches = [];
      for (let i = 0; i < currentRound.length; i += 2) {
        if (i + 1 < currentRound.length) {
          matches.push({
            player1: currentRound[i],
            player2: currentRound[i + 1],
            winner: null,
            completed: false
          });
        } else {
          // Bye round
          matches.push({
            player1: currentRound[i],
            player2: null,
            winner: currentRound[i],
            completed: true
          });
        }
      }
      rounds.push(matches);
      currentRound = matches.map(m => m.winner).filter(w => w);
    }

    return rounds;
  }

  // Get all tournaments
  getAllTournaments() {
    return Array.from(this.tournaments.values()).sort((a, b) => b.createdAt - a.createdAt);
  }

  // Get active tournaments
  getActiveTournaments() {
    return this.getAllTournaments().filter(t => t.status !== 'completed');
  }

  // Get completed tournaments
  getCompletedTournaments() {
    return this.getAllTournaments().filter(t => t.status === 'completed');
  }

  // Get all payouts
  getAllPayouts() {
    return [...this.payouts].sort((a, b) => b.timestamp - a.timestamp);
  }

  // Get tournament by ID
  getTournament(id) {
    return this.tournaments.get(id);
  }

  // Get player stats
  getPlayerStats(address) {
    return this.players.get(address) || {};
  }

  // Get leaderboard
  getLeaderboard() {
    const players = Array.from(this.players.values());
    return {
      topWinners: players
        .filter(p => p.tournamentsWon > 0)
        .sort((a, b) => (b.totalEarnings || 0) - (a.totalEarnings || 0))
        .slice(0, 10),
      mostActive: players
        .filter(p => p.tournamentsPlayed > 0)
        .sort((a, b) => (b.tournamentsPlayed || 0) - (a.tournamentsPlayed || 0))
        .slice(0, 10)
    };
  }

  // Utility functions
  generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }

  generateTxHash() {
    return '0x' + Array.from({length: 64}, () => Math.floor(Math.random() * 16).toString(16)).join('');
  }

  formatTimeAgo(timestamp) {
    const now = Date.now();
    const diff = now - timestamp;
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (days > 0) return `${days} day${days > 1 ? 's' : ''} ago`;
    if (hours > 0) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    if (minutes > 0) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    return 'Just now';
  }

  formatAddress(address) {
    if (!address) return '';
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  }

  // Event system for cross-page communication
  listeners = new Map();

  addEventListener(event, callback) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event).push(callback);
  }

  removeEventListener(event, callback) {
    if (this.listeners.has(event)) {
      const callbacks = this.listeners.get(event);
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  notifyListeners(event, data) {
    if (this.listeners.has(event)) {
      this.listeners.get(event).forEach(callback => {
        try {
          callback(data);
        } catch (error) {
          console.error('Error in event listener:', error);
        }
      });
    }
  }

  // Simulate tournament completion for demo purposes
  simulateTournamentCompletion(tournamentId) {
    const tournament = this.tournaments.get(tournamentId);
    if (!tournament || tournament.status !== 'active') return;

    // Pick a random winner
    const winner = tournament.registeredPlayers[Math.floor(Math.random() * tournament.registeredPlayers.length)];
    return this.completeTournament(tournamentId, winner.address);
  }

  // Get statistics
  getStatistics() {
    const tournaments = this.getAllTournaments();
    const payouts = this.getAllPayouts();
    
    return {
      totalTournaments: tournaments.length,
      completedTournaments: tournaments.filter(t => t.status === 'completed').length,
      activeTournaments: tournaments.filter(t => t.status === 'active').length,
      totalPrizeDistributed: payouts.reduce((sum, p) => sum + p.prizeAmount, 0),
      totalPlayers: this.players.size,
      averagePayoutTime: 1.2 // seconds (simulated)
    };
  }
}

// Create global instance
window.tournamentData = new TournamentDataManager();

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
  module.exports = TournamentDataManager;
}