// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

///////////////////////////////////////////////////////////////
//                               IMPORTS
///////////////////////////////////////////////////////////////
import { console2 } from "forge-std/console2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


///////////////////////////////////////////////////////////////
//                                ERRORS
///////////////////////////////////////////////////////////////
error UnAuthorized_MembersOnly();
error InvalidChoice();
error DuplicateVoting();
error VotingPeriodOver();
error VotingInProgress();

///////////////////////////////////////////////////////////////
//                        TYPE DECLARATIONS
///////////////////////////////////////////////////////////////
enum Choice {
    NAY,
    YEA,
    ABSTAIN
}

struct Proposal {
    uint id;
    string title;
    uint votingDeadline;
    address creator;
}

///////////////////////////////////////////////////////////////
//                               CONTRACT
///////////////////////////////////////////////////////////////
contract Governance {
    ///////////////////////////////////////////////////////////////
    //                       STATE VARIABLES
    ///////////////////////////////////////////////////////////////
    // Token contract interface
    IERC20 public voteToken;
    uint public votingPeriod;
    uint private nonce;
    // Tracks whether an address has voted
    mapping(uint => mapping(address => bool)) public hasVoted;
    // Tracks what choice an address has voted on the proposal
    mapping(uint => mapping(address => Choice)) public choice;
    // Tracks proposals created by members
    mapping(uint => Proposal) public proposals;
    // Total votes in favor of the proposal
    mapping(uint => uint) public votesFor;
    // Total votes against the proposal
    mapping(uint => uint) public votesAgainst;
    // Total votes to abstain
    mapping(uint => uint) public votesAbstain;

    ///////////////////////////////////////////////////////////////
    //                            EVENTS
    ///////////////////////////////////////////////////////////////
    // Event emitted when a vote is cast
    event VoteCasted(uint proposalId, address indexed voter, Choice vote, uint weight);
    // Event emitted when a proposal is created
    event ProposalCreated(uint proposalId, string title, uint votingDeadline, address creator);

    ///////////////////////////////////////////////////////////////
    //                          MODIFIERS
    ///////////////////////////////////////////////////////////////
    /**
     * @notice Modifier to restrict access to only the token holders
     * Requirements:
     * - Reverts with `UnAuthorized_MembersOnly` if the caller is not a token holder
     */
    modifier onlyMembers() {     

        _;
    }

    ///////////////////////////////////////////////////////////////
    //                        CONSTRUCTOR
    ///////////////////////////////////////////////////////////////
    /**
    * @notice Constructor to initialize the governance contract
    * @param _tokenAddress The address of the ERC20 token contract
    * @param _votingPeriod The duration of the voting period in seconds
    */
    constructor(address _tokenAddress, uint _votingPeriod) {
        voteToken = IERC20(_tokenAddress);
        votingPeriod = _votingPeriod;
    }

    ///////////////////////////////////////////////////////////////
    //                      EXTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////////////
    /**
     * @notice Function to create a new proposal
     * @dev Only members (token holders) can create proposals
     * @param _title The title of the proposal
     * @return proposalId The unique ID of the newly created proposal
     * Requirements:
     * - Only callable by members
     * - Creates a new Proposal with a unique ID using the nonce
     * - Increments the nonce
     * - Adds the new proposal to `proposals`
     * - Emits a `ProposalCreated` event
     * - Returns the proposal ID
     */
    function propose(string memory _title) external onlyMembers returns(uint) {

    }

    /**
     * @notice Function to cast a vote on a proposal
     * @dev Only members (token holders) can vote
     * @param _proposalId The ID of the proposal to vote on
     * @param _support The choice of the voter (YEA, NAY, ABSTAIN)
     * Requirements:
     * - Only callable by members.
     * - should revert with `InvalidChoice` if `uint(_support)` is not 0, 1, or 2
     * - should revert with `VotingPeriodOver` if current timestamp is over proposal's voting deadline
     * - should revert with `DuplicateVoting` if caller already voted for the specified proposal
     * - Add voter weight (caller token balance) to the appropriate choice for the proposal i.e votesFor, votesAgainst, votesAbstain
     * - Mark the voter as having voted
     * - Record voter choice
     * - Emits a `VoteCasted` event
     */
    function vote(uint _proposalId, Choice _support) external onlyMembers {

    }

    /**
     * @notice Function to get the vote of a specific address on a specific proposal
     * @param _proposalId The ID of the proposal
     * @param _voter The address of the voter
     * @return The choice of the voter (YEA, NAY, ABSTAIN)
     * Requirements:
     * - Return the choice of the voter for the specified proposal
     */
    function getVote(uint _proposalId, address _voter) external view returns (Choice) {

    }

    /**
     * @notice Function to get the result of a proposal vote
     * @param _proposalId The ID of the proposal
     * @return True if the votes in favor are greater than the votes against, otherwise false
     * Requirements:
     * - should revert with `VotingInProgress` if current timestamp is less than or equal to proposal's voting deadline
     * - Return true if votesFor is greater than votesAgainst, otherwise false
     */
    function getResult(uint _proposalId) external view returns (bool) {

    }
}