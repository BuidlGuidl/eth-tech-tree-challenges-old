//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract Challenge {
    ///// Errors /////
    error InsufficentFunds();
    error NoActiveStream();
    error NotEnoughStreamUnlocked();
    error TransferFailed();

    ///// Types /////
    struct StreamConfig {
        uint256 cap;
        uint256 timeOfLastWithdrawal;
    }

    ///// Modifiers /////
    modifier senderHasStream() {
        StreamConfig storage builderStream = s_streamRegistry[msg.sender];
        if (builderStream.cap == 0) revert NoActiveStream();
        _;
    }

    ///// State Variables /////
    mapping(address => StreamConfig) public s_streamRegistry;
    uint256 public immutable i_frequency = 2592000; // How long until stream is fully unlocked after last withdrawal

    ///// Events /////
    event Withdraw(address indexed to, uint256 amount);
    event AddBuilder(address indexed to, uint256 amount);

    ///// Functions /////
    constructor() {}

    ///// External Functions /////
    receive() external payable {}

    fallback() external payable {}

    /**
     * @param builder new account allowed allowed to withdraw from a stream
     * @param cap max amount (in wei) that can be withdrawn from stream at a time
     */
    function addBuilderStream(address payable builder, uint256 cap) public {
        s_streamRegistry[builder] = StreamConfig(cap, 0);
        emit AddBuilder(builder, cap);
    }

    /**
     * Withdraws the maximum amount that can be withdrawn from the stream
     * @dev Should revert if there is not enough funds in the contract
     * @dev Should revert if the sender does not have a stream
     */
    function maxWithdraw() public senderHasStream {
        uint256 maxAmount = unlockedAmount(msg.sender);
        if (address(this).balance >= maxAmount) revert InsufficentFunds();

        (bool success, ) = msg.sender.call{value: maxAmount}("");
        if (!success) revert TransferFailed();

        StreamConfig storage builderStream = s_streamRegistry[msg.sender];
        builderStream.timeOfLastWithdrawal = block.timestamp;

        emit Withdraw(msg.sender, maxAmount);
    }

    ///// View Functions /////
    /**
     * @param builder account to check unlocked amount
     * @return amount in wei that can be withdrawn
     */
    function unlockedAmount(
        address builder
    ) public view senderHasStream returns (uint256 amount) {
        StreamConfig storage builderStream = s_streamRegistry[builder];

        uint256 timeSinceLastWithdrawal = block.timestamp -
            builderStream.timeOfLastWithdrawal;
        if (timeSinceLastWithdrawal > i_frequency) return builderStream.cap;

        amount = (builderStream.cap * timeSinceLastWithdrawal) / i_frequency;
    }
}
