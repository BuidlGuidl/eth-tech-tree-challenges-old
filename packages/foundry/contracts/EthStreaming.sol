//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console2} from "forge-std/console2.sol";

/**
 * @title ETH Streaming Contract
 * @author Buidl Guidl Labs
 * @notice The natspec paired with the README will help guide you towards completing this challenge
 * @dev The goal for this challenge is to write contract that allows for the owner of the contract to add
 * accounts that have permission to withdraw up to a certain amount of ETH from the contract every 30 days
 */
contract EthStreaming is Ownable {
    ///////////////////
    // Errors
    ///////////////////
    error InsufficentFunds();
    error NoActiveStream();
    error NotEnoughStreamUnlocked();
    error TransferFailed();

    ///////////////////
    // Types
    ///////////////////
    struct StreamConfig {
        uint256 cap;
        uint256 timeOfLastWithdrawal;
    }

    ///////////////////
    // State Variables
    ///////////////////
    mapping(address => StreamConfig) private streamRegistry;
    uint256 public immutable FREQUENCY = 2592000; // How long until stream is fully unlocked after last withdrawal

    ///////////////////
    // Events
    ///////////////////
    event Withdraw(address indexed to, uint256 amount);
    event AddStream(address indexed to, uint256 cap);
    event EthReceived(address indexed from, uint256 amount);

    ///////////////////
    // Modifiers
    ///////////////////
    /**
     * @dev This modifier checks if an account has a stream
     * Requirements:
     * - Revert with NoActiveStream if the account does not have a stream
     */
    modifier hasStream(address account) {

        _;
    }

    ///////////////////
    // Functions
    ///////////////////
    constructor() {}

    ///////////////////
    // External Functions
    ///////////////////
    /**
     * @dev This special fallback function allows the contract to receive ether 👉 https://solidity-by-example.org/fallback/
     * The function also offers us opportunity to emit an event that will make it easier to track incoming funds
     * Requirements:
     * - Emit a `EthReceived` event with the address of the sender and the amount of ether sent
     */
    receive() external payable {

    }

    ///////////////////
    // Public Functions
    ///////////////////
    /**
     * @param account new account to add to the stream registry
     * @param cap max amount (in wei) that can be withdrawn from stream at a time
     * Requirements:
     * - Use a modifier inherited from OpenZeppelin's Ownable contract to prevent accounts that are not the owner of this contract from adding streams
     * - Add a stream for the account with the cap amount
     * - Emit an `AddStream` event with the address of the account receiving the stream and the cap amount for the stream
     */
    function addStream(address account, uint256 cap) public onlyOwner {

    }

    /**
     * @dev Withdraws the maximum amount that can be withdrawn from the stream
     * Requirements:
     * - Revert if there is not enough funds in the contract
     * - Revert if the sender does not have a stream
     * - Transfer the amount to the sender
     * - Revert if the transfer is unsuccessful
     * - Update the StreamConfig of the sender with the time of transaction execution
     * - Emit a `Withdraw` event with the address of the sender and the amount withdrawn
     */
    function maxWithdraw() public hasStream(msg.sender) {

    }

    //////////////////////////////
    // View Functions
    //////////////////////////////
    /**
     * @dev This function calculates the amount that can be withdrawn from a stream at a given time
     * @param account account to check unlocked amount
     * @return amount in wei that can be withdrawn
     * Requirements:
     * - Revert if the account does not have a stream
     * - Returns the full cap amount if the time since the last withdrawal is greater than the frequency
     * - Returns a fraction of the cap amount if the time since the last withdrawal is less than the frequency
     */
    function unlockedAmount(
        address account
    ) public view hasStream(account) returns (uint256 amount) {

    }

    /**
     * @dev This is a getter function for the stream registry
     * @param account account to get stream for
     * @return stream configuration for the given account
     * Requirements:
     * - Revert if the account does not have a stream (Use the hasStream modifier)
     * - Returns the stream configuration for the given account
     */
    function getStream(
        address account
    ) public view hasStream(account) returns (StreamConfig memory stream) {

    }
}
