## Overview

Buckle up, there’s a lot to learn when writing your first smart contract (often referred to as token). If you want to make it anything more complex than a basic smart contract, this tutorial will be good for you.

This repo demonstrates how to:
- Develop a smart contract to the ERC20 standard
- Develop a smart contract with burning/minting logic
- Allow the contract logic to be upgradeable
- Deploy the smart contract to a blockchain network

The smart contract in this example provides very similar functionality to how SafeMoon works. With this coin, there is a 10% transaction fee: 5% gets burned (gone forever) and 5% of the transaction gets sent to the liquidity pool (such as PancakeSwap). In addition, this coin has a 10% annual interest rate for anyone who holds the coin, compounded weekly. The contract in this repo will follow the ERC20 token standard. Contracts that follow the ERC20 standard are compatible with both Ethereum and Binance Smart Chain networks.

An upgradeable smart contract means that the logic inside of the contract is modifiable, and that the token can be uploaded again and again without having to change the address of the contract on the blockchain.

In this tutorial, I will show you how to upload your smart contract to an Ethereum testnet (Rinkeby). This means you don’t need real money to upload the smart contract.

Caveats to upgradeable contracts:
Please read [this article](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable) to understand everything unique about upgradeable contracts. In particular, the most important sections are [this section](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#potentially-unsafe-operations) and [this section]( https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#modifying-your-contracts) on the things you must 100% avoid of an upgradeable contract. Any upgradeable contract you write must follow these rules.

## Requirements

You should have access to a Metamask wallet. You do not need any funds to start.

In addition, npm must be installed on your machine.

#### Linux:

`sudo apt-get install npm`

#### Mac OS:

Install homebrew through the instruction at this link: https://brew.sh/

`brew install npm`

## Setup Repo

### Initialize repository and download dependencies

`git clone https://github.com/emersonboyd/UpgradeableContractExample.git`

`cd UpgradeableContractExample`

`npm install --save-dev # installs packages listed in package.json`

### Create secrets.json to store network/private keys

You need to create a secrets.json file in your repo’s top-level folder. This file should contain the lines of code listed below. You will need to replace the x’s with your wallet private key. You can access the private key of your Metamask wallet using [this method]( https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).

```
{
  "key": "xxxxxxx",
  "moralisRinkebyUrl": "https://speedy-nodes-nyc.moralis.io/99cc68aa0fa3ad3533303a17/eth/rinkeby"
}
```

Keep this file completely private and do not commit it to any git repo! If others gain access to your private key, they can access your real-life funds.

This secrets.json file tells your deployment script a) which account should perform the deployment and b) where the contract should be deployed (in our case, it’s on the Rinkeby Ethereum test network).

## Steps to Develop/Test Coin:

An example upgradeable contract is located in `contracts/contract.sol`. You can look at this contract to understand how certain minting/burning logic may be applied to smart contracts and how to make your contract upgradeable.

Whenever you develop a contract, you want to create tests for the contract to ensure it functions as you’d expect it to. Test scripts are located in `test/` folder. The tests labeled `.js` file extension test the implementation contract, while tests with the `.proxy.js` file extension test the proxy contract. The “implementation” and “proxy” contracts are concepts specific to upgradeable contracts.

You can run the example tests that are provided by doing the following:

`npx hardhat test`

## Steps to Deploy Coin:
These steps will demonstrate how to deploy the smart contract on an Ethereum test network (Rinkeby). Steps for deploying the token on the Ethereum Mainnet and Binance Smart Chain are very similar.

1) Fund your wallet with fake Rinkeby Ether by following the steps [here](https://faucet.rinkeby.io/).
2) Deploy the proxy and implementation contracts by running the command `npx hardhat run --network moralisRinkebyUrl scripts/deploy.js`. Keep track of the address of the deployed proxy token. You will need it later.

Congratulations, your contract is now deployed! If you want to interact with the methods in your contract via the console, you can look at the ‘Interacting with your Coin’ section of this page to see how to interact with the contract.

Now that your contract has been deployed, you need to setup the ability to upgrade it. In order to do so, you need to transfer ownership of your smart contract to a Gnosis safe.
1) Follow the steps to set up a Gnosis safe [here](https://help.gnosis-safe.io/en/articles/3876461-create-a-safe). Make sure your safe is set up for the Rinkeby network.
2) Copy the address of the newly-created safe. This is not your wallet address, but the address on Gnosis listed under your safe’s name.
3) Go into the `scripts/transfer_ownership.js` file and modify the `gnosisSafe` address to match your newly-created Gnosis safe address.
4) Run `npx hardhat run --network rinkeby scripts/transfer_ownership.js`. If you have problems with this command, read the 'Common Issues' section below.

Your contract is now ready to upgrade and re-deploy. Once you have modified some code in your contract and want to re-deploy it, follow these steps:

1) Go into `scripts/prepare_upgrade.js` and modify the `proxyAddress` to match the address of your deployed token.
2) Execute `npx hardhat run --network rinkeby scripts/prepare_upgrade.js`. Keep track of this new implementation address.
3) Complete the upgrade in Gnosis Safe. Go to the Apps pane in Gnosis Safe and find the OpenZeppelin app.
4) Plug in the proxy address from your initial deployment in the “Contract address” box.
5) Plug in the newly-deployed implementation address in the “New implementation address” box.
6) Press the “Upgrade” button, double check the information, and click the “Submit” button.
7) Sign off on the upgrade via Metamask.

Congratulations, you have upgraded your smart contract! If you want to do console-level interaction with the contract as suggested before, you’ll just need to use the proxy address again. You won’t need the new implementation address anymore.

## Common issues

If you run into an error when where the transfer_ownership.js script wasn't working due to this error:
`Ownable: caller is not the owner`

Then you should delete the `.openzeppelin` folder in your repo's top-level directory and re-deploy the contract to a new proxy address. This means you will have to start over from the beginning of the 'Steps to Deploy Coin' section. Doing this will clear any old wonky state from your project and refresh the state using information about the contract at the new address.

## Interacting with your Coin

Once your code is deployed, you can interact with the contract by calling the functions on the contract! For this, you will need the address of your proxy contract, which is printed when running `scripts/deploy.js`. Follow [the 'Working on a testnet' section of this tutorial]( https://docs.openzeppelin.com/learn/connecting-to-public-test-networks?pref=hardhat#working-on-testnet) for how to call functions on your deployed coin:

## Follow-Up

I recommend you read up more on upgradeable contracts to learn more about how the proxy/implementation pattern works. Without this pattern, upgradeable contracts would be much more difficult to implement. Below are some reads that helped me understand OpenZeppelin upgradeable contracts:
- https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable
- https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies
