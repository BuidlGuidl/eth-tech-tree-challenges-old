// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/MolochRageQuit.sol";

contract MolochRageQuitTest is Test {
    MolochRageQuit public dao;
    address public member1 = vm.addr(1);
    address public member2 = vm.addr(2);
    address public nonMember1 = vm.addr(3);
    address public nonMember2 = vm.addr(4);
    uint256 public constant INITIAL_ETH = 1000 ether;
    uint256 public constant QUORUM = 1;
    uint256 public PROPOSAL_AMOUNT = 1 ether;
    uint256 public PROPOSAL_SHARES = 100;
    address public CONTRACT_ADDR = address(this);
    uint256 public PROPOSAL_ID = 1;
    bytes public addMemberdata =
        abi.encodeWithSignature(
            "addMember(address,uint256)",
            member1,
            PROPOSAL_ID
        );
    bytes public removMemberdata =
        abi.encodeWithSignature("removeMember(address)", member1);
    uint256 public DEADLINE = block.timestamp + 1 days;
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address contractAddr,
        bytes data,
        uint256 value,
        uint256 deadline
    );
    event ProposalApproved(uint256 proposalId, address approver);
    event RageQuit(address member, uint256 shareAmount);
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 proposalId);
    event ProposalValueRefunded(address proposer, uint256 amount);

    function setUp() public {
        dao = new MolochRageQuit(QUORUM);
        vm.deal(member1, INITIAL_ETH);
        vm.deal(member2, INITIAL_ETH);
    }

    function testProposalCreation() public {
        vm.expectEmit(true, true, true, true);
        emit ProposalCreated(
            1,
            CONTRACT_ADDR,
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );

        (, , , uint256 value, , uint256 deadline, ) = dao.proposals(1);
        assertEq(value, PROPOSAL_AMOUNT);
        assertEq(deadline, DEADLINE);
    }

    function testProposalAddressZero() public {
        vm.expectRevert(
            abi.encodeWithSelector(MolochRageQuit__ZeroAddress.selector)
        );
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(0),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
    }

    function testInvalidProposalDeadline() public {
        vm.expectRevert(
            abi.encodeWithSelector(MolochRageQuit__InvalidDeadline.selector)
        );
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            block.timestamp - 1
        );
    }

    function testProposalAmount() public {
        vm.expectRevert(
            abi.encodeWithSelector(MolochRageQuit__InsufficientETH.selector)
        );
        dao.propose{value: 0}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
    }

    function testProposalExists() public {
        vm.expectRevert(
            abi.encodeWithSelector(MolochRageQuit__ProposalNotFound.selector)
        );
        dao.vote(PROPOSAL_ID);
    }

    function testMemberCanVote() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        dao.vote(PROPOSAL_ID);
        (, , , , uint256 votes, , ) = dao.proposals(PROPOSAL_ID);
        assertEq(votes, 1);
    }

    function testMemberCanOnlyVoteOnce() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        dao.vote(PROPOSAL_ID);
        vm.expectRevert(
            abi.encodeWithSelector(MolochRageQuit__AlreadyVoted.selector)
        );
        dao.vote(PROPOSAL_ID);
    }

    function testNonMembersCannotVote() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        vm.prank(nonMember1);
        vm.expectRevert(
            abi.encodeWithSelector(MolochRageQuit__NotAMamber.selector)
        );
        dao.vote(PROPOSAL_ID);
    }

    function testProposalExecution() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );

        (, , , uint256 value, , , ) = dao.proposals(1);
        assertEq(value, PROPOSAL_AMOUNT);
        vm.expectEmit(true, true, true, true);
        emit ProposalApproved(PROPOSAL_ID, CONTRACT_ADDR);
        dao.vote(PROPOSAL_ID);
        vm.warp(block.timestamp + 2 days);
        vm.expectEmit(true, true, true, true);
        emit MemberAdded(member1);
        dao.executeProposal(PROPOSAL_ID);
    }

    function testAddMember() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        dao.vote(PROPOSAL_ID);
        vm.warp(block.timestamp + 2 days);
        vm.expectEmit(true, true, true, true);
        emit MemberAdded(member1);
        dao.executeProposal(PROPOSAL_ID);
        assertTrue(dao.members(member1));
    }

    function testDeadlineNotReached() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                MolochRageQuit__ProposalDeadlineNotReached.selector
            )
        );
        dao.executeProposal(PROPOSAL_ID);
    }

    function testProposalRejectedAndAmountRefunded() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        vm.warp(block.timestamp + 2 days);
        vm.expectEmit(true, true, true, true);
        emit ProposalValueRefunded(CONTRACT_ADDR, PROPOSAL_AMOUNT);
        dao.executeProposal(PROPOSAL_ID);
    }

    function testProposalAlreadyVotedEvent() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        dao.vote(PROPOSAL_ID);
        vm.expectRevert(
            abi.encodeWithSelector(MolochRageQuit__AlreadyVoted.selector)
        );
        dao.vote(PROPOSAL_ID);
    }

    function testRemoveMember() public {
        dao.propose{value: PROPOSAL_AMOUNT}(
            address(dao),
            addMemberdata,
            PROPOSAL_AMOUNT,
            DEADLINE
        );
        dao.vote(PROPOSAL_ID);
        vm.warp(block.timestamp + 2 days);
        dao.executeProposal(PROPOSAL_ID);
        assertTrue(dao.members(member1));
        dao.propose(address(dao), removMemberdata, 0, block.timestamp + 1 days);
        uint256 proposalId = PROPOSAL_ID + 1;
        dao.vote(proposalId);
        vm.warp(block.timestamp + 2 days);
        vm.expectEmit(true, true, true, true);
        emit RageQuit(member1, PROPOSAL_AMOUNT);
        vm.expectEmit(true, true, true, true);
        emit MemberRemoved(member1);
        dao.executeProposal(proposalId);
        assertFalse(dao.members(member1));
    }

    receive() external payable {}
}
