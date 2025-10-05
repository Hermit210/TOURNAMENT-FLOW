# TournamentFlow Deployment Guide

This guide will help you deploy and run the TournamentFlow decentralized gaming tournament platform.

## Quick Start (Local Development)

### Prerequisites
- Node.js 14+ installed
- Git installed
- Web3 wallet (MetaMask recommended)

### 1. Clone the Repository
```bash
git clone https://github.com/Hermit210/quest.git
cd quest
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Start the Local Server
```bash
npm start
```

The server will start at `http://localhost:3000`

### 4. Open in Browser
Navigate to `http://localhost:3000` to access TournamentFlow

## Available Pages

- **Home**: `http://localhost:3000/` - Platform overview and features
- **Tournaments**: `http://localhost:3000/tournaments.html` - Create and join tournaments
- **Rewards**: `http://localhost:3000/rewards.html` - View payouts and leaderboards
- **Documentation**: `http://localhost:3000/docs.html` - Complete platform documentation

## Smart Contract Deployment

### Prerequisites
- Hardhat or Foundry installed
- Kwala Testnet RPC access
- Funded wallet for deployment

### 1. Deploy Tournament Contracts
```bash
# Using Hardhat
npx hardhat deploy --network kwala-testnet

# Or manually deploy:
# - contracts/TournamentManager.sol
# - contracts/AchievementNFT.sol
```

### 2. Configure Contract Addresses
Update the contract addresses in:
- `web/tournaments.html` (JavaScript section)
- `kwala/tournament-automation.yaml`

## Kwala Workflow Deployment

### 1. Install Kwala CLI
```bash
npm install -g @kwala/cli
```

### 2. Configure Workflow
Edit `kwala/tournament-automation.yaml` with your contract addresses:
```yaml
secrets:
  - TOURNAMENT_MANAGER_ADDRESS=0x...
  - ACHIEVEMENT_NFT_ADDRESS=0x...
  - TOURNAMENT_WEBHOOK_URL=https://...
  - PRIVATE_KEY=0x...
```

### 3. Deploy Workflows
```bash
kwala deploy kwala/tournament-automation.yaml
```

## Environment Configuration

### Required Environment Variables
Create a `.env` file in the project root:
```env
# Contract Addresses
TOURNAMENT_MANAGER_ADDRESS=0x...
ACHIEVEMENT_NFT_ADDRESS=0x...

# Network Configuration
KWALA_TESTNET_RPC_URL=https://testnet-rpc.kwala.com
CHAIN_ID=2410

# Webhook Configuration
TOURNAMENT_WEBHOOK_URL=https://your-webhook-url.com

# Deployment Keys
PRIVATE_KEY=0x...
DEPLOYER_ADDRESS=0x...
```

## Production Deployment

### Option 1: Static Hosting (Recommended)
Deploy the `web/` folder to any static hosting service:
- **Vercel**: `vercel --prod`
- **Netlify**: Drag and drop `web/` folder
- **GitHub Pages**: Enable in repository settings
- **IPFS**: `ipfs add -r web/`

### Option 2: VPS/Cloud Server
```bash
# Install PM2 for process management
npm install -g pm2

# Start the server with PM2
pm2 start server.js --name "tournamentflow"

# Configure nginx reverse proxy (optional)
# Point domain to localhost:3000
```

### Option 3: Docker Deployment
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

```bash
# Build and run
docker build -t tournamentflow .
docker run -p 3000:3000 tournamentflow
```

## Network Configuration

### Kwala Testnet Setup
Add Kwala Testnet to your wallet:
- **Network Name**: Kwala Testnet
- **RPC URL**: `https://testnet-rpc.kwala.com`
- **Chain ID**: `2410`
- **Currency Symbol**: `KWALA`
- **Block Explorer**: `https://testnet-explorer.kwala.com`

### Getting Test Tokens
1. Visit Kwala Testnet faucet
2. Request test KWALA tokens
3. Use tokens for tournament entry fees

## Troubleshooting

### Common Issues

**Server won't start**
- Check Node.js version (14+ required)
- Ensure port 3000 is available
- Run `npm install` to install dependencies

**Wallet connection fails**
- Ensure you're using HTTPS or localhost
- Check if wallet extension is installed
- Verify network configuration

**Transactions fail**
- Check wallet has sufficient KWALA tokens
- Verify contract addresses are correct
- Ensure you're on Kwala Testnet

**Kwala workflows not triggering**
- Verify contract addresses in workflow config
- Check webhook URLs are accessible
- Ensure private key has necessary permissions

### Support

For additional support:
- Check the [Documentation](./web/docs.html)
- Review smart contract code in `contracts/`
- Examine Kwala workflows in `kwala/`
- Open an issue on GitHub

## Security Considerations

### Production Checklist
- [ ] Use environment variables for sensitive data
- [ ] Enable HTTPS for production domains
- [ ] Implement rate limiting for API endpoints
- [ ] Audit smart contracts before mainnet deployment
- [ ] Use hardware wallets for deployment keys
- [ ] Set up monitoring and alerting
- [ ] Configure backup and recovery procedures

### Smart Contract Security
- All contracts use OpenZeppelin libraries
- ReentrancyGuard prevents reentrancy attacks
- AccessControl manages permissions
- Proper input validation and error handling

## Performance Optimization

### Frontend Optimization
- Static assets are cached by browsers
- Minimal JavaScript dependencies
- Responsive design for mobile devices
- Progressive enhancement for Web3 features

### Backend Optimization
- Lightweight Node.js server
- Efficient file serving with proper MIME types
- Graceful error handling and 404 pages
- Process management with PM2 in production

## Monitoring and Analytics

### Recommended Tools
- **Uptime Monitoring**: UptimeRobot, Pingdom
- **Error Tracking**: Sentry, LogRocket
- **Analytics**: Google Analytics, Plausible
- **Performance**: Lighthouse, WebPageTest

### Kwala Workflow Monitoring
- Monitor workflow execution logs
- Set up alerts for failed transactions
- Track tournament creation and completion rates
- Monitor prize distribution success rates