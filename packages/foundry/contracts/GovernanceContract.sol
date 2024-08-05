// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./GovernanceToken.sol";

/// @title Governance Contract
/// @notice This contract handles the governance mechanism including proposal creation and voting
/// @dev Uses a GovernanceToken for vote delegation
contract GovernanceContract is Ownable {
    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 endBlock;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) voted;
    }

    GovernanceToken public governanceToken;
    uint256 public proposalCount;
    uint256 public proposalThreshold;
    uint256 public quorum;
    uint256 public votingPeriod;

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 id, address proposer, string description, uint256 endBlock);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalResult(uint256 proposalId, bool passed);

    constructor(
        address _governanceToken,
        uint256 _proposalThreshold,
        uint256 _quorum,
        uint256 _votingPeriod
    ) {
        governanceToken = GovernanceToken(_governanceToken);
        proposalThreshold = _proposalThreshold;
        quorum = _quorum;
        votingPeriod = _votingPeriod;
    }

    /// @notice Create a new governance proposal
    /// @param deadline The block number at which voting ends for the proposal
    /// @param description The description of the proposal
    /// @dev Ensure the proposer has enough votes (including delegated votes) to meet the proposal threshold
    /// @custom:requirements 
    /// - The caller's total votes (own + delegated) must meet the proposal threshold.
    function createProposal(uint256 deadline, string calldata description) external {
        uint256 totalVotes = governanceToken.balanceOf(msg.sender) + governanceToken.delegatedVotes(msg.sender);
        require(totalVotes >= proposalThreshold, "Not enough votes to create proposal");

        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        proposal.id = proposalCount;
        proposal.proposer = msg.sender;
        proposal.description = description;
        proposal.endBlock = deadline;

        emit ProposalCreated(proposal.id, msg.sender, description, proposal.endBlock);
    }

    /// @notice Vote on an active proposal
    /// @param proposalId The ID of the proposal to vote on
    /// @param support Boolean indicating if the vote is in support of the proposal
    /// @dev Ensure the voter has not already voted and the proposal is still active
    /// @custom:requirements 
    /// - The caller must have votes available (own + delegated).
    /// - The voting period must not have ended.
    /// - The caller must not have voted on this proposal before.
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.number <= proposal.endBlock, "Voting period has ended");
        require(!proposal.voted[msg.sender], "Already voted");

        uint256 votes = governanceToken.balanceOf(msg.sender) + governanceToken.delegatedVotes(msg.sender);
        require(votes > 0, "No votes available");

        if (support) {
            proposal.votesFor += votes;
        } else {
            proposal.votesAgainst += votes;
        }
        proposal.voted[msg.sender] = true;

        emit Voted(proposalId, msg.sender, support);
    }

    /// @notice Show the result of a proposal
    /// @param proposalId The ID of the proposal to show the result for
    /// @return passed Boolean indicating if the proposal passed
    /// @dev Ensure the proposal has ended and met the quorum requirement
    /// @custom:requirements 
    /// - The voting period must have ended.
    /// - The proposal must have reached quorum.
    function proposalResult(uint256 proposalId) public view returns (bool passed) {
        Proposal storage proposal = proposals[proposalId];
        require(block.number > proposal.endBlock, "Voting period has not ended");
        require(proposal.votesFor + proposal.votesAgainst >= quorum, "Quorum not reached");

        return proposal.votesFor > proposal.votesAgainst;
    }
}
