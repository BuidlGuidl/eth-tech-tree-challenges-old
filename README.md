# Template For Challenge - ETH Tech Tree
*--Change the above "Template For Challenge" to the challenge name--*
*--Add a paragraph sized story that pulls in the challenger to their mission--*


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

This challenge will require users to write an ERC20 contract that contains rebasing token logic. 

Rebasing tokens automatically adjust its supply typically based on some external reason, for example: to target a specific price. As the token supply is increased or decreased periodically, the effects are applied to all token holders, proportionally. Rebasing can be used as an alternative price stabilization method versus traditional market mechanisms.

An example of a rebasing token is the Ampleforth token, AMPL.

AMPL uses old contracts called `UFragments.sol`, where `Fragments` are the ERC20 and the underlying value of them are denominated in `GONS`. Balances of users, transferrance of tokens, are all calculated using `GONs` via a mapping and a var called `_gonsPerFragment`. This var changes and thus changes the balance of the Fragments token for a user since the `balanceOf()` function equates to `_gonBalances[who].div(_gonsPerFragment)`. 

> For reference, this can be seen [here](https://etherscan.deth.net/address/0xD46bA6D942050d489DBd938a2C909A5d5039A161).

**Now that you understand the context of rebasing tokens, create one named `Rebasing Token`, with the symbol `$RBT`, with the following parameters:**

1. Inherits ERC20.
2. Rebases RBT, changing the `$RBT` supply porportionally for all token holders.
3. Rebases with a `int` param `SupplyDelta` that dictates how the supply expands or constricts. Rebases can be positive or negative.
4. Rebasing logic: Simply use the initial supply, and the total supply (when rebases occur) to calculate a `_scalingFactor`. The `_scalingFactor` is used to adjust token holder's balances proportionally after rebases.
5. Ensure that the amount transferred when `transfer()` or `transferFrom()` are called are adjusted as per the `_scalingFactor` at the time of the tx.

**Assumptions:**

1. `$RBT` rebasing is called based on some external events. For this exercise it doesn't really matter, but you could imagine that decentralized oracles are querying the price of `$RBT` and if it deviates from some set price then rebases are called.
2. `$RBT` contract owner could be some treasury contract or something that exists in your imagination 😉.
3. `$RBT` _initialSupply is 1 million tokens.
4. `$RBT` `decimals` is 18.
5. `$RBT` is distributed via some imaginary mechanism, for now it's just assumed as another ERC20 and thus can be transferred as such. Thus this is not in the scope of the challenge. That said, tests to ensure that your challenge submission works will just transfer some `$RBT` to fake users and check that your rebasing calculations work correctly.
6. Minting new tokens is not handled via normal mint() functions, token balances are changed as per the rebasing logic implemented within this contract.
7. Burning is handled via the `_beforeTokenTransfer()` hook instead of the typical `burn()` function seen with other ERC20s.

Feel free to ask any questions or express any ideas that will help the end user learn through this challenge.

It already has an object in challenges.json which has the name field 'rebasing-token'.


<details markdown='1'><summary>👩🏽‍🏫 Fun question: what is an ERC20 that can be easily mistaken as a rebasing token? </summary>
Answer: An example of a token that exhibits traits that rhyme with rebasing, but is not rebasing, is stETH. stETH does not change its supply, instead its price increases as staking rewards accumulate. 
</details>

---
Here are some helpful references:
- [AMPL Project Details](https://docs.ampleforth.org/learn/about-the-ampleforth-protocol#:~:text=their%20FORTH%20tokens.-,How%20the%20Ampleforth%20Protocol%20Works,-The%20Ampleforth%20Protocol)
- [AMPL Github](https://github.com/ampleforth/ampleforth-contracts/tree/master)
- [AMPL Rebasing Token Code](https://etherscan.deth.net/address/0xD46bA6D942050d489DBd938a2C909A5d5039A161)

*--End of challenge specific section--*

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