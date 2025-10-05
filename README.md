# QuestFlow Rewards Engine

Backendless, event-driven NFT drops and dynamic rewards automation for Web3 Gaming powered by Kwala.

## How it works
- On-chain action emits `QuestCompleted(address userAddress, uint256 questId)` from `QuestController` on Base Sepolia.
- Kwala workflow (`kwala/kwala-nft-reward.yaml`) listens for the event.
- Workflow rolls a random int 1-100; if `< 50`, it calls `safeMint(to, 2)` on `EpicNFT` (gasless via signer).
- Workflow sends a webhook notification for success/failure.

## Repo structure
- `contracts/` — example `QuestController.sol` and `EpicNFT.sol` contracts
- `kwala/` — `kwala-nft-reward.yaml` automation workflow
- `web/` — static site: `index.html` (3D landing), `trigger.html`, `rewards.html`, `docs.html`

## Prerequisites
- Node.js 18+
- A Base Sepolia RPC URL
- A deployer wallet funded on Base Sepolia
- A dedicated minter key for Kwala (limited permissions)

## Environment variables
Copy `.env.example` to `.env` and fill values.

```
KV_KWALA_MINTER_PRIVATE_KEY=
BASE_SEPOLIA_RPC_URL=
DISCORD_WEBHOOK_URL=
FAILURE_WEBHOOK_URL=
QUEST_CONTROLLER_ADDRESS=
EPIC_NFT_ADDRESS=
```

## Deploy contracts (example)
Use Remix/Hardhat/Foundry.
1) Deploy `QuestController` to Base Sepolia; save address.
2) Deploy `EpicNFT` to Base Sepolia; save address.
3) Call `setMinter(<kwala_executor_address>, true)` on `EpicNFT`.

## Configure Kwala workflow
Edit `kwala/kwala-nft-reward.yaml`:
- Set `contract_address` under `trigger` to `QUEST_CONTROLLER_ADDRESS`.
- Set `contract_address` under `mint_epic_nft` to `EPIC_NFT_ADDRESS`.
- Set `signer_key` to `${KV_KWALA_MINTER_PRIVATE_KEY}`.
- Replace webhook URLs with `DISCORD_WEBHOOK_URL` and `FAILURE_WEBHOOK_URL`.

Open `web/index.html` to view the 3D landing, `web/trigger.html` to run the demo end-to-end. 


