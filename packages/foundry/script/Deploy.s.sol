//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/SocialRecoveryWallet.sol";
import "./DeployHelpers.s.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    address[] chosenGuardianList;

    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);

        SocialRecoveryWallet socialRecoveryWallet = new SocialRecoveryWallet(chosenGuardianList, 2);
        console.logString(
            string.concat(
                "SocialRecoveryWallet deployed at: ",
                vm.toString(address(socialRecoveryWallet))
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