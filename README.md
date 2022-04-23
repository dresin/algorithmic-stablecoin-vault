# Algorithmic Stablecoin Vault

This is a DeFi project that can be deployed to Ethereum or any other EVM compatible blockchain. This stack uses [Hardhat](https://hardhat.org) as the platform layer to orchestrate all the tasks. [Ethers](https://docs.ethers.io/v5/) is used for all Ethereum interactions and testing. All smart contracts are written in [Solidity](https://docs.soliditylang.org/en/v0.8.0/) and supported by the [TypeScript](https://www.typescriptlang.org/docs/) environment.

## Business Logic of the Project

During the deployment the algorithmic ERC20 stablecoin and the vault are created, and the vault becomes the owner of the stablecoin. The price of the stablecoin is initially set to 4000 AUD, also during the deployment. Only the owner is able to update the price after the deployment.

Users can deposit the native blockchain currency as a collateral in order to receive a certain amount of stablecoin. The amount of collateral is being tracked for each user and updated if the user deposits more collateral. Users can repay the debt and get some collateral in return.

Users can get an estimation of how much stablecoin for the given collateral they would receive. Users can also get an estimation of how much stablecoin is required in order to withdraw their deposited collateral.

## Using this Project

Clone this repository, then install the dependencies with `npm install`. Build everything with `npm run build`. https://hardhat.org has excellent docs, and can be used as reference for extending this project.

## Available Functionality

### Build Contracts and Generate Typechain Typeings

`npm run compile`

### Deploy to Ethereum

Create/modify network config in `hardhat.config.ts` and add API key and private key, then run:

`npx hardhat run --network rinkeby scripts/deploy.ts`

### Verify on Etherscan

Using the [hardhat-etherscan plugin](https://hardhat.org/plugins/nomiclabs-hardhat-etherscan.html), add Etherscan API key to `hardhat.config.ts`, then run:

`npx hardhat verify --network rinkeby <DEPLOYED ADDRESS>`
