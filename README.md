# ETH Streaming Challenge - ETH Tech Tree

In a world where asset allocation mechanisms have grown stale, a visionary group of technologists known as **_The StreamWeavers_** emerges. Their mission is to pioneer novel means of distributing capital that incentivize creativity and coordination. As a core developer for **_The StreamWeavers_**, you are tasked with forging the smart contracts that will allow this new system to flourish and ensure that everyone can manage their digital assets freely.

## Contents

- [ETH Streaming Challenge - ETH Tech Tree](#eth-streaming-challenge---eth-tech-tree)
  - [Contents](#contents)
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

Amidst a backdrop where centralized control over capital resouces stifles innovation and freedom, your challenge is to write a smart contract named "EthStreaming". This contract will empower authorized users to manage Ethereum assets in a decentralized manner—ensuring that the flow of resources is as continuous and uninterrupted as the ideals we uphold. Designated accounts will be permitted to withdraw predefined amounts of ETH, dictated by the passage of time since their last withrawal.

As the architect, you will start this endeavor in `packages/foundry/contracts/EthStreaming.sol` where you will craft a new paradigm where freedom and resources flow hand in hand.

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
