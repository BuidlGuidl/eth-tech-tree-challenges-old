// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

////////////////////
// Imports
////////////////////
import "@openzeppelin/contracts/access/Ownable.sol";

////////////////////
// Errors
////////////////////
error InsufficientETH();
error ProposalNotApproved();
error UnauthorizedAccess();
error InsufficientShares();
error ZeroAddress();
error InvalidSharesAmount();
error AlreadyApproved();
error ReentrancyDetected();
error ProposalNotFound();
error NotEnoughVotes();
error AlreadyVoted();
error MemberExists();

////////////////////
// Contract
////////////////////
contract MolochRageQuit is Ownable {
    ///////////////////
    // Type Declarations
    ///////////////////
    struct Proposal {
        address proposer;
        uint256 ethAmount;
        uint256 shareAmount;
        uint256 votes;
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
        uint256 ethAmount,
        uint256 shareAmount
    );
    event ProposalApproved(uint256 proposalId, address approver);
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
            revert UnauthorizedAccess();
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
     * @dev Propose to acquire shares for ETH.
     * @param ethAmount The amount of ETH to exchange for shares.
     * @param shareAmount The amount of shares to acquire.
     * Requirements:
     * - `ethAmount` must be greater than 0.
     * - `shareAmount` must be greater than 0.
     * Emits a `ProposalCreated` event.
     */
    function propose(uint256 ethAmount, uint256 shareAmount) external {
        if (ethAmount == 0 || shareAmount == 0) {
            revert InvalidSharesAmount();
        }

        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        proposal.proposer = msg.sender;
        proposal.ethAmount = ethAmount;
        proposal.shareAmount = shareAmount;

        emit ProposalCreated(proposalCount, msg.sender, ethAmount, shareAmount);
    }

    /**
     * @dev Vote on a proposal.
     * @param proposalId The ID of the proposal to vote on.
     * Requirements:
     * - Caller must be a member.
     * - Proposal must exist.
     * - Caller must not have already voted on the proposal.
     * Emits a `Voted` event.
     */
    function vote(uint256 proposalId) external onlyMember {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.proposer == address(0)) {
            revert ProposalNotFound();
        }
        if (proposal.voted[msg.sender]) {
            revert AlreadyVoted();
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
     * @dev Exchange ETH for shares after approval.
     * @param proposalId The ID of the approved proposal.
     * Requirements:
     * - The caller must be the proposer of the proposal.
     * - The proposal must be approved.
     * - The amount of ETH sent must match the proposal's ETH amount.
     * Emits a `SharesExchanged` event.
     */
    function exchangeShares(uint256 proposalId) external payable {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.proposer != msg.sender || !proposal.approved) {
            revert ProposalNotApproved();
        }
        if (msg.value < proposal.ethAmount) {
            revert InsufficientETH();
        }

        totalEth += msg.value;
        totalShares += proposal.shareAmount;
        shares[msg.sender] += proposal.shareAmount;

        emit SharesExchanged(msg.sender, msg.value, proposal.shareAmount);
    }

    /**
     * @dev Rage quit and exchange shares for ETH.
     * Requirements:
     * - The caller must have shares.
     * Emits a `RageQuit` event.
     */
    function rageQuit() external {
        uint256 memberShares = shares[msg.sender];
        if (memberShares == 0) {
            revert InsufficientShares();
        }

        uint256 ethAmount = (memberShares * totalEth) / totalShares;
        totalShares -= memberShares;
        totalEth -= ethAmount;
        shares[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: ethAmount}("");
        if (!sent) {
            revert ReentrancyDetected();
        }

        emit RageQuit(msg.sender, memberShares, ethAmount);
    }

    /**
     * @dev Add a new member to the DAO.
     * @param newMember The address of the new member.
     * Requirements:
     * - Only callable by the owner.
     * - The address must not already be a member.
     * Emits a `MemberAdded` event.
     */
    function addMember(address newMember) external onlyOwner {
        if (members[newMember]) {
            revert MemberExists();
        }
        members[newMember] = true;
        emit MemberAdded(newMember);
    }

    /**
     * @dev Remove a member from the DAO.
     * @param member The address of the member to remove.
     * Requirements:
     * - Only callable by the owner.
     * Emits a `MemberRemoved` event.
     */
    function removeMember(address member) external onlyOwner {
        members[member] = false;
        emit MemberRemoved(member);
    }

    /**
     * @dev Withdraw ETH from the DAO.
     * @param amount The amount of ETH to withdraw.
     * Requirements:
     * - Only callable by the owner.
     */
    function withdraw(uint256 amount) external onlyOwner {
        if (amount > address(this).balance) {
            revert InsufficientETH();
        }
        (bool sent, ) = msg.sender.call{value: amount}("");
        if (!sent) {
            revert ReentrancyDetected();
        }
    }
}
