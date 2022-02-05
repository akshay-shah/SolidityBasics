// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address payable[] public players;
    address public manager;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value == 1 ether);
        players.push(payable(msg.sender));
    }

    function getBalance() public view restricted returns(uint) {
        return address(this).balance;
    }

    function pickWinner() public restricted {
        require(players.length >= 3);
        uint index = random() % players.length;
        players[index].transfer(address(this).balance);
        players = new address payable[](0);
    }

    function random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,players,block.difficulty)));
    }

    modifier restricted {
        require(msg.sender == manager);
        _;
    }

}