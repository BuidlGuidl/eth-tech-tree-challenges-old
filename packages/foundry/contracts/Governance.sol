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
    bytes32 id;
    string title;
    uint256 votingDeadline;
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

    ///////////////////////////////////////////////////////////////
    //                            EVENTS
    ///////////////////////////////////////////////////////////////
    // Event emitted when a vote is cast
    event VoteCasted(bytes32 proposalId, address indexed voter, Choice vote, uint256 weight);
    // Event emitted when a proposal is created
    event ProposalCreated(bytes32 proposalId, string title, uint256 votingDeadline, address creator);

    ///////////////////////////////////////////////////////////////
    //                          MODIFIERS
    ///////////////////////////////////////////////////////////////
    /**
     * @notice Modifier to restrict access to only the token holders
     */
    modifier onlyMembers() {     
        if(voteToken.balanceOf(msg.sender) == 0) {
            revert UnAuthorized_MembersOnly();
        }
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
    constructor(address _tokenAddress, uint256 _votingPeriod) {
        voteToken = IERC20(_tokenAddress);
        votingPeriod = _votingPeriod;
        nonce = 0;
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
     * - Only callable by members.
     * - Creates a new Proposal
     * - Adds new proposal to `proposals`
     * Emits a `ProposalCreated` event.
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
     * Requirements:
     * - Only callable by members.
     * - should revert with `InvalidChoice` if `uint(_support)` is not 0, 1, or 2.
     * - should revert with `VotingPeriodOver` if current timestamp is over proposal's voting deadline.
     * - should revert with `DuplicateVoting` if caller already voted for the specified proposal
     * - Add voter weight (caller token balance) to the appropriate choice for the proposal i.e votesFor, votesAgainst, votesAbstain
     * - Mark the voter as having voted
     * - Record voter choice
     * Emits a `VoteCasted` event.
     */
    function vote(bytes32 _proposalId, Choice _support) external onlyMembers {
        if(uint(_support) > uint(Choice.ABSTAIN)){
            revert InvalidChoice();
        }
        if(block.timestamp > proposals[_proposalId].votingDeadline){
            revert VotingPeriodOver();
        }
        if(hasVoted[_proposalId][msg.sender] == true){
            revert DuplicateVoting();
        }
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
     * @notice Function to get the vote of a specific address on a specific proposal
     * @param _proposalId The ID of the proposal
     * @param _voter The address of the voter
     * @return The choice of the voter (YEA, NAY, ABSTAIN)
     */
    function getVote(bytes32 _proposalId, address _voter) external view returns (Choice) {
        return choice[_proposalId][_voter];
    }

    /**
     * @notice Function to get the result of a proposal vote
     * @param _proposalId The ID of the proposal
     * @return True if the votes in favor are greater than the votes against, otherwise false
     * * Requirements:
     * - should revert with `VotingInProgress` if current timestamp is less than or equal to proposal's voting deadline
     */
    function getResult(bytes32 _proposalId) external view returns (bool) {
        if(block.timestamp <= proposals[_proposalId].votingDeadline){
            revert VotingInProgress();
        }
        return votesFor[_proposalId] > votesAgainst[_proposalId];
    }
}