// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import { console2 } from "forge-std/console2.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Governance {

    enum Choice {
        NAY,
        YEA,
        ABSTAIN
    }

    struct Proposal {
        bytes32 id;
        string title;
        uint256 votingDeadline;
        address creator
    }

    // Token contract interface
    IERC20 public voteToken;

    uint256 public votingPeriod;
    uint256 private nonce;

    // Tracks whether an address has voted
    mapping(bytes32 => mapping(address => bool)) public hasVoted;
    // Tracks what choice an address has voted on the proposal
    mapping(bytes32 => mapping(address => Choice)) public choice;
    // Tracks proposals created by members
    mapping(bytes32 => Proposal) public proposals;
    // Total votes in favor of the proposal
    mapping(bytes32 => uint256) public votesFor;
    // Total votes against the proposal
    mapping(bytes32 => uint256) public votesAgainst;
    // Total votes to abstain
    mapping(bytes32 => uint256) public votesAbstain;

    // Event emitted when a vote is cast
    event VoteCasted(bytes32 proposalId, address indexed voter, Choice vote, uint256 weight);

    // Event emitted when a proposal is created
    event ProposalCreated(bytes32 proposalId, string title, uint256 votingDeadline, address creator);

     /**
     * @notice Constructor to initialize the governance contract
     * @param _tokenAddress The address of the ERC20 token contract
     * @param _votingPeriod The duration of the voting period in seconds
     */
    constructor(address _tokenAddress, uint256 _votingPeriod) {
        voteToken = IERC20(_tokenAddress);
        votingPeriod = _votingPeriod;
        nonce = 0;
    }
    
    /**
     * @notice Modifier to restrict access to only the token holders
     */
    modifier onlyMembers() {     
        require(voteToken.balanceOf(msg.sender) > 0, "MembersOnly::You have no tokens");
        _;
    }

    /**
     * @notice Function to create a new proposal
     * @dev Only members (token holders) can create proposals
     * @param _title The title of the proposal
     * @return proposalId The unique ID of the newly created proposal
     */
    function propose(string memory _title) external onlyMembers {
        //
    }

    /**
     * @notice Function to cast a vote on a proposal
     * @dev Only members (token holders) can vote
     * @param _proposalId The ID of the proposal to vote on
     * @param _support The choice of the voter (YEA, NAY, ABSTAIN)
     */
    function vote(bytes32 _proposalId, Choice _support) public onlyMembers {
        //
    }

    /**
     * @notice Function to get a proposal by its ID
     * @param _proposalId The ID of the proposal to retrieve
     * @return The proposal struct containing its details
     */
    function getProposal(bytes32 _proposalId) external view returns (Proposal) {
        //
    }

    /**
     * @notice Function to get the vote of a specific address on a specific proposal
     * @param _proposalId The ID of the proposal
     * @param _voter The address of the voter
     * @return The choice of the voter (YEA, NAY, ABSTAIN)
     */
    function getVote(bytes32 _proposalId, address _voter) external view returns (Choice) {
        //
    }
     
    /**
     * @notice Function to get the voting deadline of a proposal
     * @param _proposalId The ID of the proposal
     * @return The voting deadline of the proposal
     */
    function getVotingDeadline(bytes32 _proposalId) public view returns (uint256) {
        //
    }

    /**
     * @notice Function to get the result of a proposal vote
     * @param _proposalId The ID of the proposal
     * @return True if the votes in favor are greater than the votes against, otherwise false
     */
    function getResult(bytes32 _proposalId) public view returns (bool) {
        //
    }
}