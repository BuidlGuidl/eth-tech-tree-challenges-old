// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/SignatureVoting.sol";

contract ChallengeTest is Test {
    // Declare variables
    SignatureVoting public signatureVoting;

    // Create users
    address public userOne = address(0x123);
    address public userTwo = address(0x456);
    address public userThree = address(0x782);


    // Deploy contract, no constructor
    function setUp() public {
        signatureVoting = new SignatureVoting();
        signatureVoting.createProposal(); // need bytes32 data here
        
    }

    // Create proposals

    // Test that voters voted

    // Test for duplicate votes for single proposal


}
