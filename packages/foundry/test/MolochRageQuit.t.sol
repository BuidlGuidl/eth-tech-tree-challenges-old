// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/MolochRageQuit.sol";

contract MolochRageQuitTest is Test {
    MolochRageQuit public dao;
    address public owner = address(this);
    address public member1 = vm.addr(1);
    address public member2 = vm.addr(2);
    address public nonMember1 = vm.addr(3);
    address public nonMember2 = vm.addr(4);
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
    event Withdrawal(address owner, uint256 amount);

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

    //Test that rage can be quited and the RageQuit event is emitted
    function testRageQuit() public {
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);
        dao.vote(1);
        vm.prank(member1);
        dao.vote(1);
        dao.exchangeShares{value: PROPOSAL_AMOUNT}(1);
        uint256 initialBalance = owner.balance;
        vm.expectEmit(true, true, true, true);
        emit RageQuit(owner, PROPOSAL_SHARES, PROPOSAL_AMOUNT);
        dao.rageQuit();
        assertEq(dao.totalEth(), 0);
        assertEq(dao.totalShares(), 0);
        assertEq(dao.shares(member1), 0);
        assertEq(owner.balance, initialBalance + PROPOSAL_AMOUNT);
    }

    //Test that the member is added and the MemberAdded event is emitted
    function testAddMember() public {
        dao.addMember(nonMember1);
        assertTrue(dao.members(nonMember1));
        vm.expectEmit(true, true, true, true);
        emit MemberAdded(nonMember2);
        dao.addMember(nonMember2);
    }
    //Test revert if the member already exists
    function testMemberExists() public {
        dao.addMember(nonMember1);
        vm.expectRevert(MemberExists.selector);
        dao.addMember(nonMember1);
    }

    //Test that removing of members is working and the MemberRemoved event is emitted
    function testRemoveMember() public {
        dao.removeMember(member1);
        assertFalse(dao.members(member1));
        vm.expectEmit(true, true, true, true);
        emit MemberRemoved(member2);
        dao.removeMember(member2);
    }

    //Test revert if user is not not added to the members
    function testOnlyMemberCanApprove() public {
        vm.prank(member1);
        dao.propose(PROPOSAL_AMOUNT, PROPOSAL_SHARES);
        vm.prank(nonMember1);
        vm.expectRevert(UnauthorizedAccess.selector);
        dao.vote(1);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
