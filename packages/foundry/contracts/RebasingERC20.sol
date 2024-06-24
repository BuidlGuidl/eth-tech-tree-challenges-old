// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title RebasingERC20 Challenge Contract
 * @author BUIDL GUIDL
 * @notice This challenge contract is meant to be an ERC-20 token with a rebasing mechanism to adjust total supply.
 * @dev The natspec is meant to be paired with the README.md to help guide you through this challenge! Goodluck!
 * @dev This smart contract is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 * The coupon ERC20 can be redeemed for the rebasing underlying token. The redeem function has a requirement that the redemption transfers in coupon tokens. The coupon tokens then gets XYZ amount of underlying tokens to the user. Everytime a rebase happens, the underlying token totalSupply increases or decreases. 
 * The coupon token, upon redemptions, is burnt. The coupon token contract has the same onlyOwner as the rebasing token, and it owns the rebasing token? So that way, redemption calls have to be made through the coupon token. 
 * Redemptions are called on the RebasingToken contract itself. 
 * Upon redemptions, users get RBT, but then... there's some RBT out there in the wild. Rebases have to take this into account. There's always XYZ minted once it's minted. The scalingFactor is affected by the amountActuallyMinted. scalingFactor =  (1e18) * _totalSupply / _initialSupply; where totalSupply = oldTotalSupply +- supplyDelta, BUT supplyDelta must not cause totalSupply to LTE to amountActuallyMinted.
 * Thus, balanceOf() will report the real balance of a user
 * AND previewRedeem() will report estimated amount upon redemption. 
 */
contract RebasingERC20 is ERC20, Ownable {
    using SafeMath for uint256;

    /// Errors
    /**
     * @notice Sender requires enough ETH for the transaction.
     */
    error RebasingERC20__InsufficientBalance(address _sender, uint256 _amount);

    /**
     * @notice Cannot use bad _supplyDelta values in rebase.
     */
    error RebasingERC20__InvalidSupplyDelta(uint256 _supplyDelta);

    /// State Vars
    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;
    uint256 public _scalingFactor;
    uint256 public _initialSupply;
    /// Events

    /**
     * @dev Emitted when a rebase occurs.
     * @param totalSupply The new total supply of the token after the rebase.
     */
    event Rebase(uint256 totalSupply);

    /**
     * @notice Sets Total Supply and Scaling Factor.
     * @dev Constructor that gives msg.sender all of the existing tokens.
     */
    constructor() ERC20("RebasingToken", "RBT") {
        _totalSupply = 1000000 * 10 ** decimals();
        _scalingFactor = 1e18; // Initial scaling factor (1.0)
        _mint(msg.sender, _totalSupply);
        _initialSupply = _totalSupply;
    }

    /**
     * @notice Overridden `balanceOf()` function from ERC20.sol because rebasing token rebases using scaling factor in this contract.
     * @param account The address querying for its balance.
     * @return Number of tokens account has at this time.
     * Requirements:
     * - Return the balance of the requested account whilst taking into account the _scalingFactor & appropriate decimals.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account] * _scalingFactor / (1e18);
    }

    // function previewRedeem() public view returns (uint256) {

    // }

    /**
     * @notice Returns the total supply of the token.
     * @return The total supply of the token.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Adjusts the total supply of the token.
     * @param supplyDelta The amount to increase or decrease the total supply by.
     * @return The new total supply of the token.
     * Requirements:
     * - Simply return current _totalSupply if supplyDelta == 0
     * - Increment _totalSupply based on supplyDelta being > or < 0
     * - Calculate new _scalingFactor based on _totalSupply and _initialSupply()
     * - emit `Rebase` event
     * - return _totalSupply
     */
    function rebase(int256 supplyDelta) external onlyOwner returns (uint256) {
        if (supplyDelta == 0) {
            emit Rebase(_totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply -= uint256(-supplyDelta);
        } else {
            _totalSupply += uint256(supplyDelta);
        }

        _scalingFactor = (1e18) * _totalSupply / _initialSupply;

        emit Rebase(_totalSupply);
        return _totalSupply;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes minting and burning.
     * @param from The address from which tokens are transferred.
     * @param to The address to which tokens are transferred.
     * @param amount The amount of tokens to be transferred.
     * Requirements
     * - Write conditional statement for minting, aka when from address is address(0)
     * - Write conditional statement for burning, aka when to address is address(0)
     * - Finally handle if the sequence is just a transference of tokens.
     * - For all of the above, make sure to do the proper increase or decrease of token balances whilst taking into account the _scalingFactor.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        if (from == address(0)) {
            // Minting tokens
            _balances[to] += amount * (1e18) / _scalingFactor; // TODO - I think these should be `_balances[to] += amount * (1e18) * _scalingFactor;`
        } else if (to == address(0)) {
            // Burning tokens
            _balances[from] -= amount * (1e18) / _scalingFactor;
        } else {
            // Transfer between accounts
            _balances[from] -= amount * (1e18) / _scalingFactor;
            _balances[to] += amount * (1e18) / _scalingFactor;
        }
    }

    /**
     * @dev Transfers `amount` tokens from the caller's account to `recipient`.
     * @param recipient The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the operation succeeded.
     * Requirements:
     * - Use the `_beforeTokenTransfer()` hook to handle the various ways that transfer is being called.
     * - Emit the Transfer event as per ERC20 standard.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _beforeTokenTransfer(_msgSender(), recipient, amount);
        emit Transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Carries out transferFrom() but with internal accounting in order to take into account _scalingFactor.
     * @param sender The address to transfer tokens from.
     * @param recipient The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the operation succeeded.
     * Requirements:
     * - Use the `_beforeTokenTransfer()` hook to handle the various ways that transfer is being called.
     * - Approve the sender the appropriate amount.
     * - Emit the Transfer event as per ERC20 standard.
     * - Return whether or not the tx was successful.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _beforeTokenTransfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance(sender, _msgSender()) - amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
}
