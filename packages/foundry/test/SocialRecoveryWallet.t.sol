// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/SocialRecoveryWallet.sol";

contract SocialRecoveryWalletTest is Test {
    SocialRecoveryWallet public socialRecoveryWallet;

    address alice = makeAddr("alice");

    address guardian0 = makeAddr("guardian0");
    address guardian1 = makeAddr("guardian1");
    address guardian2 = makeAddr("guardian2");
    address guardian3 = makeAddr("guardian3");

    address[] chosenGuardianList = [guardian0, guardian1, guardian2, guardian3];

    uint256 threshold = 3;

    address newOwner = makeAddr("newOwner");

    function setUp() public {
        socialRecoveryWallet = new SocialRecoveryWallet(chosenGuardianList, threshold);
        vm.deal(address(socialRecoveryWallet), 1 ether);
    }

    function testConstructorSetsGaurdians() public {
        assertTrue(socialRecoveryWallet.isGuardian(guardian0));
        assertTrue(socialRecoveryWallet.isGuardian(guardian1));
        assertTrue(socialRecoveryWallet.isGuardian(guardian2));

        address nonGuardian = makeAddr("nonGuardian");
        assertFalse(socialRecoveryWallet.isGuardian(nonGuardian));
    }

    function testConstructorSetsThreshold() public {
        assertEq(socialRecoveryWallet.threshold(), threshold);
    }

    function testCanSendEth() public {
        uint256 initialValue = alice.balance;

        address recipient = alice;
        uint256 amountToSend = 1000;

        socialRecoveryWallet.sendEth(recipient, amountToSend);

        assertEq(alice.balance, initialValue + amountToSend);
    }

    function testCantSendIfNotOwner() public {
        uint256 initialValue = alice.balance;

        address recipient = alice;
        uint256 amountToSend = 1000;

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__NotOwner.selector)));
        vm.prank(alice);
        socialRecoveryWallet.sendEth(recipient, amountToSend);

        assertEq(alice.balance, initialValue);
    }

    function testCantSendIfInRecovery() public {
        vm.prank(guardian0);
        socialRecoveryWallet.initiateRecovery(newOwner);

        assertTrue(socialRecoveryWallet.inRecovery());

        address recipient = alice;
        uint256 amountToSend = 1000;

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__WalletInRecovery.selector)));
        socialRecoveryWallet.sendEth(recipient, amountToSend);
    }

    function testCanOnlyInitiateRecoveryIfGuardian() public {
        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__NotGuardian.selector)));
        vm.prank(alice);
        socialRecoveryWallet.initiateRecovery(alice);
    }

    function testInitiateRecoveryEmitsEvent() public {
        vm.expectEmit();
        emit SocialRecoveryWallet.RecoveryInitiated(guardian0, newOwner);

        vm.prank(guardian0);
        socialRecoveryWallet.initiateRecovery(newOwner);
    }

    function testInitiateRecoveryPutsWalletIntoRecovery() public {
        assertFalse(socialRecoveryWallet.inRecovery());

        vm.prank(guardian0);
        socialRecoveryWallet.initiateRecovery(newOwner);

        assertTrue(socialRecoveryWallet.inRecovery());
    }

    function testCanOnlySupportRecoveryIfGuardian() public {
        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__NotGuardian.selector)));
        address nonGuardian = makeAddr("nonGuardian");
        vm.prank(nonGuardian);
        socialRecoveryWallet.supportRecovery(newOwner);
    }

    function testCanOnlySupportIfWalletIsInRecovery() public {
        assertEq(socialRecoveryWallet.inRecovery(), false);

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__WalletNotInRecovery.selector)));
        vm.prank(guardian0);
        socialRecoveryWallet.supportRecovery(newOwner);
    }

    function testCanOnlySupportRecoveryOnce() public {
        vm.prank(guardian0);
        socialRecoveryWallet.initiateRecovery(newOwner);

        vm.prank(guardian1);
        socialRecoveryWallet.supportRecovery(newOwner);

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__AlreadyVoted.selector)));
        vm.prank(guardian1);
        socialRecoveryWallet.supportRecovery(newOwner);
    }

    function testSupportRecoveryEmitsEvent() public {
        vm.prank(guardian0);
        socialRecoveryWallet.initiateRecovery(newOwner);

        vm.expectEmit();
        emit SocialRecoveryWallet.RecoverySupported(guardian1, newOwner);

        vm.prank(guardian1);
        socialRecoveryWallet.supportRecovery(newOwner);
    }

    function testSupportRecoveryChangesOwnerOnceThresholdMet() public {
        assertEq(socialRecoveryWallet.threshold(), 3);
        assertEq(socialRecoveryWallet.owner(), address(this));

        vm.prank(guardian0);
        socialRecoveryWallet.initiateRecovery(newOwner);

        vm.prank(guardian1);
        socialRecoveryWallet.supportRecovery(newOwner);

        vm.prank(guardian2);
        socialRecoveryWallet.supportRecovery(newOwner);

        assertEq(socialRecoveryWallet.owner(), newOwner);
    }

    function testSupportRecoveryEmitsEventWhenRecoveryExecuted() public {
        vm.prank(guardian0);
        socialRecoveryWallet.initiateRecovery(newOwner);

        vm.prank(guardian1);
        socialRecoveryWallet.supportRecovery(newOwner);

        vm.expectEmit();
        emit SocialRecoveryWallet.RecoveryExecuted(newOwner);

        vm.prank(guardian2);
        socialRecoveryWallet.supportRecovery(newOwner);
    }
}
