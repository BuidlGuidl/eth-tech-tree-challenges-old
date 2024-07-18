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
    event MemberRemoved(address member);
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
     * - `contractAddr` should not be zero address.
     * - `deadline` should be in the future.
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
     * - Revert with ` MolochRageQuit__ProposalNotFound` if the proposal does not exist.
     * - Revert with ` MolochRageQuit__AlreadyVoted` if the caller has already voted on the proposal.
     * - Caller must be a member.
     * - Proposal must exist.
     * - Caller must not have already voted on the proposal.
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
     * - The proposal must be approved.
     * - The proposal deadline must be over.
     * - Execute the calldata with the value.
     * - If the proposal is rejected, refund any value deposited.
     * Emits a `ProposalExecuted` event.
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
     * @dev Rage quit and exchange shares for ETH.
     * Requirements:
     * - The caller must have shares and must be a member.
     * - Calculate the amount of ETH to return to the caller.
     * - Update the total shares and total ETH.
     * - Mark the caller as having 0 shares.
     * - Transfer the ETH after calculating the share of eth to send to the caller.
     * - Revert with ` MolochRageQuit__FailedTransfer` if the transfer fails.
     * Emits a `RageQuit` event.
     */
    function __rageQuit(address member) private onlyContractAddress {
        uint256 memberShare = shares[member];
        if (memberShare == 0) {
            revert MolochRageQuit__InsufficientShares();
        }

        totalEth -= memberShare;
        shares[member] = 0;
        (bool sent, ) = payable(member).call{value: memberShare}("");
        if (!sent) {
            revert MolochRageQuit__FailedTransfer();
        }
        emit RageQuit(member, memberShare);
    }

    /**
     * @dev Add a new member to the DAO.
     * @param newMember The address of the new member.
     * @param proposalId The ID of the approved proposal.
     * Requirements:
     * - Only callable by the contract itself.
     * - The proposal must be approved.
     * - The address must not already be a member.
     * - Mark the address as a member.
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
     * @dev Remove a member from the DAO.
     * @param member The address of the member to remove.
     * Requirements:
     * - Only callable by the contract itself.
     * - Mark the member as not a member.
     * Emits an `MemberRemoved` event.
     */
    function removeMember(
        address member
    ) external onlyContractAddress onlyMember(member) {
        __rageQuit(member);
        members[member] = false;
        emit MemberRemoved(member);
    }
}
