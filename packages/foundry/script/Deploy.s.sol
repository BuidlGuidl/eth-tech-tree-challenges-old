//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/GovernanceToken.sol";
import "../contracts/GovernanceContract.sol";
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
        GovernanceToken govToken = new GovernanceToken("Governance Token", "GOV");
        console.logString(
            string.concat(
                "GovernanceToken deployed at: ",
                vm.toString(address(govToken))
            )
        );

        GovernanceContract govContract = new GovernanceContract(address(govToken), 5, 5);
        console.logString(
            string.concat(
                "GovernanceContract deployed at: ",
                vm.toString(address(govContract))
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