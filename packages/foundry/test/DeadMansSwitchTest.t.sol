// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/DeadMansSwitch.sol";

contract DeadMansSwitchTest is Test {
    DeadMansSwitch public deadMansSwitch;
    address THIS_CONTRACT = address(this);
    address NON_CONTRACT_USER = vm.addr(1);
    address BENEFICIARY_1 = vm.addr(2);
    uint ONE_THOUSAND = 1000 wei;
    uint INTERVAL = 1 weeks;

    // Setup the contract before each test
    function setUp() public {
        deadMansSwitch = new DeadMansSwitch();
    }

    // Test deposit functionality
    function testDeposit() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        (uint balance, , ) = deadMansSwitch.users(THIS_CONTRACT);
        assertEq(balance, ONE_THOUSAND);
    }

    // Test setting the check-in interval
    function testSetCheckInInterval() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        (, , uint checkInterval) = deadMansSwitch.users(THIS_CONTRACT);
        assertEq(checkInterval, INTERVAL);
    }

    // Test setting the check-in interval to 0
    function testSetCheckInIntervalWhenZero() public {
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.IntervalNotSet.selector)));
        deadMansSwitch.setCheckInInterval(0);
    }

    // Test the check-in functionality
    function testCheckIn() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.checkIn();
        (, uint lastCheckIn, ) = deadMansSwitch.users(THIS_CONTRACT);
        assertEq(lastCheckIn, block.timestamp);
    }

    // Test adding a beneficiary
    function testAddBeneficiary() public {
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        assertEq(
            deadMansSwitch.beneficiaryLookup(THIS_CONTRACT, BENEFICIARY_1),
            true
        );
    }

    // Test removing a beneficiary
    function testRemoveBeneficiary() public {
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        assertEq(
            deadMansSwitch.beneficiaryLookup(THIS_CONTRACT, BENEFICIARY_1),
            true
        );

        deadMansSwitch.removeBeneficiary(BENEFICIARY_1);
        assertEq(
            deadMansSwitch.beneficiaryLookup(THIS_CONTRACT, BENEFICIARY_1),
            false
        );
    }

    // Test removing a beneficiary
    function testRemoveBeneficiaryWhenBeneficiaryDoesntExist() public {
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.BeneficiaryDoesNotExist.selector)));
        deadMansSwitch.removeBeneficiary(BENEFICIARY_1);
    }

    // Test withdrawing funds by the user
    function testWithdraw() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.withdraw(ONE_THOUSAND);
        (uint balance, , ) = deadMansSwitch.users(THIS_CONTRACT);
        assertEq(balance, 0);
    }

    // Test withdrawing funds by the user
    function testWithdrawInsufficientBalance() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        (uint balance, , ) = deadMansSwitch.users(NON_CONTRACT_USER);
        assertEq(balance, ONE_THOUSAND);
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.InsufficientBalance.selector)));
        deadMansSwitch.withdraw(ONE_THOUSAND + 1);
        (uint balance2, , ) = deadMansSwitch.users(NON_CONTRACT_USER);
        assertEq(balance2, ONE_THOUSAND);
    }

    // Test withdrawing funds by the user
    function testWithdrawTransferFailed() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        (uint balance, , ) = deadMansSwitch.users(THIS_CONTRACT);
        assertEq(balance, ONE_THOUSAND);
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.TransferFailed.selector)));
        deadMansSwitch.withdraw(ONE_THOUSAND);
        (uint balance2, , ) = deadMansSwitch.users(THIS_CONTRACT);
        assertEq(balance2, ONE_THOUSAND);
    }

    // Test withdrawing funds by a beneficiary after the interval has passed
    function testWithdrawAsBeneficiary() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        assertEq(
            deadMansSwitch.beneficiaryLookup(THIS_CONTRACT, BENEFICIARY_1),
            true
        );
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(BENEFICIARY_1);
        uint initialBalance = address(BENEFICIARY_1).balance;
        deadMansSwitch.withdrawAsBeneficiary(THIS_CONTRACT);
        uint finalBalance = address(BENEFICIARY_1).balance;
        assertEq(finalBalance, initialBalance + ONE_THOUSAND);
        (uint balance, , ) = deadMansSwitch.users(THIS_CONTRACT);
        assertEq(balance, 0);
    }

        // Test withdrawing funds by a beneficiary that cannot receive ether
    function testWithdrawAsBeneficiaryTransferFailed() public {
        vm.deal(BENEFICIARY_1, ONE_THOUSAND);
        vm.startPrank(BENEFICIARY_1);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        // Adding THIS_CONTRACT as a beneficiary since it can't receive ether
        deadMansSwitch.addBeneficiary(THIS_CONTRACT);
        assertEq(
            deadMansSwitch.beneficiaryLookup(BENEFICIARY_1, THIS_CONTRACT),
            true
        );
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(THIS_CONTRACT);
        uint initialBalance = address(THIS_CONTRACT).balance;
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.TransferFailed.selector)));
        deadMansSwitch.withdrawAsBeneficiary(BENEFICIARY_1);
        uint finalBalance = address(THIS_CONTRACT).balance;
        assertEq(finalBalance, initialBalance);
        (uint balance, , ) = deadMansSwitch.users(BENEFICIARY_1);
        assertEq(balance, ONE_THOUSAND);
    }

    // Test that non-beneficiaries cannot withdraw funds
    function testWithdrawAsNonBeneficiary() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.UnauthorizedCaller.selector)));
        deadMansSwitch.withdrawAsBeneficiary(THIS_CONTRACT);
    }

    // Test that non-beneficiaries cannot withdraw funds before the interval has passed
    function testWithdrawAsNonBeneficiaryBeforeInterval() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        vm.warp(block.timestamp + INTERVAL - 1);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.CheckInNotLapsed.selector)));
        deadMansSwitch.withdrawAsBeneficiary(THIS_CONTRACT);
    }

    // Test that beneficiaries cannot withdraw funds before the interval has passed
    function testWithdrawAsBeneficiaryBeforeInterval() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.warp(block.timestamp + INTERVAL - 1);
        vm.startPrank(BENEFICIARY_1);
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.CheckInNotLapsed.selector)));
        deadMansSwitch.withdrawAsBeneficiary(THIS_CONTRACT);
    }

    //Test  if user is already a beneficiary
    function testAddBeneficiaryTwice() public {
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.BeneficiaryAlreadyExists.selector)));
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
    }

    //Test for zero address
    function testZeroAddress() public {
        vm.expectRevert(bytes(abi.encodeWithSelector(DeadMansSwitch.InvalidAddress.selector)));
        deadMansSwitch.addBeneficiary(address(0));
    }

    // Test that the Deposit event is emitted correctly
    function testEmitDepositEvent() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.Deposit(THIS_CONTRACT, ONE_THOUSAND);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
    }

    // Test that the Withdrawal event is emitted correctly
    function testEmitWithdrawalEvent() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        emit DeadMansSwitch.Withdrawal(THIS_CONTRACT, ONE_THOUSAND);
        deadMansSwitch.withdraw(ONE_THOUSAND);
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

    // Test removing a beneficiary
    function testEmitBeneficiaryRemovedEvent() public {
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.BeneficiaryRemoved(THIS_CONTRACT, BENEFICIARY_1);
        deadMansSwitch.removeBeneficiary(BENEFICIARY_1);
    }

    // Test that the CheckInIntervalSet event is emitted correctly
    function testEmitCheckInIntervalSetEvent() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckInIntervalSet(THIS_CONTRACT, INTERVAL);
        deadMansSwitch.setCheckInInterval(INTERVAL);
    }
}
