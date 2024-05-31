// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/RebasingERC20.sol";
import "forge-std/Test.sol";

/**
 * @title Rebasing Token Challenge Auto-Grading Tests
 * @author BUIDL GUIDL
 * @notice These tests will be used to autograde the challenge within the tech tree. This test file is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 */
contract RebasingERC20Test is Test {
    RebasingERC20 token;
    // King of the Pirates
    address luffy;
    // World's Greatest Swordsman
    address zoro;

    function setUp() public {
        luffy = address(this);
        zoro = address(0x123);
        token = new RebasingERC20();
        token.transfer(zoro, 1000 * 10 ** token.decimals());
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000000 * 10 ** token.decimals());
        assertEq(token.balanceOf(luffy), 999000 * 10 ** token.decimals());
        assertEq(token.balanceOf(zoro), 1000 * 10 ** token.decimals());
    }

    function testTransfer() public {
        uint256 transferAmount = 500 * 10 ** token.decimals();
        token.transfer(zoro, transferAmount);
        assertEq(token.balanceOf(luffy), 998500 * 10 ** token.decimals());
        assertEq(token.balanceOf(zoro), 1500 * 10 ** token.decimals());
    }

    function testApproveAndTransferFrom() public {
        uint256 approveAmount = 500 * 10 ** token.decimals();
        uint256 transferAmount = 300 * 10 ** token.decimals();
        token.approve(zoro, approveAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount);

        // Simulate `transferFrom` by the zoro
        vm.prank(zoro);
        token.transferFrom(luffy, zoro, transferAmount);
        assertEq(token.balanceOf(luffy), 998700 * 10 ** token.decimals());
        assertEq(token.balanceOf(zoro), 1300 * 10 ** token.decimals());
        assertEq(token.allowance(luffy, zoro), approveAmount - transferAmount);
    }

    function testRebasePositive() public {
        uint256 epoch = 1;
        int256 supplyDelta = int256(100000 * 10 ** token.decimals());
        uint256 oldTotalSupply = token.totalSupply();

        token.rebase(epoch, supplyDelta);
        uint256 newTotalSupply = token.totalSupply();

        assertEq(newTotalSupply, oldTotalSupply + uint256(supplyDelta));
        assertEq(token.balanceOf(luffy), 999000 * 10 ** token.decimals() * (newTotalSupply) / oldTotalSupply);
        assertEq(token.balanceOf(zoro), (1000 * 10 ** token.decimals() * newTotalSupply) / oldTotalSupply);
    }

    function testRebaseNegative() public {
        uint256 epoch = 1;
        int256 supplyDelta = -int256(100000 * 10 ** token.decimals());
        uint256 oldTotalSupply = token.totalSupply();

        token.rebase(epoch, supplyDelta);
        uint256 newTotalSupply = token.totalSupply();

        assertEq(newTotalSupply, oldTotalSupply - uint256(-supplyDelta));
        assertEq(token.balanceOf(luffy), (999000  * 10 ** token.decimals() * newTotalSupply) / oldTotalSupply);
        assertEq(token.balanceOf(zoro), (1000  * 10 ** token.decimals() * newTotalSupply) / oldTotalSupply);
    }
}
