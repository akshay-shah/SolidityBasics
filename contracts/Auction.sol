//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

contract Auction {
    mapping(address => uint256) public bids;

    function bid() public payable {
        bids[msg.sender] = msg.value;
    }

    function getBids()
        internal
        view
        returns (mapping(address => uint256) storage)
    {
        return bids;
    }
}
