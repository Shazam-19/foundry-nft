## Project Flow

This project is a tiny ERC721 NFT collection called "Dogie" (symbol `DOG`) where anyone can mint a token by handing the contract a metadata URI (usually an IPFS link to a JSON file describing the image/attributes).

**The three pieces and how they connect:**

1. **`BasicNFT.sol`** — the actual contract.
   - `mintNft(uri)` — call this to mint yourself a new token. It saves your URI, mints the token to you, then bumps the counter for the next person.
   - `tokenURI(id)` — given a token ID, returns its metadata URI. Reverts if that ID was never minted.

2. **`DeployBasicNFT.s.sol`** — a script to put `BasicNFT` on-chain (local Anvil node, a testnet, or mainnet).
   - Run it once per chain you want to deploy to.

3. **`MintBasicNFT.s.sol`** — a script to interact with an already-deployed contract.
   - `run()` automatically finds the most recent `BasicNFT` deployment on the chain you're targeting (via `foundry-devops`), then calls `mintNFTOnContract()` to mint one NFT using the sample "PUG" URI.

## Typical Local Workflow with Foundry

```bash
# 1. Start a local blockchain
anvil

# 2. Deploy the contract (in another terminal)
forge script script/DeployBasicNFT.s.sol --rpc-url http://127.0.0.1:8545 --private-key <anvil_private_key> --broadcast

# 3. Mint an NFT on it
forge script script/MintBasicNFT.s.sol --rpc-url http://127.0.0.1:8545 --private-key <anvil_private_key> --broadcast

# 4. Run your test suite
forge test -vv
```

## Deploying to Sepolia

Once you're ready to move off a local Anvil node, the same deploy/mint scripts run against Sepolia through the project's Makefile:

```bash
# Deploy BasicNFT to Sepolia
make deploy ARGS="--network sepolia"

# Mint an NFT on the Sepolia deployment
make mint ARGS="--network sepolia"
```

These wrap the same `forge script` calls used locally, just pointed at the Sepolia RPC URL and your funded testnet account (configured via your `.env` and Makefile network settings).