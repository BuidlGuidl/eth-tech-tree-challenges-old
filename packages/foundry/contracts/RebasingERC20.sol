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
 */
contract RebasingERC20 is ERC20, Ownable {

    /// Errors

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

    /// State Vars

    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;
    uint256 public _scalingFactor;
    uint256 public _initialSupply; 
    uint256 public maxDelta; // set once in the constructor.
    mapping(address => mapping(address => uint256)) public allowedRBT; // This is denominated in RBT, because the underlying "constituent points" conversion might change before it's fully paid.

    /// Events

    /**
     * @dev Emitted when a rebase occurs.
     * @param totalSupply The new total supply of the token after the rebase.
     */
    event Rebase(uint256 totalSupply);

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
        if (delta == 0) revert RebasingERC20__DeltaCannotBeZero();
        uint256 absDelta = abs(delta);
        if (absDelta > maxDelta) revert RebasingERC20__AbsoluteDeltaTooHigh(delta, maxDelta);
        if ((delta % int256(10 ** 6)) != 0) revert RebasingERC20__DeltaNotWhollyDivisible(delta); 

        if (delta < 0) {
            _totalSupply -= absDelta;
        } else {
            _totalSupply += absDelta;
        }
        _scalingFactor = (1e18) * _totalSupply / _initialSupply;
        emit Rebase(_totalSupply);
        return _totalSupply;
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
     * - Update `allowedRBT` mapping for sender and msg.sender
     * - Use the `_beforeTokenTransfer()` hook to handle the various ways that transfer is being called.
     * - Emit the Transfer event as per ERC20 standard.
     * - Return true if tx was successful.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        allowedRBT[sender][msg.sender] = allowedRBT[sender][msg.sender] - (amount);
        _beforeTokenTransfer(sender, recipient, amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    /// NEW FUNCTIONS

    /**
     * @dev Transfer all balance tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * Requirements:
     * - Calculate the `value` of $RBT to transfer, use the scaling factor and appropriate decimals.
     * - Update the `allowedRBT` mapping for `from` and `msg.sender`
     * - Delete the `_balances[from]`
     * - Increase the `_balances[to]` by the correct amount
     * - Emit the Transfer event as per ERC20 standard.
     * - Return true if tx was successful.
     */
    function transferAllFrom(address from, address to) external returns (bool) {
        uint256 constituentValue = _balances[from];
        uint256 value = constituentValue * 1e18 / (_scalingFactor);
        allowedRBT[from][msg.sender] = allowedRBT[from][msg.sender] - (value);
        delete _balances[from];
        _balances[to] = _balances[to] +  (constituentValue);
        emit Transfer(from, to, value);
        return true;
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
        allowedRBT[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
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
        allowedRBT[msg.sender][spender] = allowedRBT[msg.sender][spender] +  (
            addedValue
        );
        emit Approval(msg.sender, spender, allowedRBT[msg.sender][spender]);
        return true;
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
        uint256 oldValue = allowedRBT[msg.sender][spender];
        allowedRBT[msg.sender][spender] = (subtractedValue >= oldValue)
            ? 0
            : oldValue - (subtractedValue);
        emit Approval(msg.sender, spender, allowedRBT[msg.sender][spender]);
        return true;
    }

    /// Helper Functions (not part of the challenge)

    /**
     * @dev Hook that is called before any transfer of tokens. This includes minting and burning.
     * @param from The address from which tokens are transferred.
     * @param to The address to which tokens are transferred.
     * @param amount The amount of tokens to be transferred.
     * Requirements
     * - Write conditional statement for minting, aka when from address is address(0)
     * - Write conditional statement for burning, aka when to address is address(0)
     * - Finally handle if the sequence is just a transference of tokens.
     * - For all of the above, make sure to increase or decrease token balances whilst taking into account the _scalingFactor.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        amount = amount * (1e18) / _scalingFactor;
        if (from == address(0)) {
            // Minting tokens - recall that minting is only allowable at the deployment of the contract.
            _balances[to] += amount;
        } else if (to == address(0)) {
            // Burning tokens - update scaling factors since total supply is changing.
            _balances[from] -= amount;
            _totalSupply -= amount;
            _scalingFactor = (1e18) * _totalSupply / _initialSupply;
        } else {
            // Transfer between accounts
            _balances[from] -= amount;
            _balances[to] += amount;
        }
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
