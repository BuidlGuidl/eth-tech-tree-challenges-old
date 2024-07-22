# 🤝💸 Multisend Challenge - ETH Tech Tree 

ETH and token transference are used all the time within the web3 space. Anyone can see it when they follow txs with NFTs, DeFi, RWAs, gaming, and more. As we can see in other challenges in this repo, this ability to have transparent, immutable transference of value is one aspect that makes blockchain technology so powerful. Therefore it is important to understand how to construct these types of transactions, at their most basic levels. 👨🏻‍🏫

Native assets to a blockchain, such as ETH for Ethereum, and ERC20 tokens follow different sequences when being transferred. This tutorial will challenge you as the student to understand one example of carrying out these basic transactions.

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

__For Windows users we highly recommend using [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) or Git Bash as your terminal app.__

## Start Here
Run the following commands in your terminal:
```
yarn install
foundryup
```

## Challenge Description

This challenge will require the user to build a contract that is capable of sending tokens or ETH to multiple provided addresses. Transference of tokens and ETH are basics that a student must understand in smart contract development.

Your task starts in `packages/foundry/contracts/Multisend.sol`. Use your solidity skills to make this smart contract whilst meeting the following criteria:

- The contract design uses two separate methods, one for sending ETH and one for sending any ERC20 token. 
- Each method will be provided an array of addresses and an array of amounts. 
- The ERC20 method will also receive the token address.

Further `requirements` are outlined within the Nat Spec inside `Multisend.sol` similar to all other tech tree challenges. Use the Nat Spec comments combined with troubleshooting using the unit tests for this challenge by following the foundry instructions below.

**Don't change any existing method names** as it will break tests but feel free to add additional methods if it helps you complete the task.

When you think you are done run `yarn foundry:test` to run a set of tests against your code. If all your tests pass then you are good to go! If some are returning errors then you might find it useful to run the command with the extra logging verbosity flag `-vvvv` (`yarn foundry:test -vvvv`) as this will show you very detailed information about where tests are failing. You can also use the `--match-test "TestName"` flag to only run a single test. Of course you can chain both to include a higher verbosity and only run a specific test by including both flags `yarn foundry:test -vvvv --match-test "TestName"`. You will also see we have included an import of console2.sol which allows you to use `console.log()` type functionality inside your contracts to know what a value is at a specific time of execution. You can read more about how to use that at [FoundryBook](https://book.getfoundry.sh/reference/forge-std/console-log).

The tests for this challenge can be found in `Multisend.t.sol`. Feel free to review them to better understand how your challenge submission is failing as well.

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