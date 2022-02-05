//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

contract Deposit {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // transfering ether from the contract to another address (recipient)
    function transferEther(address payable recipient, uint256 amount)
        public
        returns (bool)
    {
        // checking that only contract owner can send ether from the contract to another address
        require(
            owner == msg.sender,
            "Transfer failed, you are not the owner!!"
        );

        if (amount <= getBalance()) {
            // transfering the amount of wei from the contract to the recipient address
            // anyone who can call this function have access to the contract's funds
            recipient.transfer(amount);
            return true;
        } else {
            return false;
        }
    }
}
