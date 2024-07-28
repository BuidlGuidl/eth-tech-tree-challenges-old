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

    // Create proposals
    bytes32 public proposalOne = _placeholder;
    bytes32 public proposalTwo = _placeholder;
    bytes32 public proposalThree = _placeholder;

    // Users sign messages, they can also send the transaction, however it's not required
    // ToDo: Create messages

    // ToDo: Sign messages


    // Deploy contract, no constructor
    // Create proposals
    function setUp() public {
        signatureVoting = new SignatureVoting();
        signatureVoting.createProposal(proposalOne); // need bytes32 data here
        signatureVoting.createProposal(proposalTwo); // need bytes32 data here
        signatureVoting.createProposal(proposalThree); // need bytes32 data here

    }

    // Test initial proposals
    function testProposalsCreated() public {
        assertEq(signatureVoting.getProposalName(0), proposalOne);
        assertEq(signatureVoting.getProposalName(1), proposalTwo);
        assertEq(signatureVoting.getProposalName(2), proposalThree);
    }

    // Voters vote
    function testVotersVote() public {
        signatureVoting.vote(signedMessage, signature, proposalId);
    }

    // Test that voters voted
    function testVotersVoted() public {

    }

    // Test for duplicate votes for single proposal
    function testDuplicateVoting() public {

    }


}
