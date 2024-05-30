//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/SocialRecoveryWallet.sol";
import "./DeployHelpers.s.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    address guardian0 = 0x0b3aA6f7e5be55E7012A8677779B41487B424F70;
    address guardian1 = 0x09F1E981Ac9c32D3E88819b0cE091Dc27f9cf857;
    address guardian2 = 0x62bA14f9BBAe5aF1fE4b4cA4339d9ee332750E3F;

    address[] chosenGuardianList = [guardian0, guardian1, guardian2];

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