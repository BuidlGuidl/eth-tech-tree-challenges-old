# Social Recovery Wallet Challenge - ETH Tech Tree

Mother's day, 2023. You decide to send your mom some ETH to help her learn more about your world. You set up a new MetaMask wallet and write down the seed phrase on a nice piece of flowered stationary. You briefly consider custodying the phrase on her behalf, but ultimately decide against it. To understand your cypherpunk values, she needs to truly own her new gift. She's ecstatic. She immediately hops online, and for the next few days, continues to explore the rich new world that is web3. Then...disaster strikes. Her laptop dies and she's LOST HER SEED PHRASE.

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

A year has passed, and after the horrific debacle of last year's mother's day, you've vowed to come up with a more user-friendly wallet design. You need it to be able to withstand the loss of a seed phrase, while retaining as much autonomy as possible.

But how?? You hearken back to your own upbringing for inspiration. Sure, your mom was a central figure, but ultimately, you realize, **it took a village**. You decide to develop your new wallet with this same strategy. What if you could select a group of trustworthy `guardian` addresses that could come together to recover the wallet after the seed phrase was lost.

With that idea, you begin work on your project in `packages/foundry/contracts/SocialRecoveryWallet.sol`.

**Don't change any existing method names** as it will break tests but feel free to add additional methods if it helps you complete the task.

Start by using `yarn foundry:test` to run a set of tests against the contract code. You will see several failing tests. As you add functionality to the contract, periodically run the tests so you can see your progress and address blind spots. If you struggle to understand why some are returning errors then you might find it useful to run the command with the extra logging verbosity flag `-vvvv` (`yarn foundry:test -vvvv`) as this will show you very detailed information about where tests are failing. You can also use the `--match-test "TestName"` flag to only run a single test. Of course you can chain both to include a higher verbosity and only run a specific test by including both flags `yarn foundry:test -vvvv --match-test "TestName"`. You will also see we have included an import of `console2.sol` which allows you to use `console.log()` type functionality inside your contracts to know what a value is at a specific time of execution. You can read more about how to use that at [FoundryBook](https://book.getfoundry.sh/reference/forge-std/console-log).

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
