//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { console2 } from "forge-std/console2.sol";

/**
 * @title Social Recovery Wallet Challenge Contract
 * @author BUIDL GUIDL
 * @notice This challenge contract is meant to allow users to recover control of their wallet in the event of a lost seed phrase.
 * @dev The natspec is meant to be paired with the README.md to help guide you through this challenge! Good luck!
 * @dev This smart contract is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 */
contract SocialRecoveryWallet {

    ///////////////////
    // Errors
    ///////////////////
    /// @dev The caller of the function is not the owner of the wallet
    error SocialRecoveryWallet__NotOwner();
    /// @dev The caller of the function is not a guardian
    error SocialRecoveryWallet__NotGuardian();
    /// @dev The wallet is not in the recovery state when it needs to be
    error SocialRecoveryWallet__WalletNotInRecovery();
    /// @dev The wallet is in the recovery state when it shouldn't be
    error SocialRecoveryWallet__WalletInRecovery();
    /// @dev The guardian attempting to vote for recovery has already voted
    error SocialRecoveryWallet__AlreadyVoted();
    /// @dev The `call()` function reverted when trying to send ETH or call another contract
    error SocialRecoveryWallet__CallFailed();
    /// @dev The threshold is set higher than the number of guardians
    error SocialRecoveryWallet__ThresholdTooHigh();

    ///////////////////
    // State Variables
    ///////////////////
    address public owner;    

    /// @dev Whether or not the wallet is actively being recovered
    bool public inRecovery;

    /// @dev The number of guardian votes required to recover the wallet
    uint256 public threshold;
    /// @dev The number of guardians
    uint256 public numGuardians;
    /// @dev A counter to keep track of the current recovery round
    uint256 public currRound;

    /// @dev Mapping of round number to guardian address to whether or not they have voted
    mapping(uint => mapping(address => bool)) public recoveryRoundToGuardianVoted;
    /// @dev Mapping to keep track of whether or not an address is a guardian
    mapping(address => bool) public isGuardian;

    /// @dev Struct to keep track of the current recovery info
    struct Recovery {
        address proposedOwner;
        uint256 votes;
        uint256 round;
    }

    Recovery public currRecovery;

    ///////////////////
    // Events
    ///////////////////
    event RecoveryInitiated(address indexed by, address newProposedOwner);
    event RecoverySupported(address indexed by, address newProposedOwner);
    event RecoveryExecuted(address newOwner);

    ///////////////////
    // Modifiers
    ///////////////////
    /**
     * @dev Modifier to check if the caller of the function is the owner of the wallet
     * Requirements:
     * - Reverts with SocialRecoveryWallet__NotOwner if caller of the function is not the owner of the wallet
     */
    modifier onlyOwner {

        _;
    }

    /**
     * @dev Modifier to check if the caller of the function is a guardian
     * Requirements:
     * - Reverts with SocialRecoveryWallet__NotGuardian if the caller is not a guardian
     */
    modifier onlyGuardian {

        _;
    }

    /**
     * @dev Modifier to check if the wallet is not in recovery
     * Requirements:
     * - Reverts with SocialRecoveryWallet__WalletInRecovery if the wallet is in recovery
     */
    modifier notBeingRecovered {

        _;
    }

    /**
     * @dev Modifier to check if the wallet is in recovery
     * Requirements:
     * - Reverts with SocialRecoveryWallet__WalletNotInRecovery if the wallet is not in recovery
     */
    modifier isBeingRecovered {
  
        _;
    }

    ///////////////////
    // Functions
    ///////////////////
    /**
     * @param _guardians: addresses to be added as guardians
     * @param _threshold: the number of guardian votes required to recover the wallet
     * Requirements:
     * - Sets the owner to the sender of the transaction
     * - Sets the threshold to the input
     * - Adds the each address in _guardians to the contract
     */
    constructor(address[] memory _guardians, uint256 _threshold) {

    }

    /**
     * @param _callee: The address of the contract or EOA you want to call
     * @param _value: The amount of ETH you're sending, if any
     * Requirements:
     * - Calls the address at _callee with the value and data passed
     * - Emits a `SocialRecoveryWallet__CallFailed` error if the call reverts
     */
    function call(address _callee, uint256 _value, bytes calldata _data) external onlyOwner notBeingRecovered returns (bytes memory) {

    }

    /**
     * @notice The function for the first guardian to call in order to initiate the recovery process for the wallet
     * @param _proposedOwner: the address of the new owner that will take control of the wallet
     * Requirements:
     * - Puts contract into recovery mode
     * - Records the proposed owner, current round, and the vote of the guardian making the call
     * - Emits a `RecoveryInitiated` event
     */
    function initiateRecovery(address _proposedOwner) onlyGuardian notBeingRecovered external {

    }

    /**
     * @notice For other guardians to call after the recovery process has been initiated. If the threshold is met, ownership the wallet will transfered and the recovery process completed
     * @param _proposedOwner: the address of the new owner that will take control of the wallet
     * Requirements:
     * - Records the vote of the guardian making the call
     * - Emits a `RecoverySupported` event
     * - If threshold is met:
        * - Changes the owner of the wallet
        * - Takes contract out of recovery mode
        * - Emits a `RecoveryExecuted` event
     */
    function supportRecovery(address _proposedOwner) external onlyGuardian isBeingRecovered {

    }

    /**
     * @param _guardian: The address of the contract or EOA to be added as a guardian
     * Requirements:
     * - Records the address as a guardian
     * - Updates the numGuardians variable
     */
     function addGuardian(address _guardian) external onlyOwner {

     }

    /**
     * @param _guardian: The address of the contract or EOA to be removed as a guardian
     * Requirements:
     * - Removes the record of the address as a guardian
     * - Updates the numGuardians variable
     */
     function removeGuardian(address _guardian) external onlyOwner {

     }

    /**
     * @param _threshold: The number of guardian votes required to recover the wallet
     * Requirements:
     * - Sets the contract's threshold to the input
     * - Reverts with SocialRecoveryWallet__ThresholdTooHigh if trying to set threshold higher than the number of guardians
     */
     function setThreshold(uint256 _threshold) external onlyOwner {

     }
}
