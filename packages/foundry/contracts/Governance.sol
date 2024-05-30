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
        address creator;
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
    function propose(string memory _title) external onlyMembers returns(bytes32) {
        // Generate a unique ID for the proposal using keccak256 hash
        bytes32 proposalId = keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce));
        nonce++;
        uint256 votingDeadline = block.timestamp + votingPeriod;
        // Create the new proposal
        Proposal memory newProposal = Proposal({
            id: proposalId,
            title: _title,
            votingDeadline: votingDeadline,
            creator: msg.sender
        });
        // Save the proposal in the mapping
        proposals[proposalId] = newProposal;

        emit ProposalCreated(proposalId, _title, votingDeadline, msg.sender);

        return proposalId;
    }

    /**
     * @notice Function to cast a vote on a proposal
     * @dev Only members (token holders) can vote
     * @param _proposalId The ID of the proposal to vote on
     * @param _support The choice of the voter (YEA, NAY, ABSTAIN)
     */
    function vote(bytes32 _proposalId, Choice _support) public onlyMembers {
        require(uint(_support) <= uint(Choice.ABSTAIN), "Invalid choice");
        require(block.timestamp < proposals[_proposalId].votingDeadline, "Voting has ended");
        require(!hasVoted[_proposalId][msg.sender], "You have already voted");
        uint256 voterWeight = voteToken.balanceOf(msg.sender);
        // Update vote counts based on the support choice
        if (_support == Choice.YEA) {
            votesFor[_proposalId] += voterWeight;
        } else if (_support == Choice.NAY) {
            votesAgainst[_proposalId] += voterWeight;
        }else {
            votesAbstain[_proposalId] += voterWeight;
        }
        // Mark the voter as having voted and record their choice
        hasVoted[_proposalId][msg.sender] = true;
        choice[_proposalId][msg.sender] = _support;
        emit VoteCasted(_proposalId, msg.sender, _support, voterWeight);
    }

    /**
     * @notice Function to get a proposal by its ID
     * @param _proposalId The ID of the proposal to retrieve
     * @return The proposal struct containing its details
     */
    function getProposal(bytes32 _proposalId) external view returns (Proposal memory) {
        return proposals[_proposalId];
    }

    /**
     * @notice Function to get the vote of a specific address on a specific proposal
     * @param _proposalId The ID of the proposal
     * @param _voter The address of the voter
     * @return The choice of the voter (YEA, NAY, ABSTAIN)
     */
    function getVote(bytes32 _proposalId, address _voter) external view returns (Choice) {
        return choice[_proposalId][_voter];
    }
     
    /**
     * @notice Function to get the voting deadline of a proposal
     * @param _proposalId The ID of the proposal
     * @return The voting deadline of the proposal
     */
    function getVotingDeadline(bytes32 _proposalId) public view returns (uint256) {
        return proposals[_proposalId].votingDeadline;
    }

    /**
     * @notice Function to get the result of a proposal vote
     * @param _proposalId The ID of the proposal
     * @return True if the votes in favor are greater than the votes against, otherwise false
     */
    function getResult(bytes32 _proposalId) public view returns (bool) {
        require(block.timestamp >= proposals[_proposalId].votingDeadline, "Voting is still ongoing");
        return votesFor[_proposalId] > votesAgainst[_proposalId];
    }
}