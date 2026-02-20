# Recycle-Ledger DAO Smart Contract

## Overview

**Recycle-Ledger.clar** is a DAO smart contract for incentivizing recycling and funding environmental projects. It uses an internal token ledger, staking for voting power, and a proposal system for transparent fund allocation.

## Features

- **Internal Token Minting:** Users mint "RECYCLE" tokens for donations and rewards.
- **Staking:** Stake tokens to gain voting power for DAO proposals.
- **Recycling Submissions:** Submit recycling reports for admin verification and rewards.
- **Proposal System:** Create, vote, and execute funding proposals with quorum.
- **Admin Controls:** Admin can verify submissions and change admin role.
- **Event Logging:** Key actions are logged for transparency.

## Key Functions

- `mint-tokens(amount)`  
  Mint internal tokens for donations or rewards.

- `donate-to-treasury(amount)`  
  Donate tokens to the DAO treasury.

- `submit-recycling(weight)`  
  Submit a recycling report for verification.

- `verify-submission(id)`  
  Admin verifies a submission and rewards the user.

- `stake-tokens(amount)`  
  Stake tokens to gain voting power.

- `unstake-tokens(amount)`  
  Unstake tokens to reclaim balance.

- `create-proposal(title, description-hash, amount)`  
  Create a funding proposal.

- `vote-on-proposal(proposal-id)`  
  Vote on a proposal with staked tokens.

- `execute-proposal(proposal-id)`  
  Execute a proposal if quorum is met.

- `change-admin(new-admin)`  
  Admin-only function to change admin.

## Testing

This contract is Clarinet-friendly and can be tested using [Clarinet](https://github.com/clarinet/clarinet).

## Deployment

Deploy on the Stacks blockchain using the `.clar` file. The initial admin is the deployer.

## License

MIT License

---

**File:** Recycle-Ledger.clar  
**Version:** 1.1
