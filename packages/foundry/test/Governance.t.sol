// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Governance.sol";
import "../contracts/DecentralizedResistanceToken.sol";

contract GovernanceTest is Test {
    DecentralizedResistanceToken public token;
    uint proposalId;
    Governance public governance;
    address public userOne = address(0x123);
    address public userTwo = address(0x456);
    address public userThree = address(0x782);
    address public userNonMember = address(0x789);

    function setUp() public {
        token = new DecentralizedResistanceToken(1000000 * 10 ** 18); // 1,000,000 tokens
        governance = new Governance(address(token), 86400); // 1 day voting period
        // Distribute tokens
        token.transfer(userOne, 1000 * 10 ** 18); // 1000 tokens to userOne
        token.transfer(userTwo, 2000 * 10 ** 18); // 2000 tokens to userTwo
        token.transfer(userThree, 3000 * 10 ** 18); // 3000 tokens to userThree
        proposalId = governance.propose("Basic Proposal");
    }

    function testInitialBalances() public {
        assertEq(token.balanceOf(address(this)), 994000 * 10 ** 18); // Deployer balance after distribution
        assertEq(token.balanceOf(userOne), 1000 * 10 ** 18); // userOne balance after distribution
        assertEq(token.balanceOf(userTwo), 2000 * 10 ** 18); // userTwo balance after distribution
        assertEq(token.balanceOf(userThree), 3000 * 10 ** 18); // userThree balance after distribution
    }

    function testProposal() public {
        vm.prank(userOne);
        uint pId = governance.propose("New Proposal");
        (,string memory title,,) = governance.proposals(pId);
        assertEq(title, "New Proposal");
    }

    function testProposalIDsAreUnique() public {
        vm.prank(userOne);
        uint pId = governance.propose("New Proposal");
        (,string memory title,,) = governance.proposals(pId);
        uint pId2 = governance.propose("New Proposal 2");
        (,string memory title2,,) = governance.proposals(pId2);
        assertEq(title, "New Proposal");
        assertEq(title2, "New Proposal 2");
        assertFalse(pId == pId2);
    }

    function testErrorNonMemberProposal() public {
        vm.prank(userNonMember);
        vm.expectRevert(UnAuthorized_MembersOnly.selector);
        governance.propose("Failing Proposal");
    }

    function testErrorNonMemberVoting() public {
        vm.prank(userNonMember);
        vm.expectRevert(UnAuthorized_MembersOnly.selector);
        governance.vote(proposalId, Choice.YEA);
    }

    function testVotingFor() public {
        vm.prank(userOne);
        governance.vote(proposalId, Choice.YEA);

        assertEq(governance.votesFor(proposalId), token.balanceOf(userOne));
        assertEq(governance.votesAgainst(proposalId), 0);
        assertEq(governance.votesAbstain(proposalId), 0);
        assertTrue(governance.hasVoted(proposalId, userOne));
    }

    function testVotingAgainst() public {
        vm.prank(userTwo);
        governance.vote(proposalId, Choice.NAY);

        assertEq(governance.votesFor(proposalId), 0);
        assertEq(governance.votesAgainst(proposalId), token.balanceOf(userTwo));
        assertEq(governance.votesAbstain(proposalId), 0);
        assertTrue(governance.hasVoted(proposalId, userTwo));
    }

    function testVotingAbstain() public {
        vm.prank(userThree);
        governance.vote(proposalId, Choice.ABSTAIN);

        assertEq(governance.votesFor(proposalId), 0);
        assertEq(governance.votesAgainst(proposalId), 0);
        assertEq(governance.votesAbstain(proposalId), token.balanceOf(userThree));
        assertTrue(governance.hasVoted(proposalId, userThree));
    }

    function testErrorDoubleVoting() public {
        vm.startPrank(userOne);
        governance.vote(proposalId, Choice.NAY);
        assertTrue(governance.hasVoted(proposalId, userOne));
        vm.expectRevert(DuplicateVoting.selector);
        governance.vote(proposalId, Choice.YEA);
        vm.stopPrank();
    }

    function testTieVotingResult() public {
        vm.prank(userThree);
        governance.vote(proposalId, Choice.YEA);
        vm.prank(userOne);
        governance.vote(proposalId, Choice.NAY);
        vm.prank(userTwo);
        governance.vote(proposalId, Choice.NAY);
        vm.warp(block.timestamp + 86400 + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, false);
    }

    function testVotingResultRejected() public {
        // 1000 for vs 2000 against
        vm.prank(userOne);
        governance.vote(proposalId, Choice.YEA);
        vm.prank(userTwo);
        governance.vote(proposalId, Choice.NAY);
        vm.warp(block.timestamp + 86400 + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, false);
    }

    function testVotingResultApproved() public {
        // 2000 for vs 1000 against
        vm.prank(userOne);
        governance.vote(proposalId, Choice.NAY);
        vm.prank(userTwo);
        governance.vote(proposalId, Choice.YEA);
        vm.warp(block.timestamp + 86400 + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, true);
    }

    function testErrorVoteAfterDeadline() public {
        // Try to vote after the voting deadline
        vm.warp(block.timestamp + 86400 + 1);
        vm.prank(userOne);
        vm.expectRevert(VotingPeriodOver.selector);
        governance.vote(proposalId, Choice.YEA);
    }

    function testErrorVoteInProgress() public {
        // Try to get result when vote is in progress
        vm.expectRevert(VotingInProgress.selector);
        governance.getResult(proposalId);
    }

}
