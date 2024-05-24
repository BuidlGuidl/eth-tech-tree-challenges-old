// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Voting {
    // Token contract interface
    IERC20 public token;
    // Voting deadline timestamp
    uint256 public votingDeadline;
    // Tracks whether an address has voted
    mapping(address => bool) public hasVoted;
    // Total votes in favor of the proposal
    uint256 public votesFor;
    // Total votes against the proposal
    uint256 public votesAgainst;
    // The proposal
    string public proposal = "Expand the Intelligence Network";

    // Event emitted when a vote is cast
    event VoteCasted(address indexed voter, bool vote, uint256 weight);

    /**
     * @dev Constructor to initialize the voting contract
     * @param _tokenAddress The address of the ERC20 token contract
     * @param _votingPeriod The duration of the voting period in seconds
     * Requirements:
     * - Initialize the token contract using IERC20 interface
     * - Set the voting deadline
     */
    constructor(address _tokenAddress, uint256 _votingPeriod) {
        token = IERC20(_tokenAddress);
        votingDeadline = block.timestamp + _votingPeriod;
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
     * - Emits a `VoteCasted` event.
     */
    function vote(bool support) public {
        require(block.timestamp < votingDeadline, "Voting has ended");
        require(!hasVoted[msg.sender], "You have already voted");

        uint256 voterWeight = token.balanceOf(msg.sender);
        require(voterWeight > 0, "You have no tokens to vote with");

        if (support) {
            votesFor += voterWeight;
        } else {
            votesAgainst += voterWeight;
        }
        hasVoted[msg.sender] = true;
        emit VoteCasted(msg.sender, support, voterWeight);
    }

    /**
     * @dev Function to get the result of the vote
     * @return The result of the vote as a string ("Proposal Approved" or "Proposal Rejected")
     * Requirements:
     * - Ensure the voting period has ended
     * - Determine the result based on the majority vote
     */
    function getResult() public view returns (bool) {
        require(block.timestamp >= votingDeadline, "Voting is still ongoing");
        return votesFor > votesAgainst;
    }
}
