//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console} from "forge-std/console.sol";

contract EthAndTokenStreaming is Ownable {
    /***** ERRORS *****/
    error InsufficentFunds();
    error NoActiveStream();
    error NotEnoughStreamUnlocked();
    error TransferFailed();

    /***** TYPES *****/
    struct StreamConfig {
        uint256 cap;
        uint256 timeOfLastWithdrawal;
    }

    /***** MODIFIERS *****/
    modifier hasStream(address account) {
        StreamConfig storage builderStream = s_streamRegistry[account];
        if (builderStream.cap == 0) revert NoActiveStream();
        _;
    }

    /***** STATE VARIABLES *****/
    mapping(address => StreamConfig) private s_streamRegistry;
    uint256 public immutable i_frequency = 2592000; // How long until stream is fully unlocked after last withdrawal

    /***** EVENTS *****/
    event Withdraw(address indexed to, uint256 amount);
    event AddStream(address indexed to, uint256 cap);

    /***** FUNCTIONS *****/
    constructor() {}

    /***** EXTERNAL FUNCTIONS *****/
    receive() external payable {}

    fallback() external payable {}

    /**
     * @param account new account allowed allowed to withdraw from a stream
     * @param cap max amount (in wei) that can be withdrawn from stream at a time
     * Requirements:
     * - Only owner can add a stream
     * - Emits a `AddStream` event with the address of the account receiving the stream and the cap amount for the stream
     */
    function addStream(address account, uint256 cap) public onlyOwner {
        s_streamRegistry[account] = StreamConfig(cap, 0);
        emit AddStream(account, cap);
    }

    /**
     * @dev Withdraws the maximum amount that can be withdrawn from the stream
     * Requirements:
     * - Revert if there is not enough funds in the contract
     * - Revert if the sender does not have a stream
     */
    function maxWithdraw() public hasStream(msg.sender) {
        uint256 amount = unlockedAmount(msg.sender);
        if (amount > address(this).balance) revert InsufficentFunds();

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();

        StreamConfig storage builderStream = s_streamRegistry[msg.sender];
        builderStream.timeOfLastWithdrawal = block.timestamp;

        emit Withdraw(msg.sender, amount);
    }

    /***** VIEW FUNCTIONS *****/

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
        StreamConfig storage stream = s_streamRegistry[account];

        console.log("block.timestamp: ", block.timestamp);
        console.log(
            "stream.timeOfLastWithdrawal: ",
            stream.timeOfLastWithdrawal
        );
        uint256 timeSinceLastWithdrawal = block.timestamp -
            stream.timeOfLastWithdrawal;
        if (timeSinceLastWithdrawal > i_frequency) return stream.cap;

        amount = (stream.cap * timeSinceLastWithdrawal) / i_frequency;
    }

    /**
     * @dev This is a getter function for the stream registry
     * @param account account to get stream for
     * Requirements:
     * - Revert if the account does not have a stream
     * - Returns the stream configuration for the given account
     */
    function getStream(
        address account
    ) public view hasStream(account) returns (StreamConfig memory) {
        return s_streamRegistry[account];
    }
}
