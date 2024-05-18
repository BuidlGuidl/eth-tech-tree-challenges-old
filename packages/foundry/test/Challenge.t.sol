// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Challenge} from "contracts/Challenge.sol";

contract ChallengeTest is Test {
    Challenge challenge;
    address public ALICE = makeAddr("alice");
    address public BOB = makeAddr("bob");
    uint256 public STREAM_CAP = 0.5 ether;
    uint256 public FREQUENCY = 2592000; // 30 days
    uint256 public STARTING_TIMESTAMP = 42000000069;

    event Withdraw(address indexed to, uint256 amount);
    event AddStream(address indexed to, uint256 amount);

    /**
     * Setup function is invoked before each test case is run to reduce redundancy
     * @notice Alice is given a stream, but Bob has no stream
     */
    function setUp() public {
        // Deploy the contract
        challenge = new Challenge();
        // Fund the contract
        (bool success, ) = payable(challenge).call{value: 10 ether}("");
        require(success, "Failed to send ether to challenge contract");
        // Pass time to simulate what its like to deploy on network that is not brand new
        vm.warp(STARTING_TIMESTAMP);
        // Add a stream for ALICE
        challenge.addStream(ALICE, STREAM_CAP);
    }

    /**
     * Ensure value for time until a stream is fully unlocked after a max withdrawal
     */
    function testFrequency() public {
        assertEq(challenge.i_frequency(), FREQUENCY);
    }

    /**
     * Stream contract should be able to receive ether
     */
    function testContractCanReceiveEther() public {
        (bool success, ) = payable(challenge).call{value: 1 ether}("");
        assert(success);
        assertEq(address(challenge).balance, 11 ether); // setup already funded contract with 10 ether
    }

    /**
     * Only the owner of stream contract is allowed to add a stream
     */
    function testNotOwnerCannotAddStream() public {
        vm.prank(BOB);
        vm.expectRevert("Ownable: caller is not the owner");
        challenge.addStream(ALICE, 333);
    }

    /**
     * Ensure stream can be added and that event is emitted
     */
    function testOwnerCanAddStream() public {
        vm.expectEmit(true, false, false, true);
        emit AddStream(ALICE, STREAM_CAP);
        challenge.addStream(ALICE, STREAM_CAP);
        Challenge.StreamConfig memory stream = challenge.getStream(ALICE);
        assertEq(stream.cap, STREAM_CAP);
        assertEq(stream.timeOfLastWithdrawal, 0); // stream has not been withdrawn from yet
    }

    /**
     * Test that accounts without a stream in the registry cannot withdraw
     */
    function testInvalidAccountCannotWithdraw() public {
        vm.prank(BOB);
        vm.expectRevert(Challenge.NoActiveStream.selector);
        challenge.maxWithdraw();
    }

    /**
     * Test that accounts with a stream in the registry can withdraw
     */
    function testValidAccountCanMaxWithdraw() public {
        vm.prank(ALICE);
        vm.expectEmit(true, false, false, true);
        emit Withdraw(ALICE, STREAM_CAP);
        challenge.maxWithdraw();
        uint256 aliceBalance = address(ALICE).balance;
        console.log("Alice's balance: ", aliceBalance);
        assertEq(aliceBalance, STREAM_CAP);
    }

    /**
     * An account that has recently withdrawn from stream should be able to withdraw partial cap before waiting the full frequency
     * @notice TODO WIP
     */
    function testValidAccountPartialWithdrawal() public {
        vm.prank(ALICE);
        challenge.maxWithdraw();
        vm.roll(10);
        uint256 timePassed = 100000000;
        vm.warp(STARTING_TIMESTAMP + timePassed);
        vm.prank(ALICE);
        challenge.maxWithdraw();
    }

    /**
     * Ensure unlocked stream amount is correct before a withdrawal
     */
    function testUnlockedAmountBeforeWithdraw() public {
        uint256 amount = challenge.unlockedAmount(ALICE);
        assertEq(amount, STREAM_CAP);
    }

    /**
     * Ensure view function reverts for invalid account
     */
    function testGetStreamForInvalidAccount() public {
        vm.prank(BOB);
        vm.expectRevert(Challenge.NoActiveStream.selector);
        challenge.getStream(BOB);
    }

    /**
     * Ensure view function returns correct stream config for a valid account
     */
    function testGetStreamForValidAccount() public {
        Challenge.StreamConfig memory stream = challenge.getStream(ALICE);
        assertEq(stream.cap, STREAM_CAP);
        assertEq(stream.timeOfLastWithdrawal, 0);
    }
}
