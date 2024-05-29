//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import { console2 } from "forge-std/console2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Multisend Challenge Contract
 * @author BUIDL GUIDL
 * @notice This challenge contract is meant to allow users to distribute ETH or ERC20 tokens to multiple users.
 * @dev The natspec is meant to be paired with the README.md to help guide you through this challenge! Goodluck!
 * @dev This smart contract is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 */
contract Multisend {

    /// Events
    /**
     * @notice Successful transfer of ETH has been carried out.
     */
    event SuccessfulETHTransfer(address indexed _sender, address[] indexed _receivers, uint256[]  _amounts);

    /**
     * @notice Successful transfer of Tokens has been carried out.
     */
    event SuccessfulTokenTransfer(address indexed _sender, address[] indexed _receivers, uint256[] _amounts);

    /// Errors
    /**
     * @notice Sender requires enough ETH for the transaction.
     */
    error Multisend__SenderNotEnoughETH(address _sender);

    /**
     * @notice Sender requires enough Tokens for the transaction.
     */
    error Multisend__SenderNotEnoughTokens(address _sender);

    /**
     * @notice Array params must be the same length.
     * @param _recipientArrayLength Length of the _addresses array passed in from function caller.
     * @param _amountsArrayLength Length of the _amounts array passed in from function caller.
     */
    error Multisend__ParamArraysNotEqualLength(uint256 _recipientArrayLength, uint256 _amountsArrayLength);

    /**
     * @notice Send ETH amounts to one or more recipients.
     * @param _recipients Addresses to send specified amounts.
     * @param _amounts Number of ETH to send to specified recipients.
     * @dev Do we want to have a log of the recipients in memory so we don't have repeat recipients? How would we do that? I'd think we'd just keep a temporary storage of the addresses and check against it if the address has repeated.
     */
    function sendETH(address payable[] memory _recipients, uint256[] memory _amounts) public payable {
        // ensure that arrays match in length
        uint256 recipientArrayLength = _recipients.length;
        uint256 amountsArrayLength = _amounts.length;

        if (_recipients.length != _amounts.length) revert Multisend__ParamArraysNotEqualLength(recipientArrayLength, amountsArrayLength);

        console2.log("Contract ETH balance: %s", address(this).balance);
        // Go through the address array and send ETH amounts as you go through
        for (uint i = 0; i < recipientArrayLength; i++) {
            if(address(this).balance < _amounts[i]) revert Multisend__SenderNotEnoughETH(msg.sender); 
            (bool success, ) = _recipients[i].call{value: _amounts[i]}("");
            require(success, "Transfer failed.");
        }
    }

    /**
     * @notice Send ERC20 amounts to one or more recipients.
     * @param _recipients Addresses to receive specified amounts.
     * @param _amounts Number of ERC20 tokens to send to specified recipients.
     * @param _token Specified ERC20 to transfer.
     * @dev What if the tokens don't abide by ERC20? Well it would revert when trying to call an ERC20 function. This contract doesn't check that we aren't dealing with scam / rug pull ERC20s sadly, it simply just transfers ERC20s.
     */
    function sendTokens(address payable[] memory _recipients, uint256[] memory _amounts, address _token) public {
        // ensure that arrays match in length
        uint256 recipientArrayLength = _recipients.length;
        uint256 amountsArrayLength = _amounts.length;

        if (_recipients.length != _amounts.length) revert Multisend__ParamArraysNotEqualLength(recipientArrayLength, amountsArrayLength);

        IERC20 token = IERC20(_token);

        // Go through the address array and send ETH amounts as you go through
        for (uint i = 0; i < recipientArrayLength; i++) {
            if(token.balanceOf(msg.sender) < _amounts[i]) revert Multisend__SenderNotEnoughTokens(msg.sender); 
            (bool success, ) = _recipients[i].call{value: _amounts[i]}("");
            require(success, "Transfer failed.");
        }
    }

    receive() external payable {}
    fallback() external payable {
        // Do nothing, just accept the Ether
    }
}
