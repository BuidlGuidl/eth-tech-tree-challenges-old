// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/WrappedETH.sol";

contract WrappedETHTest is Test {
    WrappedETH public wrappedETH;
    address public userOne = address(0x123);

    function setUp() public {
        wrappedETH = new WrappedETH();
    }

    function testDeposit() public {
        wrappedETH.deposit{value: 1000}();
        assertEq(wrappedETH.balanceOf(address(this)), 1000);
    }

    function testFallback() public {
        address(wrappedETH).call{value: 1000}("");
        assertEq(wrappedETH.balanceOf(address(this)), 1000);
    }

    function testWithdraw() public {
        vm.startPrank(userOne);
        vm.deal(userOne, 1000);
        wrappedETH.deposit{value: 1000}();
        wrappedETH.withdraw(1000);
        assertEq(wrappedETH.balanceOf(userOne), 0);
        assertEq(wrappedETH.balanceOf(address(wrappedETH)), 0);
        assertEq(userOne.balance, 1000);
    }

    function testTotalSupply() public {
        wrappedETH.deposit{value: 1000}();
        assertEq(wrappedETH.totalSupply(), 1000);
    }

    function testApprove() public {
        wrappedETH.approve(vm.addr(2), 1000);
        assertEq(wrappedETH.allowance(address(this), vm.addr(2)), 1000);
    }

    function testTransfer() public {
        wrappedETH.deposit{value: 1000}();
        wrappedETH.transfer(vm.addr(2), 1000);
        assertEq(wrappedETH.balanceOf(address(this)), 0);
        assertEq(wrappedETH.balanceOf(vm.addr(2)), 1000);
    }

    function testTransferWithInsufficientBalance() public {
        wrappedETH.deposit{value: 999}();
        vm.expectRevert();
        wrappedETH.transfer(vm.addr(2), 1000);
        assertEq(wrappedETH.balanceOf(address(this)), 999);
        assertEq(wrappedETH.balanceOf(vm.addr(2)), 0);
    }

    function testTransferFrom() public {
        wrappedETH.deposit{value: 1000}();
        wrappedETH.approve(vm.addr(2), 1000);
        vm.startPrank(vm.addr(2));
        wrappedETH.transferFrom(address(this), vm.addr(2), 1000);
        assertEq(wrappedETH.balanceOf(address(this)), 0);
        assertEq(wrappedETH.balanceOf(vm.addr(2)), 1000);
    }

    function testTransferFromAllowanceIsAdjusted() public {
        wrappedETH.deposit{value: 1000}();
        wrappedETH.approve(vm.addr(2), 1000);
        vm.startPrank(vm.addr(2));
        wrappedETH.transferFrom(address(this), vm.addr(2), 1000);
        assertEq(wrappedETH.balanceOf(address(this)), 0);
        assertEq(wrappedETH.balanceOf(vm.addr(2)), 1000);
        assertEq(wrappedETH.allowance(address(this), vm.addr(2)), 0);
    }

    function testTransferFromWithoutAllowance() public {
        wrappedETH.deposit{value: 1000}();
        vm.startPrank(vm.addr(2));
        vm.expectRevert();
        wrappedETH.transferFrom(vm.addr(1), vm.addr(2), 1000);
        assertEq(wrappedETH.balanceOf(address(this)), 1000);
        assertEq(wrappedETH.balanceOf(vm.addr(2)), 0);
    }

    function testTransferFromWithInsufficientAllowance() public {
        wrappedETH.deposit{value: 1000}();
        wrappedETH.approve(vm.addr(2), 500);
        vm.startPrank(vm.addr(2));
        vm.expectRevert();
        wrappedETH.transferFrom(address(this), vm.addr(2), 1000);
        assertEq(wrappedETH.balanceOf(address(this)), 1000);
        assertEq(wrappedETH.balanceOf(vm.addr(2)), 0);
    }

    function testTransferFromWithInsufficientBalance() public {
        wrappedETH.deposit{value: 500}();
        wrappedETH.approve(vm.addr(2), 1000);
        vm.startPrank(vm.addr(2));
        vm.expectRevert();
        wrappedETH.transferFrom(address(this), vm.addr(2), 1000);
        assertEq(wrappedETH.balanceOf(address(this)), 500);
        assertEq(wrappedETH.balanceOf(vm.addr(2)), 0);
    }

    function testTransferFromWithMaxAllowance() public {
        wrappedETH.deposit{value: 1000}();
        wrappedETH.approve(vm.addr(2), type(uint256).max);
        vm.startPrank(vm.addr(2));
        wrappedETH.transferFrom(address(this), vm.addr(2), 1000);
        assertEq(wrappedETH.balanceOf(address(this)), 0);
        assertEq(wrappedETH.balanceOf(vm.addr(2)), 1000);
    }
}
