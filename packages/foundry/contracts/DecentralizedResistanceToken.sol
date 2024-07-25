// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { console2 } from "forge-std/console2.sol";

contract DecentralizedResistanceToken is ERC20, Ownable {
    address public votingContract;
    constructor(uint256 initialSupply) ERC20("DecentralizedResistanceToken", "DRT") {
        _mint(msg.sender, initialSupply);
    }

    function setVotingContract(address _votingContract) external onlyOwner {
        votingContract = _votingContract;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (votingContract != address(0) && from != address(0)) {
            IVoting(votingContract).removeVotes(from);
        }
        super._beforeTokenTransfer(from, to, amount);
    }
}

interface IVoting {
    function removeVotes(address voter) external;
}