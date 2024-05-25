// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Dont touch this contract
contract DecentralizedResistanceToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("DecentralizedResistanceToken", "DRT") {
        _mint(msg.sender, initialSupply);
    }
}
