# Wrapped Token Challenge - ETH Tech Tree
## Contents
- [Requirements](#requirements)
- [Start Here](#start-here)
- [Challenge Description](#challenge-description)

## Requirements

Before you begin, you need to install the following tools:

- [Node (v18 LTS)](https://nodejs.org/en/download/)
- Yarn ([v1](https://classic.yarnpkg.com/en/docs/install/) or [v2+](https://yarnpkg.com/getting-started/install))
- [Git](https://git-scm.com/downloads)
- [Foundryup](https://book.getfoundry.sh/getting-started/installation)

## Start Here
Run the following commands in your terminal:
```
yarn install
foundryup
```

## Challenge Description
This challenge will require you to write an [ERC20](https://eips.ethereum.org/EIPS/eip-20) compliant token wrapper for ETH. An ERC20 form of ETH is useful because DeFi protocols don't have to worry about integrating special functions for handling native ETH, instead they can just write methods that handle any ERC20 token.

Your task starts in `packages/foundry/contracts/WrappedETH.sol`. Use your solidity skills to make this smart contract receive ETH and give the depositor an equal amount of WETH, an ERC20 version of native ETH. The contract already has all the necessary methods to be ERC20 compliant, you will just have to fill in the details on what each method should do. Here is a helpful reference:
- [Original Ethereum Improvement Proposal for the ERC-20 token standard](https://eips.ethereum.org/EIPS/eip-20)

**Don't change any existing method names** as it will break tests but feel free to add additional methods if it helps you complete the task.

When you think you are done run `yarn foundry:test` to run a set of tests against your code. If all your tests pass then you are good to go! If some are returning errors then you might find it useful to run the command with the extra logging verbosity flag `-vvvv` (`yarn foundry:test -vvvv`) as this will show you very detailed information about where tests are failing.

For a more "hands on" approach you can try testing your contract with the provided front end interface by running the following:
```
yarn chain
```
in a second terminal deploy your contract:
```
yarn deploy
```
in a third terminal start the NextJS front end:
```
yarn start
```