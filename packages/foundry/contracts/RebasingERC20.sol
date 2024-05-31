// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RebasingERC20 Challenge Contract
 * @author BUIDL GUIDL
 * @notice This challenge contract is meant to be an example rebasing token.
 * @dev The natspec is meant to be paired with the README.md to help guide you through this challenge! Goodluck!
 * @dev This smart contract is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 */
contract RebasingERC20 is ERC20, Ownable {
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    uint256 private _scalingFactor;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    constructor() ERC20("RebasingToken", "RBT") {
        _totalSupply = 1000000 * 10 ** decimals();
        _scalingFactor = 10 ** 18; // Initial scaling factor (1.0)
        _mint(msg.sender, _totalSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account] * _scalingFactor / (10 ** 18);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function rebase(uint256 epoch, int256 supplyDelta) external onlyOwner returns (uint256) {
        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply -= uint256(-supplyDelta);
        } else {
            _totalSupply += uint256(supplyDelta);
        }

        _scalingFactor = (10 ** 18) * _totalSupply / _initialTotalSupply();

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function _initialTotalSupply() internal view returns (uint256) {
        return 1000000 * 10 ** decimals();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        if (from == address(0)) {
            // Minting tokens
            _balances[to] += amount * (10 ** 18) / _scalingFactor;
        } else if (to == address(0)) {
            // Burning tokens
            _balances[from] -= amount * (10 ** 18) / _scalingFactor;
        } else {
            // Transfer between accounts
            _balances[from] -= amount * (10 ** 18) / _scalingFactor;
            _balances[to] += amount * (10 ** 18) / _scalingFactor;
        }
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _beforeTokenTransfer(_msgSender(), recipient, amount);
        emit Transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _beforeTokenTransfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance(sender, _msgSender()) - amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
}
