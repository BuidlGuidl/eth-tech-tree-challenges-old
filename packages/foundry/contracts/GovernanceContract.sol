// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./GovernanceToken.sol";
import "forge-std/console.sol";

/// @title Governance Contract
/// @author BUIDL GUIDL
/// @notice This contract handles the governance mechanism including proposal creation and voting
/// @dev Uses a GovernanceToken for vote delegation
contract GovernanceContract is Ownable {

    ///////////////////
    // Errors
    ///////////////////

    /// @dev Thrown when the caller doesn't have enough votes to create a proposal.
    error NotEnoughVotes();

    /// @dev Thrown when the voting period for a proposal has ended.
    error VotingPeriodEnded();

    /// @dev Thrown when the caller has already voted on a proposal.
    error AlreadyVoted();

    /// @dev Thrown when the caller has no votes available to cast.
    error NoVotesAvailable();

    /// @dev Thrown when the voting period has not yet ended.
    error VotingPeriodNotEnded();

    /// @dev Thrown when a proposal does not meet the quorum requirement.
    error QuorumNotReached();

    ///////////////////
    // Type Declarations
    ///////////////////

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

    ///////////////////
    // State Variables
    ///////////////////

    GovernanceToken public governanceToken;
    uint256 public proposalCount;
    uint256 public proposalThreshold;
    uint256 public quorum;
    uint256 public votingPeriod;

    mapping(uint256 => Proposal) public proposals;

    ///////////////////
    // Events
    ///////////////////

    event ProposalCreated(uint256 id, address proposer, string description, uint256 endBlock);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalResult(uint256 proposalId, bool passed);

    ///////////////////
    // Constructor
    ///////////////////

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

    ///////////////////
    // Public Functions
    ///////////////////

    /// @notice Create a new governance proposal
    /// @param deadline The block number at which voting ends for the proposal
    /// @param description The description of the proposal
    /// @custom:requirements
    /// - Should revert with `NotEnoughVotes` if the caller's total votes (own + delegated) do not meet the proposal threshold.
    /// - Must increment `proposalCount`.
    /// - Must create a `Proposal` struct with the expected properties (id, proposer, description, endBlock, votesFor, votesAgainst, executed).
    /// - Must emit `ProposalCreated` with the expected properties (id, proposer, description, endBlock).
    function createProposal(uint256 deadline, string calldata description) external {
        uint256 totalVotes = governanceToken.balanceOf(msg.sender) + governanceToken.delegatedVotes(msg.sender);
        if (totalVotes < proposalThreshold) {
            revert NotEnoughVotes();
        }

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
    /// @custom:requirements
    /// - Should revert with `VotingPeriodEnded` if the current block is greater than `proposal.endBlock`.
    /// - Should revert with `AlreadyVoted` if the caller has already voted on this proposal.
    /// - Should revert with `NotEnoughVotes` if the caller has no votes available (own + delegated).
    /// - Must update `votesFor` or `votesAgainst` based on the `support` parameter.
    /// - Must mark the caller as having voted on this proposal.
    /// - Must emit `Voted` with the expected properties (proposalId, voter, support).
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        if (block.number > proposal.endBlock) {
            revert VotingPeriodEnded();
        }
        if (proposal.voted[msg.sender]) {
            revert AlreadyVoted();
        }

        uint256 votes = governanceToken.balanceOf(msg.sender) + governanceToken.delegatedVotes(msg.sender);
        if (votes == 0) {
            revert NotEnoughVotes();
        }

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
    /// @custom:requirements
    /// - Should revert with `VotingPeriodNotEnded` if the current block is less than or equal to `proposal.endBlock`.
    /// - Should revert with `QuorumNotReached` if the total votes (votesFor + votesAgainst) are less than the quorum.
    /// - Must return `true` if `votesFor` is greater than `votesAgainst`, otherwise return `false`.
    function proposalResult(uint256 proposalId) public view returns (bool passed) {
        Proposal storage proposal = proposals[proposalId];
        if (block.number <= proposal.endBlock) {
            revert VotingPeriodNotEnded();
        }
        if (proposal.votesFor + proposal.votesAgainst < quorum) {
            revert QuorumNotReached();
        }

        return proposal.votesFor > proposal.votesAgainst;
    }


    /// @notice Sets the quorum required for proposals to be accepted.
    /// @dev This function can only be called by the owner of the contract. The quorum is set as a percentage of the total supply of the governance token, which determines the minimum amount of votes required for a proposal to pass.
    /// @param _quorum The new quorum value to set, expressed in the smallest unit of the governance token. The value should be set considering the token's decimal places.     
    /// @custom:requirements
    /// - The caller must be the owner of the contract.
    function setQuorum(uint256 _quorum) public onlyOwner {
        quorum = _quorum;
    }

}
