// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/MolochRageQuit.sol";

contract MolochRageQuitTest is Test {
    MolochRageQuit public dao;
    address public owner = address(this);
    address public member1 = vm.addr(1);
    address public member2 = vm.addr(2);
    address public nonMember = vm.addr(3);
    uint256 public constant INITIAL_ETH = 1000 ether;
    uint256 public constant QUORUM = 2;
    uint256 public PROPOSAL_AMOUNT = 1 ether;
    uint256 public PROPOSAL_SHARES = 100;

    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        uint256 ethAmount,
        uint256 shareAmount
    );
    event ProposalApproved(uint256 proposalId, address approver);
    event SharesExchanged(
        address proposer,
        uint256 ethAmount,
        uint256 shareAmount
    );
    event RageQuit(address member, uint256 shareAmount, uint256 ethAmount);
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event Voted(uint256 proposalId, address voter);
    function setUp() public {
        dao = new MolochRageQuit(QUORUM);
        // Fund members with some ETH for testing
        vm.deal(member1, INITIAL_ETH);
        vm.deal(member2, INITIAL_ETH);
        dao.addMember(member1);
        dao.addMember(member2);
    }

    //Test that the proposal is created
    function testPropose() public {
        vm.prank(member1);
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

        (, uint256 ethAmount, , , ) = dao.proposals(1);
        assertEq(ethAmount, PROPOSAL_AMOUNT);
    }

    //Test revert if ethAmount and shareAmount are 0
    function testErrorInvalidSharesAmount() public {
        vm.prank(member1);
        vm.expectRevert(InvalidSharesAmount.selector);
        dao.propose(0, PROPOSAL_SHARES);
    }
    //Test that the ProposalCreated event is emitted
    function testEmitsProposalCreated() public {
        vm.prank(member1);
        vm.expectEmit(true, true, true, true);
        emit ProposalCreated(1, member1, PROPOSAL_AMOUNT, PROPOSAL_SHARES);
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);
    }

    //Test that the proposal is voted
    function testVote() public {
        vm.prank(member1);
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

        vm.prank(member1);
        dao.vote(1);

        (, , , uint256 votes, ) = dao.proposals(1);
        assertEq(votes, 1);
    }
    //Test revert if proposal does not exist
    function testErrorProposalNotFound() public {
        vm.prank(member1);
        vm.expectRevert(ProposalNotFound.selector);
        dao.vote(1);
    }
    //Test revert if member as already voted
    function testErrorAlreadyVoted() public {
        vm.prank(member1);
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

        vm.prank(member1);
        dao.vote(1);

        vm.prank(member1);
        vm.expectRevert(AlreadyVoted.selector);
        dao.vote(1);
    }
    //Test that the Voted event is emitted
    function testEmitsVoted() public {
        vm.startPrank(member1);
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);
        vm.expectEmit(true, true, true, true);
        emit Voted(1, member1);
        dao.vote(1);
        vm.stopPrank();
    }

    //Test that the ProposalApproved event is emitted
    function testEmitsProposalApproved() public {
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

        dao.vote(1);
        vm.startPrank(member1);
        vm.expectEmit(true, true, true, true);
        emit ProposalApproved(1, member1);
        dao.vote(1);
        vm.stopPrank();
    }

    //Test revert ProposalNotApproved if the proposal owner is not the mssg.sender and if the proposal was not approved
    function testErrorProposalNotApproved() public {
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);
        vm.startPrank(member1);
        vm.expectRevert(ProposalNotApproved.selector);
        dao.exchangeShares{value: PROPOSAL_AMOUNT}(1);
        vm.stopPrank();
    }

    //Test that the shares are exchanged
    function testExchangeShares() public {
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);
        dao.vote(1);

        vm.prank(member1);
        dao.vote(1);
        vm.expectEmit(true, true, true, true);
        emit SharesExchanged(owner, PROPOSAL_AMOUNT, PROPOSAL_SHARES);
        dao.exchangeShares{value: PROPOSAL_AMOUNT}(1);

        assertEq(dao.totalEth(), PROPOSAL_AMOUNT);
        assertEq(dao.totalShares(), PROPOSAL_SHARES);
        assertEq(dao.shares(owner), PROPOSAL_SHARES);
    }

    //Test revert InsufficientETH if the amount of ETH sent does not match the proposal's ETH amount
    function testErrorInsufficientETH() public {
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);
        dao.vote(1);

        vm.prank(member1);
        dao.vote(1);
        vm.expectRevert(InsufficientETH.selector);
        dao.exchangeShares{value: 0.5 ether}(1);
    }

    // function testRageQuit() public {
    //     vm.prank(member1);
    //     dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

    //     vm.prank(member1);
    //     dao.vote(1);

    //     vm.prank(member1);
    //     dao.exchangeShares{value: PROPOSAL_AMOUNT}(1);

    //     uint256 initialBalance = member1.balance;

    //     vm.prank(member1);
    //     dao.rageQuit();

    //     assertEq(dao.totalEth(), 0);
    //     assertEq(dao.totalShares(), 0);
    //     assertEq(dao.shares(member1), 0);
    //     assertEq(member1.balance, initialBalance + PROPOSAL_AMOUNT);

    //     vm.expectEmit(true, true, true, true);
    //     emit RageQuit(member1, PROPOSAL_SHARES, PROPOSAL_AMOUNT);
    //     dao.rageQuit();
    // }

    // function testAddMember() public {
    //     vm.prank(owner);
    //     dao.addMember(nonMember);

    //     assertTrue(dao.members(nonMember));

    //     vm.expectEmit(true, true, true, true);
    //     emit MemberAdded(nonMember);
    //     dao.addMember(nonMember);
    // }

    // function testRemoveMember() public {
    //     vm.prank(owner);
    //     dao.removeMember(member1);

    //     assertFalse(dao.members(member1));

    //     vm.expectEmit(true, true, true, true);
    //     emit MemberRemoved(member1);
    //     dao.removeMember(member1);
    // }

    // function testOnlyMemberCanApprove() public {
    //     vm.prank(member1);
    //     dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

    //     vm.prank(nonMember);
    //     vm.expectRevert(UnauthorizedAccess.selector);
    //     dao.vote(1);
    // }

    // function testInsufficientETH() public {
    //     vm.prank(member1);
    //     dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

    //     vm.prank(member1);
    //     dao.vote(1);

    //     vm.prank(member1);
    //     vm.expectRevert(InsufficientETH.selector);
    //     dao.exchangeShares{value: 0.5 ether}(1);
    // }

    // function testInvalidSharesAmount() public {
    //     vm.prank(member1);
    //     vm.expectRevert(InvalidSharesAmount.selector);
    //     dao.propose(0, PROPOSAL_SHARES);
    // }

    // function testProposalNotApproved() public {
    //     vm.prank(member1);
    //     dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

    //     vm.prank(member1);
    //     vm.expectRevert(ProposalNotApproved.selector);
    //     dao.exchangeShares{value: PROPOSAL_AMOUNT}(1);
    // }

    // function testReentrancyDetected() public {
    //     // Not possible to simulate reentrancy attack with forge tests directly
    //     // This test is just to show that reentrancy guard is in place
    //     vm.prank(member1);
    //     dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

    //     vm.prank(member1);
    //     dao.vote(1);

    //     vm.prank(member1);
    //     dao.exchangeShares{value: PROPOSAL_AMOUNT}(1);

    //     vm.prank(member1);
    //     dao.rageQuit(); // This should pass because reentrancy is prevented by nonReentrant modifier
    // }

    // function testAlreadyVoted() public {
    //     vm.prank(member1);
    //     dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);

    //     vm.prank(member1);
    //     dao.vote(1);

    //     vm.prank(member1);
    //     vm.expectRevert(AlreadyVoted.selector);
    //     dao.vote(1);
    // }

    // function testMemberExists() public {
    //     vm.prank(owner);
    //     dao.addMember(member1);

    //     vm.expectRevert(MemberExists.selector);
    //     dao.addMember(member1);
    // }

    // function testProposalNotFound() public {
    //     vm.prank(member1);
    //     vm.expectRevert(ProposalNotFound.selector);
    //     dao.vote(1);
    // }
}
