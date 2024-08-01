# Signature Voting - ETH Tech Tree

You're colonizing Mars and you have the opportunity to create a new society. Since it's known that you have some Solidity skills, the rest of your cohort asked you to code a 'trustless' voting system to make decisions about how this new world will be designed and governed. You need exactly one vote per wallet address per proposal. Imagine that each colonizer is issued exactly one wallet address so that there is no duplicate voting.

Alice was working on some code for this voting system but didn't finish and decided to stay on Earth. Finish Alice's signature voting code.

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
Voters can sign messages off chain. The sender of a 'vote' transaction may not be the wallet address that signed the message. So, we need a way to get the signer of a signed message in order to record their vote for the correct proposal.

Here are some helpful references:
*Replace with real resource links if any*
- [one](buidlguidl.com)
- [two](buidlguidl.com)
- [three](buidlguidl.com)

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