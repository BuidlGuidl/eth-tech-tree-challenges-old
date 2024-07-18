// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

////////////////////
// Errors
////////////////////
error MolochRageQuit__NotAMamber();
error MolochRageQuit__ZeroAddress();
error MolochRageQuit__AlreadyVoted();
error MolochRageQuit__MemberExists();
error MolochRageQuit__FailedTransfer();
error MolochRageQuit__NotEnoughVotes();
error MolochRageQuit__InsufficientETH();
error MolochRageQuit__FailedToExecute();
error MolochRageQuit__ProposalNotFound();
error MolochRageQuit__UnauthorizedAccess();
error MolochRageQuit__InsufficientShares();
error MolochRageQuit__InvalidDeadline();
error MolochRageQuit__ProposalNotApproved();
error MolochRageQuit__ProposalDeadlineNotReached();

////////////////////
// Contract
////////////////////
contract MolochRageQuit {
    ///////////////////
    // Type Declarations
    ///////////////////
    struct Proposal {
        address proposer;
        address contractAddr;
        bytes data;
        uint256 value;
        uint256 votes;
        uint256 deadline;
        bool approved;
        mapping(address => bool) voted;
    }

    ///////////////////
    // State Variables
    ///////////////////
    uint256 public totalShares;
    uint256 public totalEth;
    uint256 public proposalCount;
    uint256 public quorum;
    mapping(address => uint256) public shares;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;

    ///////////////////
    // Events
    ///////////////////
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address contractAddr,
        bytes data,
        uint256 value,
        uint256 deadline
    );
    event ProposalApproved(uint256 proposalId, address approver);
    event ProposalExecuted(uint256 proposalId);
    event RageQuit(address member, uint256 shareAmount);
    event MemberAdded(address member);
    event Voted(uint256 proposalId, address voter);
    event ProposalValueRefunded(address proposer, uint256 amount);

    ///////////////////
    // Modifiers
    ///////////////////
    modifier onlyMember(address _member) {
        if (!members[_member]) {
            revert MolochRageQuit__NotAMamber();
        }
        _;
    }

    modifier onlyContractAddress() {
        if (msg.sender != address(this)) {
            revert MolochRageQuit__UnauthorizedAccess();
        }
        _;
    }
    modifier proposalExists(uint256 proposalId) {
        if (proposalId > proposalCount) {
            revert MolochRageQuit__ProposalNotFound();
        }
        _;
    }

    ///////////////////
    // Constructor
    ///////////////////
    constructor(uint256 _quorum) {
        members[msg.sender] = true;
        quorum = _quorum;
    }

    ///////////////////
    // External Functions
    ///////////////////

    /**
     * @dev Propose a transaction.
     * @param contractAddr The address of the contract to call.
     * @param data The calldata for the transaction.
     * @param value The ETH value to send with the transaction.
     * @param deadline The timestamp until when the proposal is valid.
     * Requirements:
     * - `contractAddr` cannot be the zero address. Reverts with MolochRageQuit__ZeroAddress if the contract address is zero.
     * - `deadline` should be in the future. Reverts with MolochRageQuit__InvalidDeadline if the deadline is in the past.
     * - `msg.value` must be at least  `value`. Reverts with MolochRageQuit__InsufficientETH if insufficient ETH is sent.
     * - Increment the proposal count.
     * - Create a new proposal.
     * Emits a `ProposalCreated` event.
     */
    function propose(
        address contractAddr,
        bytes memory data,
        uint256 value,
        uint256 deadline
    ) external payable {
        if (contractAddr == address(0)) {
            revert MolochRageQuit__ZeroAddress();
        }
        if (deadline <= block.timestamp) {
            revert MolochRageQuit__InvalidDeadline();
        }
        if (msg.value < value) {
            revert MolochRageQuit__InsufficientETH();
        }

        proposalCount++;
        totalEth += msg.value;
        Proposal storage proposal = proposals[proposalCount];
        proposal.proposer = msg.sender;
        proposal.contractAddr = contractAddr;
        proposal.data = data;
        proposal.value = value;
        proposal.deadline = deadline;

        emit ProposalCreated(
            proposalCount,
            msg.sender,
            contractAddr,
            data,
            value,
            deadline
        );
    }

    /**
     * @dev Vote on a proposal.
     * @param proposalId The ID of the proposal to vote on.
     * Requirements:
     * - The proposal must exist. use proposalExists modifier to check if there is a proposal.
     * - Caller must be a member. make use of onlyMember modifier.
     * - Caller must not have already voted on the proposal. Reverts with MolochRageQuit__AlreadyVoted if the caller has already voted.
     * - Increment the proposal's vote count.
     * - Mark the caller as having voted on the proposal.
     * - If the proposal has enough votes, mark it as approved.
     * Emits a `Voted` event.
     * Emits a `ProposalApproved` event if the proposal is approved.
     */
    function vote(
        uint256 proposalId
    ) external onlyMember(msg.sender) proposalExists(proposalId) {
        Proposal storage proposal = proposals[proposalId];

        if (proposal.voted[msg.sender]) {
            revert MolochRageQuit__AlreadyVoted();
        }

        proposal.votes++;
        proposal.voted[msg.sender] = true;

        emit Voted(proposalId, msg.sender);

        if (proposal.votes >= quorum) {
            proposal.approved = true;
            emit ProposalApproved(proposalId, msg.sender);
        }
    }

    /**
     * @dev Execute an approved proposal after the deadline.
     * @param proposalId The ID of the proposal to execute.
     * Requirements:
     * - The proposal must be approved. Use proposalExists modifier to check if there is a proposal.
     * - The proposal deadline must be over. Reverts with MolochRageQuit__ProposalDeadlineNotReached if the deadline is not reached.
     * - Execute the calldata with the value.
     * - If the proposal is rejected: if the deadline has passed but it has not been approved, refund any value deposited. Reverts with MolochRageQuit__FailedTransfer if the transfer fails.
     * - Emit a `ProposalValueRefunded` event if the proposal is not approved.
     * - if the proposal is approved and the deadline has passed: execute the calldata with the value. Reverts with MolochRageQuit__FailedToExecute if the execution fails.
     * - Emit a `ProposalExecuted` event if the proposal is executed.
     */
    function executeProposal(
        uint256 proposalId
    ) external proposalExists(proposalId) {
        Proposal storage proposal = proposals[proposalId];

        if (block.timestamp < proposal.deadline) {
            revert MolochRageQuit__ProposalDeadlineNotReached();
        }

        if (!proposal.approved) {
            // Refund the value to the proposer if the proposal is not approved
            if (proposal.value > 0) {
                (bool refunded, ) = proposal.proposer.call{
                    value: proposal.value
                }("");
                if (!refunded) {
                    revert MolochRageQuit__FailedTransfer();
                }
            }
            emit ProposalValueRefunded(proposal.proposer, proposal.value);
        } else {
            if (proposal.contractAddr != address(this)) {
                (bool success, ) = proposal.contractAddr.call{
                    value: proposal.value
                }(proposal.data);
                if (!success) {
                    revert MolochRageQuit__FailedToExecute();
                }
            } else {
                (bool success, ) = proposal.contractAddr.call(proposal.data);
                if (!success) {
                    revert MolochRageQuit__FailedToExecute();
                }
            }

            emit ProposalExecuted(proposalId);
        }
    }

    /**
     * @dev Add a new member to the DAO.
     * @param newMember The address of the new member.
     * @param proposalId The ID of the approved proposal which is the current proposalCount + 1.
     * Requirements:
     * - Only callable by the contract itself. Reverts with MolochRageQuit__UnauthorizedAccess if called by any other address.
     * - The proposal must be approved. Reverts with MolochRageQuit__ProposalNotApproved if the proposal is not approved.
     * - The address must not already be a member. Reverts with MolochRageQuit__MemberExists if the address is already a member.
     * - Mark the address as a member.
     * - Increment the total shares by adding proposal value.
     * - Set the shares of the new member to the proposal value.
     * Emits a `MemberAdded` event.
     */
    function addMember(
        address newMember,
        uint256 proposalId
    ) external onlyContractAddress {
        Proposal storage proposal = proposals[proposalId];
        if (!proposal.approved) {
            revert MolochRageQuit__ProposalNotApproved();
        }
        if (members[newMember]) {
            revert MolochRageQuit__MemberExists();
        }
        members[newMember] = true;
        totalShares += proposal.value;
        shares[newMember] = proposal.value;
        emit MemberAdded(newMember);
    }

    /**
     * @dev Rage quit and exchange shares for ETH.
     * Requirements:
     * - The address must be a member. make use of onlyMember modifier.
     * - Reverts with MolochRageQuit__FailedTransfer if the transfer fails.
     * - Calculate the amount of ETH to return to the caller.
     * - Update the total shares and total ETH.
     * - Mark the caller as having 0 shares.
     * - Transfer the ETH to the caller.
     * - Mark member as non member(revoke membership).
     * Emits a `RageQuit` event.
     */
    function rageQuit(address member) public onlyMember(member) {
        uint256 memberShare = shares[member];
        totalEth -= memberShare;
        shares[member] = 0;
        (bool sent, ) = payable(member).call{value: memberShare}("");
        if (!sent) {
            revert MolochRageQuit__FailedTransfer();
        }
        members[member] = false;
        emit RageQuit(member, memberShare);
    }
}
