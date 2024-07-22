//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import { console2 } from "forge-std/console2.sol";

contract WrappedETH {
    ///////////////////
    // Errors
    //////////////////
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error InsufficientWETHBalance(address withdrawer, uint256 balance, uint256 needed);
    error FailedToSendEther(address recipient, uint256 amount);

    ///////////////////
    // State Variables
    //////////////////
    // ERC20 Standard methods for token metadata
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    // ERC20 Standard Interface mappings
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    ///////////////////
    //  Events
    //////////////////
    // ERC20 Standard Interface Events
    event Approval(address indexed owner, address indexed spender, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);

    // Non-ERC20 Standard Events - specific to the Wrapped Ether contract
    event Deposit(address indexed owner, uint amount);
    event Withdrawal(address indexed owner, uint amount);

    ///////////////////
    //  Functions
    //////////////////
    /**
     * @dev Deposits Ether into the contract.
     * @notice This function allows users to deposit Ether into the contract.
     * @dev The deposited Ether is added to the balance of the sender.
     * Requirements:
     * - Adds the amount deposited to the balance of the sender.
     * - Emits a `Deposit` event with the caller's address and the amount of Ether deposited.
     */
    function deposit() public payable {

    }

    /**
     * @dev Allows the caller to withdraw a specified amount of wrapped Ether (WETH) from their balance.
     * @param amount The amount of wrapped Ether to withdraw.
     * Requirements:
     * - Revert with InsufficientWETHBalance if the caller's balance is less than the amount param
     * - Revert with FailedToSendEther if the withdrawal is unsuccessful
     * - Emits a `Withdrawal` event with the caller's address and the amount of Ether withdrawn.
     */
    function withdraw(uint amount) public {
        
    }

    /**
     * @dev Part of the ERC20 Standard Interface.
     * @dev Returns the total supply of the wrapped ETH token.
     * @return uint representing the total supply of the wrapped ETH token.
     * Requirements:
     * - The total supply is equal to the balance of the contract.
     */
    function totalSupply() public view returns (uint) {
        
    }

    /**
     * @dev Part of the ERC20 Standard Interface.
     * @dev Approves the specified address to spend the caller's tokens.
     * @param spender The address to be approved.
     * @param amount The amount of tokens to be approved.
     * @return boolean value indicating whether the approval was successful or not.
     * Requirements:
     * - The caller sets the allowance of the specified address to the specified amount of tokens.
     * - Emits an `Approval` event with the caller's address, the approved address, and the amount of tokens approved.
     */
    function approve(address spender, uint amount) public returns (bool) {
        
    }

    /**
     * @dev Part of the ERC20 Standard Interface.
     * @dev Transfers a specified amount of wrapped ETH tokens from the 'from' address to the 'to' address.
     * @param from The address to transfer the tokens from.
     * @param to The address to which tokens are to be transferred.
     * @param amount The amount of tokens to transfer.
     * @return boolean value indicating whether the transfer was successful or not.
     * Requirements:
     * - Revert with ERC20InsufficientBalance if the from address has a balance less than the amount param.
     * - Revert with ERC20InsufficientAllowance if the caller is not the from address and the allowance is less than the amount param.
     * - Emits a `Transfer` event with the caller's address, the to address, and the amount of tokens approved.
     */
    function transferFrom(
        address from,
        address to,
        uint amount
    ) public returns (bool) {
        
    }

    /**
     * @dev Part of the ERC20 Standard Interface.
     * @dev Transfers a specified amount of wrapped ETH tokens from the caller's address to the to address.
     * @param to The address to transfer the tokens to. to == to
     * @param amount The amount of tokens to transfer.
     * @return boolean value indicating whether the transfer was successful or not.
     * Requirements:
     * - The caller must have a balance of at least `amount` tokens or revert with ERC20InsufficientBalance.
     * - Emits a `Transfer` event with the caller's address, the approved address, and the amount of tokens approved.
     */
    function transfer(address to, uint amount) public returns (bool) {
        
    }

    /**
     * @dev Default 'fallback' method called when a contract is called with msg.data that doesn't match any other method.
     * Requirements:
     * - Should call the `deposit` function to handle any received Ether.
     */
    fallback() external payable {
        
    }

    /**
     * @dev Default method is used when a contract is called with empty msg.data.
     * Requirements:
     * - Should call the `deposit` function to handle any received Ether.
     */
    receive() external payable {
        
    }
}
