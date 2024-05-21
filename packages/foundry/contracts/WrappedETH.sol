//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract WrappedETH {
    // ERC20 Standard methods for token metadata
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    // ERC20 Standard Interface Events
    event Approval(address indexed source, address indexed deputy, uint amount);
    event Transfer(address indexed source, address indexed destination, uint amount);

    // Non-ERC20 Standard Events - specific to the Wrapped Ether contract
    event Deposit(address indexed destination, uint amount);
    event Withdrawal(address indexed source, uint amount);

    // ERC20 Standard Interface mappings
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    /**
     * @dev Deposits Ether into the contract.
     * @notice This function allows users to deposit Ether into the contract.
     * @dev The deposited Ether is added to the balance of the sender.
     * Requirements:
     * - Adds the amount deposited to the balance of the sender.
     * - Emits a `Deposit` event with the caller's address and the amount of Ether deposited.
     */
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Allows the caller to withdraw a specified amount of wrapped Ether (WETH) from their balance.
     * @param amount The amount of wrapped Ether to withdraw.
     * Requirements:
     * - The caller must have a balance of at least `amount` wrapped Ether.
     * - The withdrawal must be successful and the Ether must be sent to the caller's address.
     * - Emits a `Withdrawal` event with the caller's address and the amount of Ether withdrawn.
     */
    function withdraw(uint amount) public {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
        emit Withdrawal(msg.sender, amount);
    }

    /**
     * @dev Part of the ERC20 Standard Interface.
     * @dev Returns the total supply of the wrapped ETH token.
     * @return uint representing the total supply of the wrapped ETH token.
     * Requirements:
     * - The total supply is equal to the balance of the contract.
     */
    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    /**
     * @dev Part of the ERC20 Standard Interface.
     * @dev Approves the specified address to spend the caller's tokens.
     * @param deputy The address to be approved.
     * @param amount The amount of tokens to be approved.
     * @return boolean value indicating whether the approval was successful or not.
     * Requirements:
     * - The caller sets the allowance of the specified address to the specified amount of tokens.
     * - Emits an `Approval` event with the caller's address, the approved address, and the amount of tokens approved.
     */
    function approve(address deputy, uint amount) public returns (bool) {
        allowance[msg.sender][deputy] = amount;
        emit Approval(msg.sender, deputy, amount);
        return true;
    }

    /**
     * @dev Part of the ERC20 Standard Interface.
     * @dev Transfers a specified amount of wrapped ETH tokens from the source address to the destination address.
     * @param source The address to transfer the tokens from.
     * @param destination The address to transfer the tokens to. destination == destination
     * @param amount The amount of tokens to transfer.
     * @return boolean value indicating whether the transfer was successful or not.
     * Requirements:
     * - The source address must have a balance of at least `amount` tokens.
     * - The source address must have approved the caller to spend at least `amount` tokens.
     * - Emits a `Transfer` event with the caller's address, the approved address, and the amount of tokens approved.
     */
    function transferFrom(
        address source,
        address destination,
        uint amount
    ) public returns (bool) {
        require(balanceOf[source] >= amount);

        if (
            source != msg.sender && allowance[source][msg.sender] != type(uint256).max
        ) {
            require(allowance[source][msg.sender] >= amount);
            allowance[source][msg.sender] -= amount;
        }

        balanceOf[source] -= amount;
        balanceOf[destination] += amount;

        emit Transfer(source, destination, amount);

        return true;
    }

    /**
     * @dev Part of the ERC20 Standard Interface.
     * @dev Transfers a specified amount of wrapped ETH tokens from the caller's address to the destination address.
     * @param destination The address to transfer the tokens to. destination == destination
     * @param amount The amount of tokens to transfer.
     * @return boolean value indicating whether the transfer was successful or not.
     * Requirements:
     * - The caller must have a balance of at least `amount` tokens.
     * - Emits a `Transfer` event with the caller's address, the approved address, and the amount of tokens approved.
     */
    function transfer(address destination, uint amount) public returns (bool) {
        return transferFrom(msg.sender, destination, amount);
    }

    /**
     * @dev Default 'fallback' method called when a contract is called with msg.data that doesn't match any other method.
     * Requirements:
     * - Should call the `deposit` function to handle any received Ether.
     */
    fallback() external payable {
        deposit();
    }

    /**
     * @dev Default method is used when a contract is called with empty msg.data.
     * Requirements:
     * - Should call the `deposit` function to handle any received Ether.
     */
    receive() external payable {
        deposit();
    }
}
