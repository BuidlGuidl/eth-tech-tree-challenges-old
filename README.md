# Multisend Challenge - ETH Tech Tree
*--Change the above "Template For Challenge" to the challenge name--*
*--Add a paragraph sized story that pulls in the challenger to their mission--*

Once we finish these methods we will have you deploy your contract on a testnet to be checked against our foundry tests that autograde your submission.

It already has an object in challenges.json which has the name field 'multisend'.
*--End of story section--*

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
*--Edit this section--*
This challenge will require the user to build a contract that is capable of sending tokens or ETH to multiple provided addresses. The contract design uses two separate methods, one for sending ETH and one for sending any ERC20 token. Each method will be provided an array of addresses and an array of amounts. The ERC20 method will also receive the token address.

The challenge is broken down into two main parts:

1. `sendETH()`
2. `sendTokens()`

Each of the above functions have natspec that outlines the requirements for the params and function. We will use these to help guide us through.

## ⛳️ **Checkpoint 1: `sendETH()`** 🤑

<!-- ![image]() -->


> 💡 _Hints:_ 

> 💡💡 _More Hints:_ 

<details markdown='1'><summary>🦉 Guided Explanation</summary>

<!-- TODO: Insert explanation here -->

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

```

<!-- TODO: Add function solution here -->

```

</details>

❗️

### 🥅 Goals / Checks

- [ ] 🤔 
- [ ] 💃 

Here are some helpful references:
*Replace with real resource links if any*
- [one](buidlguidl.com)
- [two](buidlguidl.com)
- [three](buidlguidl.com)

*-- TODO: DELETE THIS LINE WHEN DONE - End of challenge specific section--*

**Don't change any existing method names** as it will break tests but feel free to add additional methods if it helps you complete the task.

When you think you are done run `yarn foundry:test` to run a set of tests against your code. If all your tests pass then you are good to go! If some are returning errors then you might find it useful to run the command with the extra logging verbosity flag `-vvvv` (`yarn foundry:test -vvvv`) as this will show you very detailed information about where tests are failing. You can also use the `--match-test "TestName"` flag to only run a single test. Of course you can chain both to include a higher verbosity and only run a specific test by including both flags `yarn foundry:test -vvvv --match-test "TestName"`. You will also see we have included an import of console2.sol which allows you to use `console.log()` type functionality inside your contracts to know what a value is at a specific time of execution. You can read more about how to use that at [FoundryBook](https://book.getfoundry.sh/reference/forge-std/console-log).

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