// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/RebasingERC20.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

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
    uint256 luffyBalance1;
    uint256 zoroBalance1;
    uint256 initialBalance;

    /**
     * @dev Emitted when a rebase occurs.
     * @param totalSupply The new total supply of the token after the rebase.
     */
    event Rebase(uint256 totalSupply);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);


    /**
     * Total Supply is set up to be 1 million RBT
     * Scaling Factor is 1e18
     * Luffy initial balance is 1 million RBT
     * Luffy transfers 1000 RBT to zoro
     * Records initial balances for Luffy and Zoro after setup
     */
    function setUp() public {
        luffy = address(this);
        zoro = address(0x123);
        token = new RebasingERC20(); // TODO - check logs to see if it is calling mint or not on the RBT! If it is, then keep the mint logic within the transfer stuff. If it isn't, then you can remove that, and the remove the README assumption #6
        token.transfer(zoro, 1000 * 10 ** token.decimals());
        luffyBalance1 = token.balanceOf(luffy);
        zoroBalance1 = token.balanceOf(zoro);
        initialBalance = 1000000 * 10 ** token.decimals();
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), initialBalance);
        assertEq(token.balanceOf(luffy), 999000 * 10 ** token.decimals());
        assertEq(token.balanceOf(zoro), 1000 * 10 ** token.decimals());
    }

    function testTransfer(uint256 transferAmount) public {
        transferAmount = bound(transferAmount, 1e18, 10000e18);
        token.transfer(zoro, transferAmount);
        assertEq(token.balanceOf(luffy), luffyBalance1 - transferAmount);
        assertEq(token.balanceOf(zoro), zoroBalance1 + transferAmount);
    }

    function testApproveAndTransferFrom() public {
        uint256 approveAmount = 500 * 10 ** token.decimals();
        uint256 transferAmount = 300 * 10 ** token.decimals();
        token.approve(zoro, approveAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount);

        // Simulate `transferFrom` by the zoro
        vm.prank(zoro);
        token.transferFrom(luffy, zoro, transferAmount);
        assertEq(token.balanceOf(luffy), luffyBalance1 - transferAmount);
        assertEq(token.balanceOf(zoro), zoroBalance1 + transferAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount - transferAmount);
    }

    function testTransferAllFrom() public {
        uint256 approveAmount = token.balanceOf(zoro);
        vm.prank(zoro);
        vm.expectEmit(true, true, false, true);
        emit Approval(zoro, luffy, approveAmount);
        token.approve(luffy, approveAmount);
        assertEq(token.allowedRBT(zoro, luffy), approveAmount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(zoro, luffy, approveAmount);
        token.transferAllFrom(zoro, luffy);
    }

    function testIncreaseAllowance() public {
        uint256 approveAmount = 500 * 10 ** token.decimals();
        uint256 transferAmount = 300 * 10 ** token.decimals();
        token.approve(zoro, approveAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount);
        token.increaseAllowance(zoro, transferAmount);
        assertEq(token.allowance(luffy, zoro), transferAmount + approveAmount);
    }

    function testDecreaseAllowance() public {
        uint256 approveAmount = 500 * 10 ** token.decimals();
        uint256 transferAmount = 300 * 10 ** token.decimals();
        token.approve(zoro, approveAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount);
        token.decreaseAllowance(zoro, transferAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount - transferAmount);
    }
    
    function testRebasePositive() public {
        int256 supplyDelta = 24000e18;
        uint256 absSupplyDelta = abs(supplyDelta);
        uint256 oldTotalSupply = token.totalSupply();
        uint256 expectedTotalSupply =  oldTotalSupply + absSupplyDelta;
        vm.expectEmit(true, false, false, true);
        emit Rebase(expectedTotalSupply);
        token.rebase(supplyDelta);
        uint256 newTotalSupply = token.totalSupply();

        assertEq(newTotalSupply, oldTotalSupply + absSupplyDelta);
        assertEq(token.balanceOf(luffy), luffyBalance1 * (newTotalSupply) / oldTotalSupply);
        assertEq(token.balanceOf(zoro), (zoroBalance1 * newTotalSupply) / oldTotalSupply);
    }

    // TODO THIS IS WHERE YOU LEFT OFF STEVE
    function testRebaseNegative() public {
        int256 supplyDelta = -int256(initialBalance);
        uint256 oldTotalSupply = token.totalSupply();
        uint256 expectedTotalSupply = oldTotalSupply - initialBalance;
        
        vm.expectEmit(true, false, false, true);
        emit Rebase(expectedTotalSupply);
        token.rebase(supplyDelta);
        uint256 newTotalSupply = token.totalSupply();

        assertEq(newTotalSupply, oldTotalSupply - uint256(-supplyDelta));
        assertEq(token.balanceOf(luffy), (luffyBalance1 * newTotalSupply) / oldTotalSupply);
        assertEq(token.balanceOf(zoro), (zoroBalance1 * newTotalSupply) / oldTotalSupply);
    }

    /**
     * Test that rounding errors don't arise
     */
    function testRoundingErrors() public {
        // Perform multiple small transfers to check for rounding errors
        uint256 transferAmount = 1 * 10 ** token.decimals(); // Small transfer amount
        uint256 numTransfers = 1000;

        for (uint256 i = 0; i < numTransfers; i++) {
            vm.prank(luffy);
            token.transfer(zoro, transferAmount);

            vm.prank(zoro);
            token.transfer(luffy, transferAmount);
        }

        // Check balances after multiple small transfers
        uint256 finalLuffyBalance = token.balanceOf(luffy);
        uint256 finalZoroBalance = token.balanceOf(zoro);

        // Check for rounding errors
        // TODO - check end resultant math
        assertEq(finalLuffyBalance, (token.totalSupply() - 1000 * 10 ** token.decimals()) * token._scalingFactor() / (1e18));
        assertEq(finalZoroBalance, ( 1000 * 10 ** token.decimals() * token._scalingFactor() / (1e18)));
    }

    /// TODO 
    function testTransferAfterRebase() public {

    }

    /// TODO 
    function testTransferFromAfterRebase() public {

    }

    function testMintNotOwner() public {
        
    }

    function testTransferAllFromAfterRebase() public {
        
    }




    // Not Happy Path Tests

    function testFailTransferInsufficientBalance() public {
        // User tries to transfer more tokens than they have
        vm.prank(zoro);
        vm.expectRevert();
        token.transfer(luffy, 2000 * 10 ** token.decimals());
    }

    function testRebaseNotOwner() public {
        // Non-owner tries to rebase the contract
        vm.prank(zoro);
        vm.expectRevert("Ownable: caller is not the owner");
        token.rebase(1000);
    }

    function testRebaseTooHigh() public {}

    function testIncreaseAllowanceAboveOwnerBalancer() public {

    }

    function testDecreaseAllowanceBelowZero() public {}

    function testTransferAllFromWhenUserHasZero() public {}

    function testFailRebaseBadSupplyDelta() public {
        // Owner tries to rebase the contract with a bad value for supplyDelta
        vm.startPrank(luffy);
        vm.expectRevert();
        token.rebase(type(int256).min);
        vm.stopPrank();
    }

    /// UNCERTAIN TESTS
    
    // TODO - SCOPE: do we want to update total supply when minting or burning occurs? If so, then we need to check that total supply is updated, and that scaling factor is updated.

    function testMint() public {

    }

    function testBurn() public {
        
    }

    /// Helper Functions

    function abs(int256 value) public pure returns (uint256) {
        // Check if the value is negative
        if (value < 0) {
            // Return the negated value as unsigned integer
            return uint256(-value);
        } else {
            // Return the value as unsigned integer
            return uint256(value);
        }
    }

    
}
