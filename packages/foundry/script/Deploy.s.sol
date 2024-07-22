//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/Multisend.sol";
import "./DeployHelpers.s.sol";
import "../contracts/MockToken.sol";

/**
 * @title DeployScript
 * @author BUIDL GUIDL
 * @notice Deploys Multisend contract, and mock tokens to deployer wallet (specified in .env) to troubleshoot with in the debug tab etc.
 */
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

        (address mockToken1, address mockToken2) = deployMockTokens();

        Multisend multisend = new Multisend();
        console.logString(
            string.concat(
                "Multisend Challenge deployed at: ",
                vm.toString(address(multisend))
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

    /**
     * @notice Creates mock tokens for the pool and mints 1000 of each to the deployer wallet
     */
    function deployMockTokens() internal returns (address, address) {
        MockToken scUSD = new MockToken("Scaffold USD", "scUSD");
        MockToken scDAI = new MockToken("Scaffold DAI", "scDAI");

        return (address(scDAI), address(scUSD));
    }
}