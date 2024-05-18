# Template For Challenge - ETH Tech Tree

## Contents

- [Template For Challenge - ETH Tech Tree](#template-for-challenge---eth-tech-tree)
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

TODO: WIP

The goal for this challenge is to write a simple "stream" contract. A stream contract allows authorized accounts to withdraw up to a specified amount of ETH. After a withdrawal, the priveledged account must wait a specified amount of time before withdrawing the full amount again. This means you will have to calculate the amount of stream cap available using the time elapsed since the last withdrawal. The owner of the contract will be the deployer. Only the owner of the contract is allowed to add a stream.

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
