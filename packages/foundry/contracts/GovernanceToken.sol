// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Governance Token Contract
/// @notice This contract is a basic implementation of an ERC20 token with vote delegation functionality
/// @dev Inherits from OpenZeppelin's ERC20 and Ownable contracts
contract GovernanceToken is ERC20, Ownable {
    mapping(address => address) public delegates;
    mapping(address => uint256) public delegatedVotes;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event VotesDelegated(address indexed fromDelegate, address indexed toDelegate, uint256 amount);
    event VotesUndelegated(address indexed fromDelegate, address indexed toDelegate, uint256 amount);

    constructor() ERC20("Governance Token", "GOV") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    /// @notice Delegate votes to another address
    /// @param to The address to delegate votes to
    /// @dev Ensure `to` is not the same as the caller. Update delegate mappings and move votes.
    /// @custom:requirements 
    /// - `to` cannot be the same as the caller.
    function delegate(address to) external {
        require(to != msg.sender, "Cannot delegate to self");

        address currentDelegate = delegates[msg.sender];
        uint256 delegatorBalance = balanceOf(msg.sender);

        delegates[msg.sender] = to;
        emit DelegateChanged(msg.sender, currentDelegate, to);

        _moveDelegates(currentDelegate, to, delegatorBalance);
    }

    /// @notice Undelegate votes, removing the current delegation
    /// @dev Reset the delegate mapping and move votes back to the caller
    /// @custom:requirements 
    /// - The caller must have previously delegated their votes.
    function undelegate() external {
        address currentDelegate = delegates[msg.sender];
        uint256 delegatorBalance = balanceOf(msg.sender);

        delegates[msg.sender] = address(0);
        emit DelegateChanged(msg.sender, currentDelegate, address(0));

        _moveDelegates(currentDelegate, msg.sender, delegatorBalance);
    }

    /// @dev Internal function to move delegated votes from one delegate to another
    /// @param from The address delegating votes from
    /// @param to The address delegating votes to
    /// @param amount The number of votes being delegated
    function _moveDelegates(address from, address to, uint256 amount) internal {
        if (from != to && amount > 0) {
            if (from != address(0)) {
                delegatedVotes[from] -= amount;
                emit VotesUndelegated(from, to, amount);
            }
            if (to != address(0)) {
                delegatedVotes[to] += amount;
                emit VotesDelegated(from, to, amount);
            }
        }
    }
}
