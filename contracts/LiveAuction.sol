// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Auction {
    address payable public owner;
    uint256 public startblock;
    uint256 public endBlock;

    enum State {
        Started,
        Running,
        Cancelled,
        Ended
    }
    State public auctionState;

    mapping(address => uint256) public bids;

    uint256 public highestBid;
    address payable public highestBidder;

    string public ifpsHash;
    uint256 public increment;

    constructor(address auctionCreator) {
        owner = payable(auctionCreator);
        startblock = block.number;
        endBlock = startblock + 40320; // 40320 is blocks mined in a week (current 1 block = 15 seconds)
        auctionState = State.Running;
        ifpsHash = "";
        increment = 1 ether;
    }

    modifier restricted() {
        require(owner != msg.sender, "Owner cannot participate in the bidding");
        _;
    }

    modifier afterStart() {
        require(
            block.number >= startblock,
            "Current block less than start block"
        );
        require(
            block.number <= endBlock,
            "Current block greater than end block"
        );
        _;
    }

    modifier requiresOwner() {
        require(msg.sender == owner);
        _;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function placeBid() public payable restricted afterStart {
        require(auctionState == State.Running, "Auction State not running");
        require(msg.value >= 1 ether, "Minimum payable 1 ether");

        uint256 currentBid = bids[msg.sender] + msg.value;
        require(
            currentBid > highestBid,
            "Your bid is less than current highest bid"
        );

        bids[msg.sender] = currentBid;

        if (bids[msg.sender] <= highestBid) {
            highestBid = min(currentBid + 100, bids[highestBidder]);
        } else {
            highestBid = min(currentBid, bids[highestBidder] + increment);
            highestBidder = payable(msg.sender);
        }
    }

    function finalizeAuction() public payable {
        require(
            auctionState == State.Cancelled || block.number > endBlock,
            "Auction is still running, wait for the auction to get over"
        );
        require(
            msg.sender == owner || bids[msg.sender] > 0,
            "You are neither a owner nor a bidder, you cannot finalize the auction"
        );

        address payable recipient = payable(msg.sender);
        uint256 value;

        // auction cancelled
        if (auctionState == State.Cancelled) {
            value = bids[recipient];
        } else {
            // auction ended
            // Owner
            if (recipient == owner) {
                value = highestBid;
            } else {
                // bidder
                // highest bidder
                if (recipient == highestBidder) {
                    value = bids[recipient] - highestBid;
                } else {
                    // normal bidder
                    value = bids[recipient];
                }
            }
        }

        recipient.transfer(value);
        bids[recipient] = 0;
    }

    function cancelAuction() public requiresOwner {
        auctionState = State.Cancelled;
    }

    function contractBalance() public view requiresOwner returns (uint256) {
        return address(this).balance;
    }
}

contract DeployAuction {
    address public auctionContractOwner;
    Auction[] public auctionsList;

    constructor() {
        auctionContractOwner = msg.sender;
    }

    function deployAuction() public {
        Auction newAuction = new Auction(msg.sender);
        auctionsList.push(newAuction);
    }
}
