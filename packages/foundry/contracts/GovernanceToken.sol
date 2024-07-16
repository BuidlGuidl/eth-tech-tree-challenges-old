// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20, Ownable {
    mapping(address => address) public delegation;
    mapping(address => uint256) public delegatedVotes;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function delegate(address to) external {
        address delegator = msg.sender;
        uint256 balance = balanceOf(delegator);

        require(balance > 0, "No tokens to delegate");

        if (delegation[delegator] != address(0)) {
            _undelegate(delegator);
        }

        delegation[delegator] = to;
        delegatedVotes[to] += balance;
    }

    function undelegate() external {
        address delegator = msg.sender;
        _undelegate(delegator);
    }

    function _undelegate(address delegator) internal {
        address currentDelegate = delegation[delegator];
        uint256 balance = balanceOf(delegator);

        require(currentDelegate != address(0), "No delegation to revoke");

        delegation[delegator] = address(0);
        delegatedVotes[currentDelegate] -= balance;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        address sender = _msgSender();

        if (delegation[sender] != address(0)) {
            delegatedVotes[delegation[sender]] -= amount;
        }

        if (delegation[recipient] != address(0)) {
            delegatedVotes[delegation[recipient]] += amount;
        }

        return super.transfer(recipient, amount);
    }
}
