// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address payable[] public players;
    address payable manager;

    constructor() {
        manager = payable(msg.sender);
        players.push(manager);
    }

    receive() external payable {
        require(msg.value == 1 ether, "Require 1 ether to participate");
        require(
            manager != msg.sender,
            "Manager cannot directly participate in the lottery"
        );
        players.push(payable(msg.sender));
    }

    function getBalance() public view restricted returns (uint256) {
        return address(this).balance;
    }

    function pickWinner() public restricted {
        require(players.length >= 3);
        uint256 managerFee = (address(this).balance * 10) / 100; // manager fee is 10%    // winner prize is 90%
        uint256 index = random() % players.length;
        manager.transfer(managerFee);
        players[index].transfer(address(this).balance);
        players = new address payable[](0);
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, players, block.difficulty)
                )
            );
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}
