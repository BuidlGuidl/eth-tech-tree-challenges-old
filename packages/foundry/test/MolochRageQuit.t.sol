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
    uint256 public constant QUORUM = 2;
    uint256 public PROPOSAL_AMOUNT = 1 ether;
    uint256 public PROPOSAL_SHARES = 100;
    address public CONTRACT_ADDR = address(this);
    uint256 public PROPOSAL_ID = 1;
    bytes public addMemberdata =
        abi.encodeWithSignature("addMember(address)", member1, PROPOSAL_ID);
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
    event RageQuit(address member, uint256 shareAmount, uint256 ethAmount);
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event Voted(uint256 proposalId, address voter);

    function setUp() public {
        dao = new MolochRageQuit(QUORUM);
        // Fund members with some ETH for testing
        vm.deal(member1, INITIAL_ETH);
        vm.deal(member2, INITIAL_ETH);
    }
    // Test that the proposal is created and also emit event when created
    function testProposeCreation() public {
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

    //test should fail if msg.sender is not a member
    function testFailProposeCreation() public {
        vm.prank(nonMember1);
        dao.propose(address(dao), addMemberdata, PROPOSAL_AMOUNT, DEADLINE);
    }
}
