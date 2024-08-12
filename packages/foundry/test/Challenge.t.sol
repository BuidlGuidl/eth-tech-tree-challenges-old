// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/GovernanceToken.sol";
import "../contracts/GovernanceContract.sol";

/// @title Token-Vote-Delegation Tests
/// @author BUIDL GUIDL
/// @notice These tests will be used to autograde the challenge within the tech tree. This test file is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
contract ChallengeTest is Test {
    GovernanceToken governanceToken;
    GovernanceContract governanceContract;

    address owner = address(1);
    address delegatee = address(2);
    address voter1 = address(3);
    address voter2 = address(4);

    function setUp() public {
        vm.startPrank(owner);
        governanceToken = new GovernanceToken();
        governanceContract = new GovernanceContract(
            address(governanceToken),
            100 * 10 ** governanceToken.decimals(), // Proposal threshold
            200 * 10 ** governanceToken.decimals(), // Quorum
            100 // Voting period (blocks)
        );
        governanceToken.transfer(voter1, 200 * 10 ** governanceToken.decimals());
        governanceToken.transfer(voter2, 200 * 10 ** governanceToken.decimals());
        vm.stopPrank();
    }

    // GovernanceToken Tests

    function testTokenInitialization() public {
        assertEq(governanceToken.name(), "Governance Token");
        assertEq(governanceToken.symbol(), "GOV");
        assertEq(governanceToken.totalSupply(), 1000000 * 10 ** governanceToken.decimals());
        assertEq(governanceToken.balanceOf(owner), 1000000 * 10 ** governanceToken.decimals() - 400 * 10 ** governanceToken.decimals());
    }

    function testSuccessfulDelegation() public {
        vm.startPrank(voter1);
        governanceToken.delegate(delegatee);
        assertEq(governanceToken.delegates(voter1), delegatee);
        assertEq(governanceToken.delegatedVotes(delegatee), governanceToken.balanceOf(voter1));
        vm.stopPrank();
    }

    function testSelfDelegationReverts() public {
        vm.startPrank(voter1);
        vm.expectRevert(GovernanceToken.SelfDelegationNotAllowed.selector);
        governanceToken.delegate(voter1);
        vm.stopPrank();
    }

    function testSuccessfulUndelegation() public {
        vm.startPrank(voter1);
        governanceToken.delegate(delegatee);
        governanceToken.undelegate();
        assertEq(governanceToken.delegates(voter1), address(0));
        assertEq(governanceToken.delegatedVotes(delegatee), 0);
        vm.stopPrank();
    }

    function testNoDelegationToRevokeReverts() public {
        vm.startPrank(voter1);
        vm.expectRevert(GovernanceToken.NoDelegationToRevoke.selector);
        governanceToken.undelegate();
        vm.stopPrank();
    }

    function testMoveDelegatesFunction() public {
        vm.startPrank(voter1);
        
        governanceToken.delegate(delegatee);
        uint256 voter1Balance = governanceToken.balanceOf(voter1);
        assertEq(governanceToken.delegatedVotes(delegatee), voter1Balance, "Delegatee should receive votes equal to voter1's balance");
        governanceToken.undelegate();
        assertEq(governanceToken.delegatedVotes(delegatee), 0, "Delegatee should have 0 delegated votes after undelegation");
        assertEq(governanceToken.delegatedVotes(voter1), voter1Balance, "Voter1 should have same delegated votes after undelegation");
        assertEq(governanceToken.balanceOf(voter1), voter1Balance, "Voter1's balance should remain unchanged after delegation and undelegation");

        vm.stopPrank();
    }

    // GovernanceContract Tests

    function testGovernanceContractInitialization() public {
        assertEq(governanceContract.proposalThreshold(), 100 * 10 ** governanceToken.decimals());
        assertEq(governanceContract.quorum(), 200 * 10 ** governanceToken.decimals());
        assertEq(governanceContract.votingPeriod(), 100);
    }

    function testSuccessfulProposalCreation() public {
        vm.startPrank(voter1);

        uint256 deadline = block.number + 50;
        governanceContract.createProposal(deadline, "Proposal 1");
        assertEq(governanceContract.proposalCount(), 1);
        (uint256 id, address proposer,, uint256 endBlock,,,) = governanceContract.proposals(1);
        assertEq(id, 1);
        assertEq(proposer, voter1);
        assertEq(endBlock, deadline);
        vm.stopPrank();
    }

    function testProposalCreationRevertsNotEnoughVotes() public {
        vm.startPrank(delegatee);
        vm.expectRevert(GovernanceContract.NotEnoughVotes.selector);
        governanceContract.createProposal(block.number + 50, "Proposal 2");
        vm.stopPrank();
    }

    function testSuccessfulVoting() public {
        vm.startPrank(voter1);

        uint256 deadline = block.number + 50;
        governanceContract.createProposal(deadline, "Proposal 3");

        governanceContract.vote(1, true);
        (, , , , uint256 votesFor,,) = governanceContract.proposals(1);
        assertEq(votesFor, governanceToken.balanceOf(voter1));
        vm.stopPrank();
    }

    function testVotingRevertsVotingPeriodEnded() public {
        vm.startPrank(voter1);

        uint256 deadline = block.number + 1;
        governanceContract.createProposal(deadline, "Proposal 4");

        vm.roll(block.number + 2);
        vm.expectRevert(GovernanceContract.VotingPeriodEnded.selector);
        governanceContract.vote(1, true);
        vm.stopPrank();
    }

    function testVotingRevertsAlreadyVoted() public {
        vm.startPrank(voter1);

        uint256 deadline = block.number + 50;
        governanceContract.createProposal(deadline, "Proposal 5");

        governanceContract.vote(1, true);
        vm.expectRevert(GovernanceContract.AlreadyVoted.selector);
        governanceContract.vote(1, true);
        vm.stopPrank();
    }

    function testVotingRevertsNoVotesAvailable() public {
        vm.startPrank(voter1);
        uint256 deadline = block.number + 50;
        governanceContract.createProposal(deadline, "Proposal Test");
        vm.stopPrank();
        vm.startPrank(delegatee);
        vm.expectRevert(GovernanceContract.NotEnoughVotes.selector);
        governanceContract.vote(1, true);
        vm.stopPrank();
    }

    function testSuccessfulProposalResult() public {
        vm.startPrank(voter1);

        uint256 deadline = block.number + 50;
        governanceContract.createProposal(deadline, "Proposal 6");

        governanceContract.vote(1, true);
        vm.roll(block.number + 51);

        bool result = governanceContract.proposalResult(1);
        assertTrue(result);
        vm.stopPrank();
    }

    function testProposalResultRevertsVotingPeriodNotEnded() public {
        vm.startPrank(voter1);

        uint256 deadline = block.number + 50;
        governanceContract.createProposal(deadline, "Proposal 7");

        governanceContract.vote(1, true);
        vm.expectRevert(GovernanceContract.VotingPeriodNotEnded.selector);
        governanceContract.proposalResult(1);
        vm.stopPrank();
    }

    function testProposalResultRevertsQuorumNotReached() public {
        vm.startPrank(owner);
            governanceContract.setQuorum(300 * 10 ** governanceToken.decimals());
        vm.stopPrank();

        vm.startPrank(voter1);
        uint256 deadline = block.number + 50;
        governanceContract.createProposal(deadline, "Proposal 8");

        governanceContract.vote(1, true);
        vm.roll(block.number + 51);

        vm.expectRevert(GovernanceContract.QuorumNotReached.selector);
        governanceContract.proposalResult(1);
        vm.stopPrank();
    }

    function testMultipleDelegations() public {
        vm.startPrank(voter1);
        governanceToken.delegate(delegatee);
        governanceToken.undelegate();
        governanceToken.delegate(voter2);
        assertEq(governanceToken.delegates(voter1), voter2);
        assertEq(governanceToken.delegatedVotes(voter2), governanceToken.balanceOf(voter1));
        vm.stopPrank();
    }

    function testDelegationToAddressZero() public {
        vm.startPrank(voter1);
        governanceToken.delegate(address(0));
        assertEq(governanceToken.delegates(voter1), address(0));
        assertEq(governanceToken.delegatedVotes(address(0)), 0);
        vm.stopPrank();
    }

    function testMultipleProposals() public {
        vm.startPrank(voter1);

        uint256 deadline1 = block.number + 50;
        uint256 deadline2 = block.number + 50;

        governanceContract.createProposal(deadline1, "Proposal 9");
        governanceContract.createProposal(deadline2, "Proposal 10");

        governanceContract.vote(1, true);
        governanceContract.vote(2, false);

        vm.roll(block.number + 51);

        bool result1 = governanceContract.proposalResult(1);
        bool result2 = governanceContract.proposalResult(2);

        assertTrue(result1);
        assertFalse(result2);
        vm.stopPrank();
    }

    function testScenarioUserDelegatesVotesCreatesProposalAndVotes() public {
        vm.startPrank(voter1);
        governanceToken.delegate(delegatee);
        uint256 deadline = block.number + 50;
        governanceContract.createProposal(deadline, "Proposal 11");

        vm.stopPrank();

        vm.startPrank(delegatee);
        governanceContract.vote(1, true);
        vm.stopPrank();

        vm.roll(block.number + 51);

        vm.startPrank(voter1);
        bool result = governanceContract.proposalResult(1);
        assertTrue(result);
        vm.stopPrank();
    }

}
