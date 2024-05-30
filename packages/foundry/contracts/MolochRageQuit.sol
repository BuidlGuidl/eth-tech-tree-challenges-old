//SPDX-License-Identifier: MIT
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
        bool approved;
    }

    ///////////////////
    // State Variables
    ///////////////////
    uint256 public totalShares;
    uint256 public totalEth;
    uint256 public proposalCount;
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
    constructor() {
        members[msg.sender] = true;
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
    function propose(uint256 ethAmount, uint256 shareAmount) external {}

    /**
     * @dev Approve a proposal.
     * @param proposalId The ID of the proposal to approve.
     * Requirements:
     * - Caller must be a member.
     * - The proposal must not be already approved.
     * Emits a `ProposalApproved` event.
     */
    function approveProposal(uint256 proposalId) external onlyMember {}

    /**
     * @dev Exchange ETH for shares after approval.
     * @param proposalId The ID of the approved proposal.
     * Requirements:
     * - The caller must be the proposer of the proposal.
     * - The proposal must be approved.
     * - The amount of ETH sent must match the proposal's ETH amount.
     * Emits a `SharesExchanged` event.
     */
    function exchangeShares(uint256 proposalId) external payable {}

    /**
     * @dev Rage quit and exchange shares for ETH.
     * Requirements:
     * - The caller must have shares.
     * Emits a `RageQuit` event.
     */
    function rageQuit() external {}
}
