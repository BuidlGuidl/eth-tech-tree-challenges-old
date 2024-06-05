// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/StdUtils.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/SocialRecoveryWallet.sol";

contract SocialRecoveryWalletTest is Test {
    SocialRecoveryWallet public socialRecoveryWallet;
    ERC20 public dai;

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
        dai = new ERC20("Dai", "DAI");
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

    function testCallRevertsWithCorrectError() public {
        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__CallFailed.selector)));
        socialRecoveryWallet.call(address(this), 0, "");
    }

    function testCallCanSendEth() public {
        uint256 initialValue = alice.balance;

        address recipient = alice;
        uint256 amountToSend = 1000;

        socialRecoveryWallet.call(recipient, amountToSend, "");

        assertEq(alice.balance, initialValue + amountToSend);
    }

    function testCantCallIfNotOwner() public {
        uint256 initialValue = alice.balance;

        address recipient = alice;
        uint256 amountToSend = 1000;

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__NotOwner.selector)));
        vm.prank(alice);
        socialRecoveryWallet.call(recipient, amountToSend, "");

        assertEq(alice.balance, initialValue);
    }

    function testCantCallIfInRecovery() public {
        vm.prank(guardian0);
        socialRecoveryWallet.initiateRecovery(newOwner);

        assertTrue(socialRecoveryWallet.inRecovery());

        address recipient = alice;
        uint256 amountToSend = 1000;

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__WalletInRecovery.selector)));
        socialRecoveryWallet.call(recipient, amountToSend, "");
    }

    function testCallCanExecuteExternalTransactions() public {
        // Sending an ERC20 for example
        deal(address(dai), address(socialRecoveryWallet), 500);
        assertEq(dai.balanceOf(alice), 0);

        socialRecoveryWallet.call(address(dai), 0, abi.encodeWithSignature("transfer(address,uint256)", alice, 500));
        assertEq(dai.balanceOf(alice), 500);
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

    function testAddGuardian() public {
        address newGuardian = makeAddr("newGuardian");
        uint256 original_num_guardians = socialRecoveryWallet.numGuardians();
        assertFalse(socialRecoveryWallet.isGuardian(newGuardian));

        vm.prank(socialRecoveryWallet.owner());
        socialRecoveryWallet.addGuardian(newGuardian);

        assertTrue(socialRecoveryWallet.isGuardian(newGuardian));
        assertEq(socialRecoveryWallet.numGuardians(), original_num_guardians + 1);

        // Try to add the same guardian again
        original_num_guardians = socialRecoveryWallet.numGuardians();
        vm.prank(socialRecoveryWallet.owner());
        socialRecoveryWallet.addGuardian(newGuardian);

        assertTrue(socialRecoveryWallet.isGuardian(newGuardian));
        assertEq(socialRecoveryWallet.numGuardians(), original_num_guardians);
    }

    function testCantAddGuardianIfNotOwner() public {
        address newGuardian = makeAddr("newGuardian");
        assertFalse(socialRecoveryWallet.isGuardian(newGuardian));

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__NotOwner.selector)));
        vm.prank(alice);
        socialRecoveryWallet.addGuardian(newGuardian);

        assertFalse(socialRecoveryWallet.isGuardian(newGuardian));
    }

    function testCantRemoveGuardianIfNotOwner() public {
        assertTrue(socialRecoveryWallet.isGuardian(guardian0));

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__NotOwner.selector)));
        vm.prank(alice);
        socialRecoveryWallet.removeGuardian(guardian0);

        assertTrue(socialRecoveryWallet.isGuardian(guardian0));
    }

    function testRemoveGuardian() public {
        assertTrue(socialRecoveryWallet.isGuardian(guardian0));

        vm.prank(socialRecoveryWallet.owner());
        socialRecoveryWallet.removeGuardian(guardian0);

        assertFalse(socialRecoveryWallet.isGuardian(guardian0));
    }

    function testCantSetThresholdIfNotOwner() public {
        uint256 newThreshold = 2;

        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__NotOwner.selector)));
        vm.prank(alice);
        socialRecoveryWallet.setThreshold(newThreshold);

        assertEq(socialRecoveryWallet.threshold(), threshold);
    }

    function testCantSetThresholdHigherThanNumGuardians() public {
        uint256 newThreshold = 5;

        vm.prank(socialRecoveryWallet.owner());
        vm.expectRevert(bytes(abi.encodeWithSelector(SocialRecoveryWallet.SocialRecoveryWallet__ThresholdTooHigh.selector)));
        socialRecoveryWallet.setThreshold(newThreshold);

        assertEq(socialRecoveryWallet.threshold(), threshold);
    }

    function testSetThreshold() public {
        uint256 newThreshold = 2;

        vm.prank(socialRecoveryWallet.owner());
        socialRecoveryWallet.setThreshold(newThreshold);

        assertEq(socialRecoveryWallet.threshold(), newThreshold);
    }
}
