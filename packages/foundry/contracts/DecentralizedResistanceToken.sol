// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { console2 } from "forge-std/console2.sol";

contract DecentralizedResistanceToken is ERC20, Ownable {
    address public votingContract;
    constructor(uint256 initialSupply) ERC20("Decentralized Resistance Token", "DRT") {
        _mint(msg.sender, initialSupply);
    }
}
