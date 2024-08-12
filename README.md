# 🗳️💠 Token Vote Delegation Challenge - ETH Tech Tree

Governance is a fundamental aspect of decentralized systems, enabling stakeholders to influence the direction and decisions of a project. A crucial feature in governance is the ability to delegate voting power, which allows token holders to entrust their voting rights to another address. This challenge will guide you through the creation of a governance contract that facilitates vote delegation, providing valuable insights into decentralized decision-making processes. 🏛️

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

This challenge will require users to build a governance system consisting of two main contracts: a GovernanceToken contract and a Governance contract. The token holders should be able to delegate their vote to another address and create proposals only if they meet certain criteria.

Steps:
1. GovernanceToken Contract:

Delegate Function: Users should be able to delegate their votes to another address.
Undelegate Function: Users should be able to undelegate their votes, reverting to self-voting.
Your task starts in `packages/foundry/contracts/GovernanceToken.sol`. Use your Solidity skills to implement the delegate and undelegate functionalities.

2. Governance Contract:

Proposal Creation: Only users holding a certain threshold of tokens, either directly or through delegated votes, can create proposals.
Voting: Delegated votes contribute to the voting power of the delegate.
Quorum: Ensure a minimum number of votes are required for proposals to be valid.
Your task continues in `packages/foundry/contracts/GovernanceContract.sol`. Implement the logic for proposal creation, voting, and quorum checking.

Example Case:
To help you understand the requirements better, consider the following scenario:

1. Alice has 100 tokens and delegates her votes to Bob.
2. Bob now has the combined voting power of his own tokens plus Alice's delegated tokens.
3. Bob can now create a proposal if his total voting power (including Alice's tokens) meets the proposal creation threshold.
4. Once the proposal is created, token holders can vote on it, and Bob can vote with the full weight of his and Alice's tokens.
5. A proposal can only pass if it meets the quorum requirement, which ensures that a minimum number of votes are cast.

Here are some helpful references:

- [Compound Governance - Delegation](https://docs.compound.finance/v2/governance/#delegate)


**Don't change any existing method names** as it will break tests but feel free to add additional methods if it helps you complete the task.

When you think you are done run `yarn foundry:test` to run a set of tests against your code. If all your tests pass then you are good to go! If some are returning errors then you might find it useful to run the command with the extra logging verbosity flag `-vvvv` (`yarn foundry:test -vvvv`) as this will show you very detailed information about where tests are failing. You can also use the `--match-test "TestName"` flag to only run a single test. Of course you can chain both to include a higher verbosity and only run a specific test by including both flags `yarn foundry:test -vvvv --match-test "TestName"`. You will also see we have included an import of console2.sol which allows you to use `console.log()` type functionality inside your contracts to know what a value is at a specific time of execution. You can read more about how to use that at [FoundryBook](https://book.getfoundry.sh/reference/forge-std/console-log).

The tests for this challenge can be found in GovernanceContract.t.sol. Feel free to review them to better understand how your challenge submission is failing as well.

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