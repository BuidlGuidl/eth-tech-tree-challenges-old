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
    modifier hasStream(address account) {
        StreamConfig storage builderStream = streamRegistry[account];
        if (builderStream.cap == 0) revert NoActiveStream();
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
        emit EthReceived(msg.sender, msg.value);
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
        streamRegistry[account] = StreamConfig(cap, 0);
        emit AddStream(account, cap);
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
        uint256 amount = unlockedAmount(msg.sender);
        if (amount > address(this).balance) revert InsufficentFunds();

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();

        StreamConfig storage builderStream = streamRegistry[msg.sender];
        builderStream.timeOfLastWithdrawal = block.timestamp;

        emit Withdraw(msg.sender, amount);
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
     * - Withdraws the full cap amount if the time since the last withdrawal is greater than the frequency
     * - Withdraws a fraction of the cap amount if the time since the last withdrawal is less than the frequency
     */
    function unlockedAmount(
        address account
    ) public view hasStream(account) returns (uint256 amount) {
        StreamConfig storage stream = streamRegistry[account];

        uint256 timeSinceLastWithdrawal = block.timestamp -
            stream.timeOfLastWithdrawal;
        if (timeSinceLastWithdrawal > FREQUENCY) return stream.cap;

        amount = (stream.cap * timeSinceLastWithdrawal) / FREQUENCY;
    }

    /**
     * @dev This is a getter function for the stream registry
     * @param account account to get stream for
     * @return stream configuration for the given account
     * Requirements:
     * - Revert if the account does not have a stream
     * - Returns the stream configuration for the given account
     */
    function getStream(
        address account
    ) public view hasStream(account) returns (StreamConfig memory stream) {
        return streamRegistry[account];
    }
}
