# DAO governance proposals and Voting - ETH Tech Tree
In a dystopian future where megacorporations have seized control over all aspects of life, a brave group of technologists and activists form an underground movement known as The Decentralized Resistance. Their mission is to create a new society governed by the people, free from the tyranny of corporate overlords. They believe that blockchain technology holds the key to building a fair and transparent governance system. As a key developer in The Decentralized Resistance, you are tasked with creating the smart contracts that will enable this new society to thrive.

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
The Decentralized Resistance has grown rapidly, attracting members from all walks of life who are united in their desire for freedom and self-governance. To ensure that every member's voice is heard, the resistance needs a secure and transparent voting system.

Your task is to create a smart contract that allows token holders to propose and vote on various proposals. For this challenge, you will implement a contract that supports the following:

**Proposal Creation:** Token holders can create proposals. Each proposal has a title, a unique ID, a voting deadline, and an address of the creator.

**Voting:** Token holders can vote on proposals with one of three predefined options: Yea, Nay, or Abstain. The weight of their vote is determined by the number of tokens they hold.

**Result Calculation:** The system calculates the result of the vote after the voting period ends.

You will start your task in `packages/foundry/contracts/Governance.sol`. Use your Solidity skills to enable The Decentralized Resistance to govern itself effectively! 
Follow the requirements of the contract to complete the challenge 100%.

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