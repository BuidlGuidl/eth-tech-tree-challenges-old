//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
//import { console2 } from "forge-std/console2.sol";

contract SignatureVoting {
    // Storage stuff
    struct Voter {
        bool voted;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    // address public chairperson;

    mapping(address => Voter) public voters;
    //mapping(proposals => Voter) public proposalVotes;

    Proposal[] public proposals;

    // Constructor

    // Functions

    // create proposals

    function createProposal (bytes32 proposalName) external {
        // create a proposal
        proposals.push(Proposal({
            name: proposalName,
            voteCount: 0
        }));
    }

    // verify message
    // signed message
    function verify (bytes32 signedMessage) internal {
        // decode message
    }

    function decode (bytes32 signedMessage) internal returns(uint256) {

    }

    // vote on proposal
    function vote (bytes32 signedMessage) external {
        // verify message first
        // verify()

        // decode message to get proposal id
        uint256 proposalId = 0;

        // increase vote
        proposals[proposalId].voteCount += 1;
    }
    //Create a proposal
}
