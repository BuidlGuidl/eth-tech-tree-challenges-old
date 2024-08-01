//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
//import { console2 } from "forge-std/console2.sol";

contract SignatureVoting {

    struct Proposal {
        string name;
        uint256 voteCount;
    }

    // Create a way to track if someone has voted on a proposal already
    mapping(address => mapping(uint256 => bool)) internal voted;

    // A storage array of Proposal structs
    Proposal[] public proposals;

    // Creates a proposal
    function createProposal (string memory proposalName) external {
        proposals.push(Proposal({
            name: proposalName,
            voteCount: 0
        }));
    }

    // Create a function to recover the signer from a signed message
    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    // Split the signature into "r", "s", and "v" parameters for 'recoverSigner'
    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    // Create a function to vote on a proposal
    function vote (bytes32 signedMessage, bytes32 hashedMessage, uint256 proposalId) public {
        // Get the address that signed the message
        // Not using msg.sender because the signer may not have sent the transaction
        address voter = recoverSigner(signedMessage, abi.encodePacked(hashedMessage));

        // Prevent duplicate votes from voter
        require(voted[voter][proposalId] == false, "Voter already voted for this proposal!");

        // Verify hashed message is same as message
        require(hashedMessage == keccak256(abi.encodePacked(proposalId)), "Vote: Messages don't match!");

        // Increase by one vote for the proposal
        proposals[proposalId].voteCount += 1;

        // Record that voter has voted for proposal
        voted[voter][proposalId] == true;
    }

    // Query if voter voted on a proposal
    function queryVoted (address voter, uint256 proposalId) public returns(bool) {
        return voted[voter][proposalId];
    }

    // Create a function to get name of a proposal by proposalId
    function getProposalName (uint256 _proposalId) public returns(string memory) {
        Proposal storage proposal = proposals[_proposalId];
        return proposal.name;
    }
}
