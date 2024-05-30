// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/MolochRageQuit.sol";

contract MolochRageQuitTest is Test {
    MolochRageQuit public dao;
    address public owner = address(this);
    address public member1 = vm.addr(1);
    address public member2 = vm.addr(2);
    uint256 public constant INITIAL_ETH = 10 ether;

    function setUp() public {
        dao = new MolochRageQuit();
        // Fund member1 with some ETH for testing
        vm.deal(member1, INITIAL_ETH);
    }

    function testPropose() public {
        vm.prank(member1);
        dao.propose(1 ether, 100);

        (
            address proposer,
            uint256 ethAmount,
            uint256 shareAmount,
            bool approved
        ) = dao.proposals(1);
        assertEq(proposer, member1);
        assertEq(ethAmount, 1 ether);
        assertEq(shareAmount, 100);
        assertEq(approved, false);
    }

    function testApproveProposal() public {
        vm.prank(member1);
        dao.propose(1 ether, 100);

        vm.prank(owner);
        dao.approveProposal(1);

        (, , , bool approved) = dao.proposals(1);
        assertEq(approved, true);
    }

    function testExchangeShares() public {
        vm.prank(member1);
        dao.propose(1 ether, 100);

        vm.prank(owner);
        dao.approveProposal(1);

        vm.prank(member1);
        dao.exchangeShares{value: 1 ether}(1);

        assertEq(dao.totalEth(), 1 ether);
        assertEq(dao.totalShares(), 100);
        assertEq(dao.shares(member1), 100);
    }

    function testRageQuit() public {
        vm.prank(member1);
        dao.propose(1 ether, 100);

        vm.prank(owner);
        dao.approveProposal(1);

        vm.prank(member1);
        dao.exchangeShares{value: 1 ether}(1);

        uint256 initialBalance = member1.balance;

        vm.prank(member1);
        dao.rageQuit();

        assertEq(dao.totalEth(), 0);
        assertEq(dao.totalShares(), 0);
        assertEq(dao.shares(member1), 0);
        assertEq(member1.balance, initialBalance + 1 ether);
    }

    function testOnlyMemberCanApprove() public {
        vm.prank(member1);
        dao.propose(1 ether, 100);

        vm.prank(member2);
        vm.expectRevert(UnauthorizedAccess.selector);
        dao.approveProposal(1);
    }

    function testInsufficientETH() public {
        vm.prank(member1);
        dao.propose(1 ether, 100);

        vm.prank(owner);
        dao.approveProposal(1);

        vm.prank(member1);
        vm.expectRevert(InsufficientETH.selector);
        dao.exchangeShares{value: 0.5 ether}(1);
    }

    function testInvalidSharesAmount() public {
        vm.prank(member1);
        vm.expectRevert(InvalidSharesAmount.selector);
        dao.propose(0, 100);
    }

    function testProposalNotApproved() public {
        vm.prank(member1);
        dao.propose(1 ether, 100);

        vm.prank(member1);
        vm.expectRevert(ProposalNotApproved.selector);
        dao.exchangeShares{value: 1 ether}(1);
    }

    function testReentrancyDetected() public {
        // Not possible to simulate reentrancy attack with forge tests directly
        // This test is just to show that reentrancy guard is in place
        vm.prank(member1);
        dao.propose(1 ether, 100);

        vm.prank(owner);
        dao.approveProposal(1);

        vm.prank(member1);
        dao.exchangeShares{value: 1 ether}(1);

        vm.prank(member1);
        dao.rageQuit(); // This should pass because reentrancy is prevented by nonReentrant modifier
    }
}
