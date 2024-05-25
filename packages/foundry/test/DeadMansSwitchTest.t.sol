// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/DeadMansSwitch.sol";

contract DeadMansSwitchTest is Test {
    DeadMansSwitch public deadMansSwitch;
    address THIS_CONTRACT = address(this);
    address NON_CONTRACT_USER = vm.addr(1);
    address BENEFICIARY_1 = vm.addr(2);
    uint ONE_THOUSAND = 10 wei;
    uint INTERVAL = 1 weeks;

    // Setup the contract before each test
    function setUp() public {
        deadMansSwitch = new DeadMansSwitch();
    }

    // Test deposit functionality
    function testDeposit() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        assertEq(deadMansSwitch.getBalance(THIS_CONTRACT), ONE_THOUSAND);
    }

    // Test setting the check-in interval
    function testSetCheckInInterval() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        assertEq(deadMansSwitch.getCheckInInterval(THIS_CONTRACT), INTERVAL);
    }

    // Test the check-in functionality
    function testCheckIn() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.checkIn();
        assertEq(deadMansSwitch.getLastCheckIn(THIS_CONTRACT), block.timestamp);
    }

    // Test adding a beneficiary
    function testAddBeneficiary() public {
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        address[] memory beneficiaries = deadMansSwitch.getBeneficiaries(
            THIS_CONTRACT
        );
        assertEq(beneficiaries.length, 1);
        assertEq(beneficiaries[0], BENEFICIARY_1);
    }

    // // Test withdrawing funds by the user
    function testWithdraw() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.withdraw(ONE_THOUSAND);
        assertEq(deadMansSwitch.getBalance(THIS_CONTRACT), 0);
    }

    // Test withdrawing funds by a beneficiary after the interval has passed
    function testWithdrawAsBeneficiary() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(BENEFICIARY_1);
        deadMansSwitch.withdrawAsBeneficiary(THIS_CONTRACT);
        assertEq(deadMansSwitch.getBalance(THIS_CONTRACT), 0);
    }

    // Test that non-beneficiaries cannot withdraw funds
    function testWithdrawAsNonBeneficiary() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert("Caller is not a beneficiary");
        deadMansSwitch.withdrawAsBeneficiary(THIS_CONTRACT);
    }

    // Test that beneficiaries cannot withdraw funds before the interval has passed
    function testWithdrawAsBeneficiaryBeforeInterval() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.warp(block.timestamp + INTERVAL - 1);
        vm.startPrank(BENEFICIARY_1);
        vm.expectRevert("Check-in interval has not passed");
        deadMansSwitch.withdrawAsBeneficiary(THIS_CONTRACT);
    }

    // Test that the Deposit event is emitted correctly
    function testEmitDepositEvent() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.Deposit(THIS_CONTRACT, ONE_THOUSAND);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
    }

    // Test that the Withdrawal event is emitted correctly
    function testEmitWithdrawalEvent() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(BENEFICIARY_1);
        emit DeadMansSwitch.Withdrawal(THIS_CONTRACT, ONE_THOUSAND);
        deadMansSwitch.withdrawAsBeneficiary(THIS_CONTRACT);
    }

    // Test that the CheckIn event is emitted correctly
    function testEmitCheckInEvent() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckIn(THIS_CONTRACT, block.timestamp);
        deadMansSwitch.checkIn();
    }

    // Test that the BeneficiaryAdded event is emitted correctly
    function testEmitBeneficiaryAddedEvent() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.BeneficiaryAdded(THIS_CONTRACT, BENEFICIARY_1);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
    }

    // Test that the CheckInIntervalSet event is emitted correctly
    function testEmitCheckInIntervalSetEvent() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckInIntervalSet(THIS_CONTRACT, INTERVAL);
        deadMansSwitch.setCheckInInterval(INTERVAL);
    }
}
