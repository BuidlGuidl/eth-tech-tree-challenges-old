// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

////////////////////
// Errors
////////////////////
error MolochRageQuit__ProposalNotApproved();
error MolochRageQuit__UnauthorizedAccess();
error MolochRageQuit__InsufficientShares();
error MolochRageQuit__ZeroAddress();
error MolochRageQuit__InvalidSharesAmount();
error MolochRageQuit__FailedTransfer();
error MolochRageQuit__ProposalNotFound();
error MolochRageQuit__NotEnoughVotes();
error MolochRageQuit__InsufficientETH();
error MolochRageQuit__AlreadyVoted();
error MolochRageQuit__MemberExists();
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
    event SharesExchanged(
        address proposer,
        uint256 ethAmount,
        uint256 shareAmount
    );
    event RageQuit(address member, uint256 shareAmount, uint256 ethAmount);
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event Voted(uint256 proposalId, address voter);

    ///////////////////
    // Modifiers
    ///////////////////
    modifier onlyMember() {
        if (!members[msg.sender]) {
            revert MolochRageQuit__UnauthorizedAccess();
        }
        _;
    }

    modifier onlyContractAddress() {
        if (msg.sender != address(this)) {
            revert MolochRageQuit__UnauthorizedAccess();
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
    ) external onlyMember {
        if (contractAddr == address(0)) {
            revert MolochRageQuit__ZeroAddress();
        }
        if (deadline <= block.timestamp) {
            revert MolochRageQuit__InvalidSharesAmount();
        }

        proposalCount++;
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
    function vote(uint256 proposalId) external onlyMember {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.proposer == address(0)) {
            revert MolochRageQuit__ProposalNotFound();
        }
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
    function executeProposal(uint256 proposalId) external {
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
            revert MolochRageQuit__ProposalNotApproved();
        }

        (bool success, ) = proposal.contractAddr.call{value: proposal.value}(
            proposal.data
        );
        if (!success) {
            revert MolochRageQuit__FailedTransfer();
        }

        emit ProposalExecuted(proposalId);
    }

    /**
     * @dev Exchange ETH for shares after approval.
     * @param proposalId The ID of the approved proposal.
     * Requirements:
     * - The caller must be the proposer of the proposal.
     * - The proposal must be approved.
     * - The amount of ETH sent must match the proposal's ETH amount.
     * Emits a `SharesExchanged` event.
     */
    function exchangeShares(uint256 proposalId) external payable onlyMember {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.proposer != msg.sender || !proposal.approved) {
            revert MolochRageQuit__ProposalNotApproved();
        }
        if (msg.value < proposal.value) {
            revert MolochRageQuit__InsufficientETH();
        }

        totalEth += msg.value;
        totalShares += proposal.value;
        shares[msg.sender] += proposal.value;

        emit SharesExchanged(msg.sender, msg.value, proposal.value);
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
    function rageQuit() external onlyMember {
        uint256 memberShares = shares[msg.sender];
        if (memberShares == 0) {
            revert MolochRageQuit__InsufficientShares();
        }
        uint256 ethAmount = (memberShares * totalEth) / totalShares;
        totalShares -= memberShares;
        totalEth -= ethAmount;
        shares[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: ethAmount}("");
        if (!sent) {
            revert MolochRageQuit__FailedTransfer();
        }
        emit RageQuit(msg.sender, memberShares, ethAmount);
    }

    /**
     * @dev Add a new member to the DAO.
     * @param newMember The address of the new member.
     * Requirements:
     * - Only callable by the contract itself.
     * - The address must not already be a member.
     * - Mark the address as a member.
     * Emits a `MemberAdded` event.
     */
    function addMember(address newMember) external onlyContractAddress {
        if (members[newMember]) {
            revert MolochRageQuit__MemberExists();
        }
        members[newMember] = true;
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
    function removeMember(address member) external onlyContractAddress {
        members[member] = false;
        emit MemberRemoved(member);
    }
}
