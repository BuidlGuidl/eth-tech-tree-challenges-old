//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/Voting.sol";
import "../contracts/DecentralizedResistanceToken.sol";
import "./DeployHelpers.s.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        DecentralizedResistanceToken token = new DecentralizedResistanceToken(1000000 * 10**18); // 1,000,000 tokens
        vm.startBroadcast(deployerPrivateKey);
        Voting challenge = new Voting(address(token), 86400);

        token.setVotingContract(address(challenge));

        console.logString(
            string.concat(
                "Challenge deployed at: ",
                vm.toString(address(challenge))
            )
        );
        vm.stopBroadcast();
        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }
    function test() public {}
}