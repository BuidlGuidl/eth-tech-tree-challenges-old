// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/SignatureVoting.sol";

contract ChallengeTest is Test {
    // Declare variables
    SignatureVoting public signatureVoting;

    // Create users' privateKeys
    // Need privateKeys to 'sign' messages
    uint256 onePk = 1;
    uint256 twoPk = 2;
    uint256 threePk = 3;

    // Create users
    address public userOne = vm.addr(onePk);
    address public userTwo = vm.addr(twoPk);
    address public userThree = vm.addr(threePk);

    // Create proposals
    string public proposalOne = "Everyone must wear red";
    string public proposalTwo = "No tacos allowed";
    string public proposalThree = "Water is a public right";

    // Users sign messages, they can also send the transaction, however it's not required
    // ToDo: Create messages
    bytes32 hashOne = keccak256("Signed by One");
    bytes32 hashTwo = keccak256("Signed by Two");
    bytes32 hashThree = keccak256("Signed by Three");

    // ToDo: Sign messages
    


    // Deploy contract, no constructor
    // Create proposals
    function setUp() public {
        signatureVoting = new SignatureVoting();
        signatureVoting.createProposal(proposalOne);
        signatureVoting.createProposal(proposalTwo);
        signatureVoting.createProposal(proposalThree);

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
