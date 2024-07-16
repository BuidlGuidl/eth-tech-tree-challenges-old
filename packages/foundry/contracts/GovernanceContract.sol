// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GovernanceToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceContract is Ownable {
    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 endBlock;
        uint256 votesFor;
        uint256 votesAgainst;
        mapping(address => bool) hasVoted;
    }

    GovernanceToken public token;
    uint256 public proposalCount;
    uint256 public quorum;
    uint256 public proposalThreshold;
    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 id, address proposer, string description);
    event VoteCast(address voter, uint256 proposalId, bool support);

    constructor(address tokenAddress, uint256 _quorum, uint256 _proposalThreshold) {
        token = GovernanceToken(tokenAddress);
        quorum = _quorum;
        proposalThreshold = _proposalThreshold;
    }

    function createProposal(string calldata description) external {
        require(token.balanceOf(msg.sender) >= proposalThreshold, "Not enough tokens to create proposal");

        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        proposal.id = proposalCount;
        proposal.proposer = msg.sender;
        proposal.description = description;
        proposal.endBlock = block.number + 100; // Example duration

        emit ProposalCreated(proposalCount, msg.sender, description);
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.number < proposal.endBlock, "Voting period has ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");

        uint256 weight = token.balanceOf(msg.sender) + token.delegatedVotes(msg.sender);
        require(weight > 0, "No voting power");

        if (support) {
            proposal.votesFor += weight;
        } else {
            proposal.votesAgainst += weight;
        }

        proposal.hasVoted[msg.sender] = true;
        emit VoteCast(msg.sender, proposalId, support);
    }

    function proposalResult(uint256 proposalId) external view returns (bool passed) {
        Proposal storage proposal = proposals[proposalId];
        require(block.number >= proposal.endBlock, "Voting period not ended");

        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        if (totalVotes < quorum) {
            return false;
        }
        return proposal.votesFor > proposal.votesAgainst;
    }
}
