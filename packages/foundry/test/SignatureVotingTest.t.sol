// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/SignatureVoting.sol";

contract SignatureVotingTest is Test {
    // Declare variables
    SignatureVoting public signatureVoting;

    // Create users' privateKeys
    // Need privateKeys to create wallets and to 'sign' messages
    uint256 onePk = 0x123;
    uint256 twoPk = 0x456;
    uint256 threePk = 0x789;

    // Create users' wallets
    address public userOne = vm.addr(onePk);
    address public userTwo = vm.addr(twoPk);
    address public userThree = vm.addr(threePk);

    // Create proposals
    string public proposalOne = "Everyone must wear red";
    string public proposalTwo = "Falafel Friday";
    string public proposalThree = "Water is a public right";

    // Create messages
    uint256 messageOne = 0;
    uint256 messageTwo = 1;
    uint256 messageThree = 2;

    // ToDo: Create messages
    bytes32 hashOne = keccak256(abi.encodePacked(messageOne));
    bytes32 hashTwo = keccak256(abi.encodePacked(messageTwo));
    bytes32 hashThree = keccak256(abi.encodePacked(messageThree));

    // Deploy contract and create proposals
    function setUp() public {
        signatureVoting = new SignatureVoting();
        signatureVoting.createProposal(proposalOne);
        signatureVoting.createProposal(proposalTwo);
        signatureVoting.createProposal(proposalThree);
    }

    // Test proposals were created
    function test_ProposalsCreated() public {
        assertEq(signatureVoting.getProposalName(0), proposalOne);
        assertEq(signatureVoting.getProposalName(1), proposalTwo);
        assertEq(signatureVoting.getProposalName(2), proposalThree);
    }

    // Voters sign message and call 'vote'
    function voterVotes() public {
        // Sign the message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(onePk, hashOne);
        // Pack the message
        bytes32 signedMessage = keccak256(abi.encodePacked(r, s, v));
        // Call smart contract
        signatureVoting.vote(signedMessage, hashOne, messageOne);
    }

    // Test that voters voted
    function test_voterVotedProposal0() public {
        assertTrue(signatureVoting.queryVoted(userOne, 0), "Voter did not vote for this proposal");
    }

    // Test for duplicate votes for single proposal
    function test_DuplicateVoting() public {
        vm.expectRevert(bytes("Voter already voted for this proposal!"));
        signatureVoting.queryVoted(userOne, messageOne);
    }
}