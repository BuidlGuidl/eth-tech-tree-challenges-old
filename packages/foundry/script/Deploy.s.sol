//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/RebasingERC20.sol";
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
        vm.startBroadcast(deployerPrivateKey);
        RebasingERC20 rebasingERC20 = new RebasingERC20();
        console.logString(
            string.concat(
                "RebasingERC20 deployed at: ",
                vm.toString(address(rebasingERC20))
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
}