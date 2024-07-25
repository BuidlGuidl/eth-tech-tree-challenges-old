// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {EthStreaming} from "../contracts/EthStreaming.sol";

contract EthStreamingTest is Test {
    EthStreaming ethStreaming;
    address public ALICE = makeAddr("alice");
    address public BOB = makeAddr("bob");
    uint256 public STREAM_CAP = 0.5 ether;
    uint256 public FREQUENCY = 2592000; // 30 days
    uint256 public STARTING_TIMESTAMP = 42000000069;
    uint256 public STARTING_BALANCE = 3 ether;

    /**
     * Setup function is invoked before each test case is run to reduce redundancy
     * @notice Alice is given a stream, but Bob has no stream to start
     */
    function setUp() public {
        // Deploy the contract
        ethStreaming = new EthStreaming(FREQUENCY);
        // Fund the contract
        (bool success, ) = payable(ethStreaming).call{value: STARTING_BALANCE}(
            ""
        );
        require(success, "Failed to send ether to ethStreaming contract");
        // Pass time to simulate what its like to deploy on network that is not brand new
        vm.warp(STARTING_TIMESTAMP);
        // Add a stream for ALICE
        ethStreaming.addStream(ALICE, STREAM_CAP);
    }

    /**
     * Ensure value for time until a stream is fully unlocked after a max withdrawal
     */
    function testFrequency() public {
        assertEq(ethStreaming.FREQUENCY(), FREQUENCY);
    }

    /**
     * Stream contract should be able to receive ether and emit a `EthReceived` event
     */
    function testContractCanReceiveEther() public {
        address sender = address(this); // For foundry test env, the sender is the test contract itself
        uint256 amount = 1 ether;
        vm.expectEmit(true, false, false, true);
        emit EthStreaming.EthReceived(sender, amount); // test contract
        (bool success, ) = payable(ethStreaming).call{value: amount}("");
        assert(success);
        assertEq(address(ethStreaming).balance, STARTING_BALANCE + amount);
    }

    /**
     * Only the owner of stream contract is allowed to add a stream
     */
    function testNotOwnerCannotAddStream() public {
        vm.prank(BOB);
        vm.expectRevert("Ownable: caller is not the owner");
        ethStreaming.addStream(ALICE, 333);
    }

    /**
     * Ensure stream can be added and that event is emitted
     */
    function testOwnerCanAddStream() public {
        vm.expectEmit(true, false, false, true);
        emit EthStreaming.AddStream(ALICE, STREAM_CAP);
        ethStreaming.addStream(ALICE, STREAM_CAP);
        EthStreaming.StreamConfig memory stream = ethStreaming.getStream(ALICE);
        assertEq(stream.cap, STREAM_CAP);
        assertEq(stream.timeOfLastWithdrawal, 0); // stream has not been withdrawn from yet
    }

    /**
     * Ensure error thrown when trying to withdraw more than contract balance
     */
    function testWithdrawCannotExceedBalance() public {
        uint256 amount = STARTING_BALANCE + 1 ether;
        ethStreaming.addStream(BOB, amount);
        vm.expectRevert(EthStreaming.InsufficentFunds.selector);
        vm.prank(BOB);
        ethStreaming.maxWithdraw();
    }

    /**
     * Test that accounts without a stream in the registry cannot withdraw
     */
    function testInvalidAccountCannotWithdraw() public {
        vm.prank(BOB);
        vm.expectRevert(EthStreaming.NoActiveStream.selector);
        ethStreaming.maxWithdraw();
    }

    /**
     * Test that accounts with a stream in the registry can withdraw
     */
    function testValidAccountCanWithdraw() public {
        vm.prank(ALICE);
        vm.expectEmit(true, false, false, true);
        emit EthStreaming.Withdraw(ALICE, STREAM_CAP);
        ethStreaming.maxWithdraw();
        uint256 aliceBalance = address(ALICE).balance;
        assertEq(aliceBalance, STREAM_CAP);
    }

    /**
     * An account that has recently withdrawn from stream should be able to withdraw partial cap before waiting the full frequency
     */
    function testValidAccountPartialWithdrawal() public {
        vm.prank(ALICE);
        ethStreaming.maxWithdraw();
        uint aliceBalanceBefore = address(ALICE).balance;
        vm.roll(10);
        uint256 timePassed = 100000000;
        vm.warp(STARTING_TIMESTAMP + timePassed);
        vm.prank(ALICE);
        ethStreaming.maxWithdraw();
        uint aliceBalanceAfter = address(ALICE).balance;
        assertGt(aliceBalanceAfter, aliceBalanceBefore);
    }

    /**
     * Ensure unlocked stream amount is correct before a withdrawal
     */
    function testUnlockedAmountBeforeWithdraw() public {
        uint256 amount = ethStreaming.unlockedAmount(ALICE);
        assertEq(amount, STREAM_CAP);
    }

    /**
     * Ensure view function reverts for invalid account
     */
    function testGetStreamForInvalidAccount() public {
        vm.prank(BOB);
        vm.expectRevert(EthStreaming.NoActiveStream.selector);
        ethStreaming.getStream(BOB);
    }

    /**
     * Ensure view function returns correct stream config for a valid account
     */
    function testGetStreamForValidAccount() public {
        EthStreaming.StreamConfig memory stream = ethStreaming.getStream(ALICE);
        assertEq(stream.cap, STREAM_CAP);
        assertEq(stream.timeOfLastWithdrawal, 0);
    }
}
