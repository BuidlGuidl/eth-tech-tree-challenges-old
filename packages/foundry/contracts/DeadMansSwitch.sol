// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Dead Mans Switch Challenge Contract
 * @author BUIDL GUIDL
 * @notice This challenge contract is meant to help make it possible for benficiaries to recover funds in a contract if the owner dies or is otherwise unable to maintain access.
 * @dev The natspec is meant to be paired with the README.md to help guide you through this challenge! Good luck!
 * @dev This smart contract is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 */
contract DeadMansSwitch {
    
    ///////////////////
    // Errors
    ///////////////////
    // @dev The interval must be greater than 0
    error IntervalNotSet();
    // @dev Cannot be the 0 address
    error InvalidAddress();
    // @dev The beneficiary already exists
    error BeneficiaryAlreadyExists();
    // @dev The beneficiary does not exist
    error BeneficiaryDoesNotExist();
    // @dev The user has insufficient balance
    error InsufficientBalance();
    // @dev The check-in interval has not passed
    error CheckInNotLapsed();
    // @dev The caller is not a beneficiary
    error UnauthorizedCaller();
    // @dev The ETH failed to transfer
    error TransferFailed();

    ///////////////////
    // State Variables
    ///////////////////
    struct User {
        uint balance;
        uint lastCheckIn;
        uint checkInInterval;
        mapping(address => bool) isBeneficiary;
    }

    // @dev Mapping of user addresses to user data
    mapping(address => User) public users;

    ///////////////////
    // Events
    ///////////////////
    event CheckIn(address indexed user, uint timestamp);
    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed beneficiary, uint amount);
    event CheckInIntervalSet(address indexed user, uint interval);
    event BeneficiaryAdded(address indexed user, address indexed beneficiary);
    event BeneficiaryRemoved(address indexed user, address indexed beneficiary);

    ///////////////////
    // Functions
    ///////////////////
    /**
     * @dev Deposits Ether into the contract.
     * @notice This function allows users to deposit Ether into the contract.
     * Requirements:
     * - Adds the amount deposited to the balance of the sender.
     * - Updates the last check-in time to the current block timestamp.
     * - Emits a `Deposit` event with the caller's address and the amount of Ether deposited.
     */
    function deposit() public payable {
        
    }

    /**
     * @dev Sets the check-in interval for the user.
     * @param interval The time interval (in seconds) for the user to check in.
     * Requirements:
     * - Revert with IntervalNotSet if the interval is 0.
     * - Emits a `CheckInIntervalSet` event with the caller's address and the interval.
     */
    function setCheckInInterval(uint interval) public {

    }

    /**
     * @dev Allows the user to check in and reset the timer.
     * Requirements:
     * - Updates the last check-in time to the current block timestamp.
     * - Emits a `CheckIn` event with the caller's address and the current timestamp.
     */
    function checkIn() public {
  
    }

    /**
     * @dev Adds a beneficiary for the user's funds.
     * @param beneficiary The address of the beneficiary.
     * Requirements:
     * - Revert with InvalidAddress if the beneficiary address is the zero address.
     * - Revert with BeneficiaryAlreadyExists if the beneficiary has already been added.
     * - Emits a `BeneficiaryAdded` event with the caller's address and the beneficiary address.
     */
    function addBeneficiary(address beneficiary) public {

    }

    /**
     * @dev Removes a beneficiary for the user's funds.
     * @param beneficiary The address of the beneficiary to remove.
     * Requirements:
     * - Revert with BeneficiaryDoesNotExist if the beneficiary has not been added.
     * - Removes the beneficiary from the user's list of beneficiaries.
     * - Emits a `BeneficiaryRemoved` event with the caller's address and the beneficiary address.
     */
    function removeBeneficiary(address beneficiary) public {

    }
    /**
     * @dev Allows the user to withdraw their funds at any time.
     * @param amount The amount of Ether to withdraw.
     * Requirements:
     * - Revert with InsufficientBalance if the user does not have enough balance to withdraw the specified amount.
     * - Transfer the amount and revert with TransferFailed if the Ether fails to send.
     * - Emits a `Withdrawal` event with the caller's address and the amount of Ether withdrawn.
     */
    function withdraw(uint amount) public {

    }

    /**
     * @dev Allows beneficiaries to withdraw the user's funds if the check-in interval has passed.
     * @param userAddress The address of the user.
     * Requirements:
     * - Revert with CheckInNotLapsed if the user's check-in interval has not passed.
     * - Revert with UnauthorizedCaller if the caller is not a beneficiary.
     * - Transfer the total amount of the users balance and revert with TransferFailed if the Ether fails to send.
     * - Emits a `Withdrawal` event with the beneficiary's address and the amount of Ether withdrawn.
     */
    function withdrawAsBeneficiary(address userAddress) public {

    }

    /**
     * @dev Gets to check if there is a beneficiary.
     * @param userAddress The address of the user.
     * @param beneficiary The address of the beneficiary.
     * @return boolean representing whether the address is a beneficiary
     * Requirements:
     * - Returns true if the provided beneficiary is a given userAddresses beneficiary, otherwise false
     */
    function beneficiaryLookup(
        address userAddress,
        address beneficiary
    ) public view returns (bool) {
        
    }
}
