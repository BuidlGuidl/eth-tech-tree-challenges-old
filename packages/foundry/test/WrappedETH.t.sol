// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/WrappedETH.sol";

contract WrappedETHTest is Test {
    WrappedETH public wrappedETH;
    address THIS_CONTRACT = address(this);
    address NON_CONTRACT_USER = vm.addr(1);
    uint ONE_THOUSAND = 1000 wei;

    function setUp() public {
        wrappedETH = new WrappedETH();
    }

    function testDeposit() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), ONE_THOUSAND);
    }

    function testFallback() public {
        address(wrappedETH).call{value: ONE_THOUSAND}("");
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), ONE_THOUSAND);
    }

    function testWithdraw() public {
        vm.startPrank(NON_CONTRACT_USER);
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        wrappedETH.deposit{value: ONE_THOUSAND}();
        wrappedETH.withdraw(ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
        assertEq(address(wrappedETH).balance, 0);
        assertEq(NON_CONTRACT_USER.balance, ONE_THOUSAND);
    }

    function testWithdrawInsufficientBalance() public {
        vm.startPrank(NON_CONTRACT_USER);
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        wrappedETH.deposit{value: ONE_THOUSAND}();
        vm.expectRevert(bytes(abi.encodeWithSelector(WrappedETH.InsufficientWETHBalance.selector, NON_CONTRACT_USER, ONE_THOUSAND, ONE_THOUSAND + 1)));
        wrappedETH.withdraw(ONE_THOUSAND + 1);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), ONE_THOUSAND);
        assertEq(address(wrappedETH).balance, ONE_THOUSAND);
        assertEq(NON_CONTRACT_USER.balance, 0);
    }

    function testWithdrawFailedToSendEther() public {
        address CONTRACT_NOT_PAYABLE = vm.addr(3);
        vm.etch(CONTRACT_NOT_PAYABLE, "function() payable { revert(); }");
        vm.startPrank(CONTRACT_NOT_PAYABLE);
        vm.deal(CONTRACT_NOT_PAYABLE, ONE_THOUSAND);
        wrappedETH.deposit{value: ONE_THOUSAND}();
        vm.expectRevert(bytes(abi.encodeWithSelector(WrappedETH.FailedToSendEther.selector, CONTRACT_NOT_PAYABLE, ONE_THOUSAND)));
        wrappedETH.withdraw(ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(CONTRACT_NOT_PAYABLE), ONE_THOUSAND);
        assertEq(address(wrappedETH).balance, ONE_THOUSAND);
        assertEq(CONTRACT_NOT_PAYABLE.balance, 0);
    }

    function testTotalSupply() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        assertEq(wrappedETH.totalSupply(), ONE_THOUSAND);
    }

    function testApprove() public {
        wrappedETH.approve(NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.allowance(THIS_CONTRACT, NON_CONTRACT_USER), ONE_THOUSAND);
    }

    function testTransfer() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        wrappedETH.transfer(NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 0);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), ONE_THOUSAND);
    }

    function testTransferWithInsufficientBalance() public {
        wrappedETH.deposit{value: 999}();
        vm.expectRevert(bytes(abi.encodeWithSelector(WrappedETH.ERC20InsufficientBalance.selector, address(this), 999, ONE_THOUSAND)));
        wrappedETH.transfer(NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 999);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
    }

    function testTransferFrom() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        wrappedETH.approve(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 0);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), ONE_THOUSAND);
    }

    function testTransferFromAllowanceIsAdjusted() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        wrappedETH.approve(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 0);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), ONE_THOUSAND);
        assertEq(wrappedETH.allowance(THIS_CONTRACT, NON_CONTRACT_USER), 0);
    }

    function testTransferFromWithoutAllowance() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert(bytes(abi.encodeWithSelector(WrappedETH.ERC20InsufficientAllowance.selector, NON_CONTRACT_USER, 0, ONE_THOUSAND)));
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
    }

    function testTransferFromWithInsufficientAllowance() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        wrappedETH.approve(NON_CONTRACT_USER, 500);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert(bytes(abi.encodeWithSelector(WrappedETH.ERC20InsufficientAllowance.selector, NON_CONTRACT_USER, 500, ONE_THOUSAND)));
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
    }

    function testTransferFromWithInsufficientBalance() public {
        wrappedETH.deposit{value: 500}();
        wrappedETH.approve(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert(bytes(abi.encodeWithSelector(WrappedETH.ERC20InsufficientBalance.selector, address(this), 500, ONE_THOUSAND)));
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 500);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
    }

    function testTransferFromWithMaxAllowance() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        wrappedETH.approve(NON_CONTRACT_USER, type(uint256).max);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 0);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), ONE_THOUSAND);
    }

    function testEmitDepositEvent() public {
        vm.expectEmit(address(wrappedETH));
        emit WrappedETH.Deposit(THIS_CONTRACT, ONE_THOUSAND);
        wrappedETH.deposit{value: ONE_THOUSAND}();
    }

    function testEmitWithdrawalEvent() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.deposit{value: ONE_THOUSAND}();
        vm.expectEmit(address(wrappedETH));
        emit WrappedETH.Withdrawal(NON_CONTRACT_USER, ONE_THOUSAND);
        wrappedETH.withdraw(ONE_THOUSAND);
    }

    function testEmitTransferEvent() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        vm.expectEmit(address(wrappedETH));
        emit WrappedETH.Transfer(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        wrappedETH.transfer(NON_CONTRACT_USER, ONE_THOUSAND);
    }

    function testEmitApprovalEvent() public {
        vm.expectEmit(address(wrappedETH));
        emit WrappedETH.Approval(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        wrappedETH.approve(NON_CONTRACT_USER, ONE_THOUSAND);
    }

    function testEmitTransferEventOnTransferFrom() public {
        wrappedETH.deposit{value: ONE_THOUSAND}();
        wrappedETH.approve(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.expectEmit(address(wrappedETH));
        emit WrappedETH.Transfer(THIS_CONTRACT, NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.transferFrom(THIS_CONTRACT,NON_CONTRACT_USER, ONE_THOUSAND);
    }
}
