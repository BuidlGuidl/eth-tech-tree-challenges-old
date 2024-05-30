# Moloch Rage Quit - ETH Tech Tree

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

### Objective:

In this challenge, you will create a smart contract that simulates a simple DAO (Decentralized Autonomous Organization) allowing members to propose and exchange ETH for shares. Additionally, members can "rage quit" to exchange their shares back for ETH if they are dissatisfied with the DAO's direction.

### Scenario:

Imagine a DAO where members contribute ETH to acquire shares. These shares represent ownership and voting power within the DAO. Members can propose to acquire a specific amount of shares for a certain amount of ETH. If the proposal is approved by the existing members, the proposer can exchange their ETH for the proposed shares. As the DAO evolves, it can accumulate ETH through various activities or spend ETH on services. If a member becomes unhappy with the DAO's direction, they can call the RageQuit function to exchange their shares for their proportionate share of the DAO's ETH holdings.

Here are some helpful references:

- [Moloch DAO Primer](https://medium.com/odyssy/moloch-primer-for-humans-9e6a4f258f78)

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
