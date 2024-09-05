# Asset-Backed ERC20 Token -- SunCoin

## Overview

This smart contract implements an ERC20 token using the ERC4626 standard. The token represents an investment in real-world assets, with its supply dynamically adjusted based on the value of the underlying asset pool.

## Features

- ERC20 compliant token
- Implements ERC4626 tokenized vault standard
- Minting mechanism based on asset-to-token ratio
- Yield utilization for token buyback and burn

## Contract Details

### Token Minting

The token minting process is tied to the ratio of total tokens in distribution against the accumulated assets in the contract pool. This ensures that the token supply accurately represents the underlying asset value.

### Yield Utilization

Yields generated from the real-world assets are used to reduce the total amount of tokens in circulation. This is achieved through a buyback and burn mechanism, which helps maintain the token's value proposition.

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
- Solidity ^0.8.0

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/IDEA-godwin/sun-tokens.git
   cd asset-backed-token
   ```

2. Install dependencies:
   ```
   forge install
   ```

3. Compile the contract:
   ```
   forge build
   ```

## Contract Functions

[List and briefly explain the main functions of your contract, such as:]

- `mint(uint256 amount)`: Mints new tokens based on the current asset-to-token ratio.
- `deposit(uint356 amount)`: Mints new tokens based on the current asset-to-token ratio.
- `burn(address owner, uint256 amount)`: Uses yield to buy back and destroy tokens.

## Slides
[Slides link](https://www.canva.com/design/DAGPx60EbrM/P-AWattVgwEPpz6FBUDaxQ/view?utm_content=DAGPx60EbrM&utm_campaign=designshare&utm_medium=link&utm_source=editor)

## Contact
godsdelightjude@gmail.com
