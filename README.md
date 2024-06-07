# ERC-5023 Shareable NFT Standard

## Overview

The ERC-5023 standard introduces Shareable Non-Fungible Tokens (NFTs), a new type of token designed for non-scarce digital resources. Unlike traditional NFTs (ERC-721) that focus on scarcity, ERC-5023 tokens gain value through sharing and can be reminted for new recipients while retaining the original version. This standard captures positive externalities and creates incentives through anti-rival logic.

## Abstract

ERC-5023 standardizes an interface for non-fungible, value-holding shareable tokens. These tokens can be minted and shared among multiple owners, allowing for the construction of a graph that describes who has shared what with whom. This approach facilitates the representation of digital items that become more valuable as they are shared.

## Motivation

Existing NFT standards like ERC-721 and ERC-1155 focus on scarce digital resources. ERC-5023 addresses the need for a standard that supports non-scarce digital resources, enabling the representation and incentivization of items that benefit from being shared.

## Key Features

- **Shareability**: Tokens can be reminted and shared with new recipients, preserving the original token.
- **Multiple Ownership**: Supports multiple owners for a single token, reflecting shared value.
- **Positive Externalities**: Tokens gain value as they are shared, encouraging distribution and use.
- **Compatibility**: Designed to work alongside other token standards like ERC-721 and ERC-1155.

## Implementation

ERC-5023 defines an interface for shareable tokens, allowing for digital copying or granting rights to use a resource. This standard supports a wide range of applications, from digital art to access rights and beyond.

## Asset contract

The `Asset` contract implements the ERC-5023 standard, providing functionalities for creating, fractionalizing, and sharing non-fungible assets. Adjustments can be made to suit specific requirements and use cases.

### Contract Functions

- `mint`: Mints a new token and assigns ownership to the specified account.
- `registerAsset`: Registers a new asset, minting a token and assigning ownership to the specified account.
- `fractionalizeAsset`: Fractionalizes an existing asset, dividing its total supply into shares.
- `share`: Shares an existing token with another address.
- `shareAsset`: Shares a fractionalized asset with another address, allocating a specified number of shares.
- Other functions such as `balanceOfMainAsset`, `balanceOfSharedToken`, `ownerOfMainAsset`, etc., provide information about token balances and ownership.

### Install & Test

Installation

```bash
git clone https://github.com/Prodigal-Blockchain/EIP_5023.git
cd EIP_5023
```

npm install

```

```

npx hardhat compile

````

### Deployment

1. Replace .env.example with .env and replace

   - RPC_URL=
   - PRIVATE_KEY=
   - ETHERSCAN_API=

2. To deploy and mint security token and fractionalize , sell shares of asset run

```sh
npx hardhat run scripts/deploy.js --netowrk NETWORK
````

Replace NETWORK valide network of your choice (ex: sepolia or base-sepolia)

##Deployed Address on Sepolia
**Asset** :[0x91fa8663653e932dAf2f5bB556d8A0a33Dc2a2e9](https://sepolia.etherscan.io/address/0x91fa8663653e932dAf2f5bB556d8A0a33Dc2a2e9)
