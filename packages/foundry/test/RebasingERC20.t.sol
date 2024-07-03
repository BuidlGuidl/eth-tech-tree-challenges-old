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
     * @notice Emitted when a burn occurs.
     * @param amount The tokens being burnt.
     */
    event Burn(address indexed sender, uint256 amount);


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
        token = new RebasingERC20();
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

    function testTransferFromAllTokens() public {
        uint256 approveAmount = token.balanceOf(zoro);
        vm.prank(zoro);
        vm.expectEmit(true, true, false, true);
        emit Approval(zoro, luffy, approveAmount);
        token.approve(luffy, approveAmount);
        assertEq(token.allowedRBT(zoro, luffy), approveAmount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(zoro, luffy, approveAmount);
        token.transferFrom(zoro, luffy, approveAmount);
        assertEq(token.balanceOf(zoro), 0);
        assertEq(token.balanceOf(luffy), luffyBalance1 + zoroBalance1);
    }

    function testTransferAllTokens() public {
        uint256 approveAmount = token.balanceOf(zoro);
        vm.startPrank(zoro);
        vm.expectEmit(true, true, false, true);
        emit Transfer(zoro, luffy, approveAmount);
        token.transfer(luffy, approveAmount);
        assertEq(token.balanceOf(zoro), 0);
        assertEq(token.balanceOf(luffy), luffyBalance1 + zoroBalance1);
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

    function testRebaseNegative() public {
        int256 supplyDelta = -24000e18;
        uint256 absSupplyDelta = abs(supplyDelta);
        uint256 oldTotalSupply = token.totalSupply();
        uint256 expectedTotalSupply =  oldTotalSupply - absSupplyDelta;
        vm.expectEmit(true, false, false, true);
        emit Rebase(expectedTotalSupply);
        token.rebase(supplyDelta);
        uint256 newTotalSupply = token.totalSupply();

        assertEq(newTotalSupply, oldTotalSupply - absSupplyDelta);
        assertEq(token.balanceOf(luffy), luffyBalance1 * (newTotalSupply) / oldTotalSupply);
        assertEq(token.balanceOf(zoro), (zoroBalance1 * newTotalSupply) / oldTotalSupply);
    }
    
    /**
     * Rebase
     * Transfer
     * Check balanceOf is updated properly
     */
    function testTransferAfterRebase(uint256 transferAmount) public {
        transferAmount = bound(transferAmount, 1e18, 10000e18);
        int256 supplyDelta = 24000e18;
        token.transfer(zoro, transferAmount);

        token.rebase(supplyDelta);

        token.transfer(zoro, transferAmount);

        // check that balances are updated properly taking into account scalingFactor by first checking the internal, then the ultimate, balances against manual calcs.

        // check that internal balances are updated properly
        // calculate expected internal balance
        // compare against reported internal balance
        uint256 newScalingFactor = token._scalingFactor();
        uint256 expectedLuffyInternalBalance = (luffyBalance1 - transferAmount) - (transferAmount * 1e18 / newScalingFactor);
        uint256 expectedZoroInternalBalance = (zoroBalance1 + transferAmount) + (transferAmount * 1e18 / newScalingFactor);
        
        uint256 expectedLuffyBalance = ((luffyBalance1 - transferAmount) - (transferAmount * 1e18 / newScalingFactor)) * newScalingFactor / 1e18;
        uint256 expectedZoroBalance = ((zoroBalance1 + transferAmount) + (transferAmount * 1e18 / newScalingFactor)) * newScalingFactor / 1e18;

        assertEq(token.internalBalanceOf(luffy), expectedLuffyInternalBalance);
        assertEq(token.internalBalanceOf(zoro), expectedZoroInternalBalance);
        assertEq(token.balanceOf(luffy), expectedLuffyBalance);
        assertEq(token.balanceOf(zoro), expectedZoroBalance);
    }

    function testTransferFromAfterRebase(uint256 transferAmount) public {
        transferAmount = bound(transferAmount, 1e18, 10000e18);
        int256 supplyDelta = 24000e18;
        token.transfer(zoro, transferAmount);

        token.rebase(supplyDelta);

        uint256 approveAmount = 10000e18;
        token.approve(zoro, approveAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount);
        vm.prank(zoro);
        token.transferFrom(luffy, zoro, transferAmount);

        // check that balances are updated properly taking into account scalingFactor by first checking the internal, then the ultimate, balances against manual calcs.

        // check that internal balances are updated properly
        // calculate expected internal balance
        // compare against reported internal balance
        uint256 newScalingFactor = token._scalingFactor();

        uint256 expectedLuffyInternalBalance = (luffyBalance1 - transferAmount) - (transferAmount * 1e18 / newScalingFactor);
        uint256 expectedZoroInternalBalance = (zoroBalance1 + transferAmount) + (transferAmount * 1e18 / newScalingFactor);
        
        uint256 expectedLuffyBalance = ((luffyBalance1 - transferAmount) - (transferAmount * 1e18 / newScalingFactor)) * newScalingFactor / 1e18;
        uint256 expectedZoroBalance = ((zoroBalance1 + transferAmount) + (transferAmount * 1e18 / newScalingFactor)) * newScalingFactor / 1e18;

        assertEq(token.internalBalanceOf(luffy), expectedLuffyInternalBalance);
        assertEq(token.internalBalanceOf(zoro), expectedZoroInternalBalance);
        assertEq(token.balanceOf(luffy), expectedLuffyBalance);
        assertEq(token.balanceOf(zoro), expectedZoroBalance);
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

    function testRebaseTooHigh() public {
        int256 supplyDelta = 26000e18;        
        vm.expectRevert(bytes(abi.encodeWithSelector(RebasingERC20.RebasingERC20__AbsoluteDeltaTooHigh.selector, supplyDelta, 25000e18)));
        token.rebase(supplyDelta);
    }

    // Should allow higher approvals to go through.
    function testIncreaseAllowanceAboveOwnerBalance() public {
        uint256 approveAmount = 500 * 10 ** token.decimals();
        token.approve(zoro, approveAmount);
        token.increaseAllowance(zoro, luffyBalance1*2);
    }

    function testDecreaseAllowanceBelowZero() public {
        uint256 approveAmount = 500 * 10 ** token.decimals();
        token.approve(zoro, approveAmount);
        token.decreaseAllowance(zoro, luffyBalance1);
        assertEq(token.allowance(luffy, zoro), 0);
    }

    // Try rebasing with zero
    // Try to rebase with not-wholly divisible value
    function testRebaseBadSupplyDelta() public {
        vm.expectRevert(bytes(abi.encodeWithSelector(RebasingERC20.RebasingERC20__DeltaCannotBeZero.selector)));
        token.rebase(0);
        int256 badDelta = (10 ** 6) + 1;
        vm.expectRevert(bytes(abi.encodeWithSelector(RebasingERC20.RebasingERC20__DeltaNotWhollyDivisible.selector, badDelta)));
        token.rebase(badDelta);
    }
    
    function testBurn(uint256 amount) public {
        // user burns their tokens
        // check that _balances[user] has changed
        // " that _totalSupply has decreased
        // check that _scalingFactor has changed too
        vm.startPrank(luffy);
        amount = bound(amount, 1e18, 10e18);
        vm.expectEmit(true, false, false, true);
        emit Burn(luffy, amount);
        token.burn(amount);
        vm.stopPrank();

        uint256 newTotalSupply = token._totalSupply();
        uint256 newScalingFactor = token._scalingFactor();
        assertEq(token.balanceOf(luffy), ((luffyBalance1 - amount) * newScalingFactor) / 1e18);
        assertEq(newTotalSupply, 1000000e18 - amount);
        assertEq(token._scalingFactor(), (1e18) * newTotalSupply / initialBalance);
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
