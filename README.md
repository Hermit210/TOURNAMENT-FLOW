# TournamentFlow

Decentralized Gaming Tournament Platform with automated registration, scheduling, and prize distribution powered by Kwala workflows.

## Overview

TournamentFlow is a comprehensive tournament management platform that automates the entire tournament lifecycle using Kwala's event-driven serverless workflows. From player registration to prize distribution, everything happens automatically on-chain.

## Features

###  Tournament Management
- **Automated Registration**: Players register and pay entry fees through smart contracts
- **Dynamic Brackets**: Kwala workflows generate and update tournament brackets automatically
- **Match Scheduling**: Intelligent scheduling based on tournament progression
- **Prize Distribution**: Instant payouts to winners upon tournament completion

###  Kwala-Powered Automation
- **Event-driven**: Responds to on-chain tournament events in real-time
- **Serverless**: No backend infrastructure required
- **Cross-chain**: Support for multiple blockchain networks
- **Scalable**: Handle multiple concurrent tournaments

###  Gaming Integration
- **Multi-game Support**: Works with any game that can report match results
- **Achievement NFTs**: Automatic minting of tournament badges and achievements
- **Real-time Updates**: Live tournament tracking and notifications
- **Transparent**: All tournament data stored on-chain

## Architecture

### Smart Contracts (Kwala Testnet)
- **TournamentManager.sol**: Core tournament lifecycle management
- **AchievementNFT.sol**: NFT badges for tournament achievements
- **Prize Pool Management**: Automated escrow and distribution

### Kwala Workflows
- **Tournament Creation**: Initialize new tournaments and tracking
- **Player Registration**: Handle registrations and bracket updates
- **Match Processing**: Update brackets based on game results
- **Prize Distribution**: Automatic payouts and achievement minting

### Frontend
- **Tournament Dashboard**: Create and join tournaments
- **Live Brackets**: Real-time tournament progression
- **Reward Tracking**: View payouts and achievements
- **Responsive Design**: Mobile-friendly interface

## Quick Start

### 1. Deploy Contracts
```bash
npx hardhat deploy --network kwala-testnet
```

### 2. Configure Kwala Workflows
```yaml
# kwala/tournament-automation.yaml
name: tournament-automation
triggers:
  - event: TournamentCreated
  - event: PlayerRegistered
  - event: TournamentCompleted
```

### 3. Deploy Workflows
```bash
kwala deploy tournament-automation.yaml
```

### 4. Create Tournament
Visit the [Tournaments page](./web/tournaments.html) to create your first tournament.

## Tournament Flow

1. **Creation**: Organizer creates tournament with entry fee and max players
2. **Registration**: Players register and pay entry fees (held in escrow)
3. **Bracket Generation**: Kwala automatically generates tournament bracket when full
4. **Match Processing**: Game results trigger bracket updates via Kwala workflows
5. **Prize Distribution**: Winners receive prizes automatically upon completion
6. **Achievement Minting**: NFT badges minted for winners and participants

## Integration

### Game Integration
```javascript
// Report match result to trigger Kwala workflow
await tournamentContract.reportMatchResult(
  tournamentId,
  winnerAddress,
  loserAddress,
  roundNumber
);
```

### Webhook Notifications
```javascript
// Receive tournament updates
{
  "event": "tournament_completed",
  "tournament_id": 123,
  "winner": "0x...",
  "prize_amount": "5.2"
}
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

```
TOURNAMENT_MANAGER_ADDRESS=
ACHIEVEMENT_NFT_ADDRESS=
KWALA_TESTNET_RPC_URL=
TOURNAMENT_WEBHOOK_URL=
PRIVATE_KEY=
```

## Repo Structure

- `contracts/` — Tournament smart contracts (TournamentManager, AchievementNFT)
- `kwala/` — Kwala workflow automation files
- `web/` — Frontend application (tournaments, rewards, docs)

## Built for BuildWithKwala Hackathon

TournamentFlow showcases Kwala's capabilities for:
- **Event-driven Automation**: Responding to blockchain events in real-time
- **Serverless Workflows**: Complex tournament logic without backend infrastructure
- **Cross-chain Support**: Tournament platform that works across multiple networks
- **Gaming Infrastructure**: Production-ready tools for Web3 gaming

## Technology Stack

- **Blockchain**: Kwala Testnet (with cross-chain support)
- **Smart Contracts**: Solidity with OpenZeppelin
- **Automation**: Kwala Workflows
- **Frontend**: HTML/CSS/JavaScript with Web3 integration
- **Styling**: Tailwind CSS


## Future Enhancements

- **Multi-game Support**: Integration with popular gaming engines
- **Advanced Brackets**: Double elimination and Swiss tournaments
- **Streaming Integration**: Live tournament broadcasting
- **Mobile App**: Native mobile tournament experience
- **DAO Governance**: Community-driven tournament rules
