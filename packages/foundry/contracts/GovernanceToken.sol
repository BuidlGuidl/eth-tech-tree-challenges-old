// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Governance Token Contract
/// @author BUIDL GUIDL
/// @notice This contract is a basic implementation of an ERC20 token with vote delegation functionality
/// @dev Inherits from OpenZeppelin's ERC20 and Ownable contracts
contract GovernanceToken is ERC20, Ownable {

    ///////////////////
    // Errors
    ///////////////////

    /// @dev Thrown when the caller attempts to delegate votes to themselves.
    error SelfDelegationNotAllowed();

    /// @dev Thrown when the caller attempts to undelegate votes without a prior delegation.
    error NoDelegationToRevoke();

    ///////////////////
    // State Variables
    ///////////////////

    mapping(address => address) public delegates;
    mapping(address => uint256) public delegatedVotes;

    ///////////////////
    // Events
    ///////////////////

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event VotesDelegated(address indexed fromDelegate, address indexed toDelegate, uint256 amount);
    event VotesUndelegated(address indexed fromDelegate, address indexed toDelegate, uint256 amount);

    ///////////////////
    // Constructor
    ///////////////////

    constructor() ERC20("Governance Token", "GOV") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    ///////////////////
    // Public Functions
    ///////////////////

    /// @notice Delegate votes to another address
    /// @param to The address to delegate votes to
    /// @custom:requirements:
    /// - Should revert with `SelfDelegationNotAllowed` if `to` is the same as the caller.
    /// - Must update the `delegates` mapping with the new delegate address.
    /// - Must call `_moveDelegates` to transfer the caller's vote balance from the current delegate (if any) to the new delegate.
    /// - Must emit `DelegateChanged` with the expected properties (delegator, fromDelegate, toDelegate).
    function delegate(address to) external {
        if (to == msg.sender) {
            revert SelfDelegationNotAllowed();
        }

        address currentDelegate = delegates[msg.sender];
        uint256 delegatorBalance = balanceOf(msg.sender);

        delegates[msg.sender] = to;
        emit DelegateChanged(msg.sender, currentDelegate, to);

        _moveDelegates(currentDelegate, to, delegatorBalance);
    }

    /// @notice Undelegate votes, removing the current delegation
    /// @custom:requirements:
    /// - Should revert with `NoDelegationToRevoke` if the caller has not previously delegated their votes.
    /// - Must reset the `delegates` mapping to address(0).
    /// - Must call `_moveDelegates` to transfer the caller's vote balance from the current delegate back to the caller.
    /// - Must emit `DelegateChanged` with the expected properties (delegator, fromDelegate, address(0)).
    function undelegate() external {
        address currentDelegate = delegates[msg.sender];
        if (currentDelegate == address(0)) {
            revert NoDelegationToRevoke();
        }

        uint256 delegatorBalance = balanceOf(msg.sender);

        delegates[msg.sender] = address(0);
        emit DelegateChanged(msg.sender, currentDelegate, address(0));

        _moveDelegates(currentDelegate, msg.sender, delegatorBalance);
    }

    ///////////////////
    // Internal Functions
    ///////////////////

    /// @dev Internal function to move delegated votes from one delegate to another
    /// @param from The address delegating votes from
    /// @param to The address delegating votes to
    /// @param amount The number of votes being delegated
    /// @custom:requirements:
    /// - Must decrement `delegatedVotes[from]` by `amount` if `from` is not address(0).
    /// - Must increment `delegatedVotes[to]` by `amount` if `to` is not address(0).
    /// - Must emit `VotesUndelegated` or `VotesDelegated` with the expected properties (fromDelegate, toDelegate, amount).
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
