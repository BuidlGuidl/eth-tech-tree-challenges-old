// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { console2 } from "forge-std/console2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Voting {

    ///////////////////
    // Errors
    ///////////////////
    // @dev The call does not come from the token contract
    error Voting__NotTokenContract();
    // @dev The call is made after the voting period has ended
    error Voting__VotingHasEnded();
    // @dev The call is made before the voting period has ended
    error Voting__VotingHasNotEnded();
    // @dev The caller has already voted
    error Voting__AlreadyVoted();
    // @dev The caller doesn't have enough tokens to vote
    error Voting__NotEnoughTokens();

    ///////////////////
    // State Variables
    ///////////////////
    // @dev Token contract interface
    IERC20 public token;

    // @dev Voting deadline timestamp
    uint256 public votingDeadline;
    // @dev Total votes in favor of the proposal
    uint256 public votesFor;
    // @dev Total votes against the proposal
    uint256 public votesAgainst;

    // @dev The proposal
    string public proposal = "Expand the Intelligence Network";

    // @dev Tracks whether an address has voted
    mapping(address => bool) public hasVoted;
    // @dev Tracks whether an address has supported the proposal
    mapping(address => bool) public hasSupported;

    ///////////////////
    // Events
    ///////////////////
    // @dev Event emitted when a vote is cast
    event VoteCasted(address indexed voter, bool vote, uint256 weight);
    // @dev Event emitted when votes are removed
    event VotesRemoved(address indexed voter, uint256 weight);

    ///////////////////
    // Modifiers
    ///////////////////
    /**
     * @dev Modifier to restrict access to only the token contract
     * Requirements:
     * - The caller must be the token contract
     */
    modifier onlyTokenContract() {

        _;
    }

    ///////////////////
    // Functions
    ///////////////////
    /**
     * @dev Constructor to initialize the voting contract
     * @param _tokenAddress The address of the ERC20 token contract
     * @param _votingPeriod The duration of the voting period in seconds
     * Requirements:
     * - Initialize the token contract using IERC20 interface
     * - Set the voting deadline
     */
    constructor(address _tokenAddress, uint256 _votingPeriod) {
        
    }
    
    /**
     * @dev Function to remove votes when tokens used for voting are transferred
     * @param voter The address of the voter whose votes are to be removed
     * Requirements:
     * - The voter must have voted
     * - Adjusts the vote count based on the voter's previous support or opposition
     * - Remove the voter's weight from voted option
     * - Resets the hasVoted flags for the voter
     * - Emits a `VotesRemoved` event
     * - Reverts with `Voting__NotTokenContract` error if called by anyone other than the token contract
     */
    function removeVotes(address voter) external onlyTokenContract {
        
    }

    /**
     * @dev Function to cast a vote
     * @param support Boolean indicating whether the vote is in favor (true) or against (false) the proposal
     * Requirements:
     * - Ensure the voting period has not ended.
     * - Ensure the voter has not already voted.
     * - Ensure the user has tokens to cast a vote.
     * - Updates votesFor or votesAgainst based on the vote.
     * - Marks the user as having voted.
     * - Marks the user's support status.
     * - Emits a `VoteCasted` event.
     * - Reverts with `Voting__VotingHasEnded` error if voting period has ended.
     * - Reverts with `Voting__AlreadyVoted` error if caller has already voted.
     * - Reverts with `Voting__NotEnoughTokens` error if caller doesn't have a balance.
     */
    function vote(bool support) public {
        
    }

    /**
     * @dev Function to get the result of the vote
     * @return The result should be true if the majority of votes are in favor, otherwise return false
     * Requirements:
     * - Reverts with `Voting__VotingHasNotEnded` error if the voting period has not ended
     * - Determine the result based on the majority vote
     */
    function getResult() public view returns (bool) {
       
    }
}
