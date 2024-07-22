// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RebasingERC20 Challenge Contract
 * @author BUIDL GUIDL
 * @notice This challenge contract is meant to be an ERC-20 token with a rebasing mechanism to adjust total supply.
 * @dev The natspec is meant to be paired with the README.md to help guide you through this challenge! Goodluck!
 * @dev This smart contract is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 * Rebasing tokens automatically adjust its supply to target a specific price. Thus the token supply is increased or decreased periodically, where the effects are applied to all token holders, proportionally. Rebasing is an alternative price stabilization method versus traditional market mechanisms.
 * Thus, balanceOf() and token transferrance will report the real balance of a user, adjusted by rebasing effects.
 * @dev Minting new tokens is not handled via normal mint() functions, token balances are changed as per the rebasing logic implemented within this contract.
 */
contract RebasingERC20 is ERC20, Ownable {
    ///////////////////
    // Errors
    //////////////////
    /**
     * @notice Rebase cannot be zero.
     */
    error RebasingERC20__DeltaCannotBeZero();

    /**
     * @notice Rebase delta too high.
     */
    error RebasingERC20__AbsoluteDeltaTooHigh(int256 delta, uint256 maxDelta);

    /**
     * @notice Rebase delta not wholly-divisible & thus introduces rounding errors.
     */
    error RebasingERC20__DeltaNotWhollyDivisible(int256 delta);

    ///////////////////
    // State Variables
    //////////////////
    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;
    uint256 public _scalingFactor;
    uint256 public _initialSupply; 
    uint256 public maxDelta; // set once in the constructor.
    mapping(address => mapping(address => uint256)) public allowedRBT; // This is denominated in RBT, because the underlying "constituent points" conversion might change before it's fully paid.

    ///////////////////
    //  Events
    //////////////////
    /**
     * @dev Emitted when a rebase occurs.
     * @param totalSupply The new total supply of the token after the rebase.
     */
    event Rebase(uint256 totalSupply);

    /**
     * @notice Emitted when a burn occurs.
     * @param amount The tokens being burnt.
     */
    event Burn(address indexed sender, uint256 amount);

    ///////////////////
    //  Constructor
    //////////////////
    /**
     * @notice Sets Total Supply and Scaling Factor.
     * @dev Constructor that gives msg.sender all of the existing tokens.
     * @dev initialSupply is set to 1 million tokens with 18 decimals.
     */
    constructor() ERC20("RebasingToken", "RBT") {
        _initialSupply = 1000000e18;
        _scalingFactor = 1e18; // Initial scaling factor (1.0)
        _balances[msg.sender] = _initialSupply; // aka `_balances[msg.sender] = _initialSupply * (1e18) / _scalingFactor;`
        _totalSupply = _initialSupply;
        maxDelta = 25000e18;
    }

    ///////////////////
    //  Functions
    //////////////////
    /**
     * @notice Overridden `balanceOf()` function from ERC20.sol because rebasing token rebases using scaling factor in this contract.
     * @param account The address querying for its balance.
     * @return Number of tokens account has at this time.
     * Requirements:
     * - Return the balance of the requested account whilst taking into account the _scalingFactor & appropriate decimals.
     */
    function balanceOf(address account) public view override returns (uint256) {

    }

    function internalBalanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice Adjusts the total supply of the token and updates the scaling factor.
     * @param delta The amount to increase or decrease the total supply by. Remember that delta needs to be wrt 18 decimals & initial supply was 1 million tokens (1000000e18)
     * @return The new total supply of the token.
     * Requirements:
     * - Write conditional logic such that:
     *  - Simply revert with RebasingERC20__DeltaCannotBeZero if delta == 0
     *  - To prevent rounding errors, ensure that absolute delta doesn't exceed the maxDelta, and is wholly divisible by 10 ** 6
     *  - Increment _totalSupply based on delta being > or < 0
     *  - Calculate new _scalingFactor based on _totalSupply and _initialSupply()
     * - return _totalSupply
     * - emit `Rebase` event before returning _totalSupply
     */
    function rebase(int256 delta) external onlyOwner returns (uint256) {

    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowedRBT[owner][spender];
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
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

    }

    /**
     * @dev Carries out transferFrom() but with internal accounting in order to take into account _scalingFactor.
     * @param sender The address to transfer tokens from.
     * @param recipient The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the operation succeeded.
     * Requirements:
     * - Update `allowedRBT` mapping for sender and msg.sender
     * - Use the `_beforeTokenTransfer()` hook to handle the various ways that transfer is being called.
     * - Emit the Transfer event as per ERC20 standard.
     * - Return true if tx was successful.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * increaseAllowance and decreaseAllowance should be used instead.
     * Changing an allowance with this method brings the risk that someone may transfer both
     * the old and the new allowance - if they are both greater than zero - if a transfer
     * transaction is mined before the later approve() call is mined.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * Requirements:
     * - Update the `allowedRBT[msg.sender][spender]` value
     * - Emit the Approval event as per ERC20 standard.
     * - Return true if tx was successful.
     */
    function approve(address spender, uint256 value) public override returns (bool) {

    }

    /**
     * @dev Increase the amount of tokens that an owner has allowed to a spender.
     * This method should be used instead of approve() to avoid the double approval vulnerability
     * described above.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     * Requirements:
     * - Update the `allowedRBT[msg.sender][spender]` value
     * - Emit the Approval event as per ERC20 standard.
     * - Return true if tx was successful.'
     */
    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {

    }

    /**
     * @dev Decrease the amount of tokens that an owner has allowed to a spender.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     * Requirements:
     * - Update the `allowedRBT[msg.sender][spender]` value
     * - Emit the Approval event as per ERC20 standard.
     * - Return true if tx was successful.'
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {

    }

    function burn(uint256 amount) public {
        _beforeTokenTransfer(msg.sender, address(0), amount);
        emit Burn(msg.sender, amount);
    }

    ///////////////////
    //  Helper Functions
    //////////////////
    /**
     * @dev Hook that is called before any transfer of tokens. This includes burning.
     * @param from The address from which tokens are transferred.
     * @param to The address to which tokens are transferred.
     * @param amount The amount of tokens to be transferred.
     * Requirements
     * - Write conditional statement for burning, aka when to address is address(0)
     * - Finally handle if the sequence is just a transference of tokens.
     * - For all of the above, make sure to increase or decrease token balances whilst taking into account the _scalingFactor.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {

    }

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
