//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import { console2 } from "forge-std/console2.sol";

/**
 * @title Social Recovery Wallet Challenge Contract
 * @author BUIDL GUIDL
 * @notice This challenge contract is meant to allow users to recover control of their wallet in the event of a lost seed phrase.
 * @dev The natspec is meant to be paired with the README.md to help guide you through this challenge! Goodluck!
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

    ///////////////////
    // State Variables
    ///////////////////
    address public owner;    

    /// @dev Whether or not the wallet is actively being recovered
    bool public inRecovery;
    /// @dev The number of guardian votes required to recover the wallet
    uint256 public threshold;
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
    modifier onlyOwner {
        if (msg.sender != owner) {
            revert SocialRecoveryWallet__NotOwner();
        }
        _;
    }

    modifier onlyGuardian {
        if (!isGuardian[msg.sender]) {
            revert SocialRecoveryWallet__NotGuardian();
        }
        _;
    }

    modifier notBeingRecovered {
        if (inRecovery) {
            revert SocialRecoveryWallet__WalletInRecovery();
        }
        _;
    }

    modifier isBeingRecovered {
        if (!inRecovery) {
            revert SocialRecoveryWallet__WalletNotInRecovery();
        }
        _;
    }

    ///////////////////
    // Functions
    ///////////////////
    constructor(address[] memory _guardians, uint256 _threshold) {
        owner = msg.sender;
        threshold = _threshold;
        currRound = 0;
        for (uint i = 0; i < _guardians.length; i++) {
            isGuardian[_guardians[i]] = true;
        }
    }

    /*
     * @param _callee: The address of the contract or EOA you want to call
     * @param _value: The amount of ETH you're sending, if any
     */
    function sendEth(address _callee, uint256 _value) external onlyOwner notBeingRecovered returns (bytes memory) {
        (bool success, bytes memory result) = _callee.call{value: _value}("");
        require(success, "external call reverted");
        return result;
    }

    /*
     * @notice The function for the first guardian to call in order to initiate the recovery process for the wallet
     * @param _proposedOwner: the address of the new owner that will take control of the wallet
     */
    function initiateRecovery(address _proposedOwner) onlyGuardian notBeingRecovered external {
        currRound++;
        currRecovery = Recovery(
            _proposedOwner,
            1,
            currRound
        );
        recoveryRoundToGuardianVoted[currRound][msg.sender] = true;
        inRecovery = true;
        emit RecoveryInitiated(msg.sender, _proposedOwner);
    }

    /*
     * @notice For other guardians to call after the recovery process has been initiated. If the threshold is met, ownership the wallet will transfered and the recovery process completed
     * @param _proposedOwner: the address of the new owner that will take control of the wallet
     */
    function supportRecovery(address _proposedOwner) onlyGuardian isBeingRecovered external {
        if (recoveryRoundToGuardianVoted[currRecovery.round][msg.sender]) {
            revert SocialRecoveryWallet__AlreadyVoted();
        }

        currRecovery.votes++;
        recoveryRoundToGuardianVoted[currRecovery.round][msg.sender] = true;

        emit RecoverySupported(msg.sender, _proposedOwner);

        if (currRecovery.votes >= threshold) {
            owner = currRecovery.proposedOwner;
            inRecovery = false;
            emit RecoveryExecuted(currRecovery.proposedOwner);
        }
    }
}
