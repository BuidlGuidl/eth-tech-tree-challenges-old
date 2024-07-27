//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
//import { console2 } from "forge-std/console2.sol";

// Vote (signedMessage)

contract SignatureVoting {

    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }

    // Create a way to track if someone has voted on a proposal already
    // Prevents duplicate votes
    mapping(address => mapping(proposalId => bool)) internal voted;

    // A storage array of Proposal structs
    Proposal[] public proposals;

    // Creates a proposal
    function createProposal (bytes32 proposalName) external {
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

    // function decode (bytes32 signedMessage) internal returns(uint256) {

    // }

    // Vote on Proposal
    function vote (bytes32 signedMessage, bytes memory signature) external {
        // Get the address that signed the message
        // Not using msg.sender because the signer may not have sent the transaction
        address voter = recoverSigner(signedMessage, signature);

        // ToDo: Get proposalId from signedMessage
        uint256 proposalId = 0;

        // Check if voter has voted
        require(
            voted[voter][proposalId] == false;
        );

        // Increase proposal vote
        proposals[proposalId].voteCount += 1;

        // Record that voter has voted for proposal
        voted[voter][proposalId] == true;
    }
}
