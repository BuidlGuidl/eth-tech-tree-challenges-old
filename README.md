# Dead Man's Switch - ETH Tech Tree

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

##### Objective:

In this challenge, you will create a smart contract that implements a "Dead Man's Switch". This contract allows users to deposit funds (ETH or other tokens) and set a time interval for regular "check-ins". If the user fails to check in within the specified time frame, designated beneficiaries can withdraw the funds.

##### Scenario:

Imagine you want to ensure that your funds are securely passed on to your loved ones or trusted parties if something happens to you and you can no longer interact with the contract. This "Dead Man's Switch" will automate this process based on your predefined conditions.

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
