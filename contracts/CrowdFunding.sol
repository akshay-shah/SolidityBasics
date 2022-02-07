// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding {
    address admin;
    mapping(address => uint) public contributors;
    uint totalContributors;
    uint minimumContribution;
    uint raisedAmount;
    uint goalAmount;
    uint deadline;

    struct Request {
        address payable recipient;
        uint value;
        string description;
        mapping(address => bool) voters;
        bool isCompleted;
        uint totalVoters;
    }

    mapping(uint => Request) public requests;
    uint totalRequests;

    event Contribute(address contributor, uint value);
    event AmountRaised(uint value);
    event MakeCampaign(string description, address recipient, uint value);
    event MakeCampaignPayment(address recipient, uint value);

    constructor(uint _goalAmount, uint _deadline) {
        goalAmount = _goalAmount;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;
    }

    function contribute() public payable {
        require(block.timestamp < deadline);
        require(msg.value >= minimumContribution);

        if(contributors[msg.sender] == 0){
            totalContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit Contribute(msg.sender,msg.value);
        emit AmountRaised(raisedAmount);
    }

    function getRefund() public payable {
        require(block.timestamp > deadline && raisedAmount < goalAmount, "Crowd funding is still running");
        require(contributors[msg.sender] > 0, "Sorry, you are not a contributor");

        address payable recipient = payable(msg.sender);
        uint value = contributors[recipient];

        recipient.transfer(value);
        contributors[recipient] = 0;
    }

    function createRequest(uint _value, string memory _description, address payable _recipient) public requiresAdmin {
        Request storage newRequest = requests[totalRequests];
        totalRequests++;

        newRequest.value = _value;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.isCompleted = false;
        newRequest.totalVoters = 0;

        emit MakeCampaign(_description, _recipient,_value);
    }

    function voteRequest(uint _requestNumber) public {
        require(contributors[msg.sender] > 0 , "Not a contributor");
        Request storage thisRequest = requests[_requestNumber];
        require(thisRequest.voters[msg.sender] == false, "You have already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.totalVoters++;
    }

    function makePayment(uint _requestNumber) public payable requiresAdmin {
        require(raisedAmount >= goalAmount);
        Request storage thisRequest = requests[_requestNumber];
        require(thisRequest.isCompleted == false, "Already fulfilled");
        require(thisRequest.totalVoters > totalContributors/2,"Majority of contributors not voted");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.isCompleted = true;

        emit MakeCampaignPayment(thisRequest.recipient, thisRequest.value);
    }

    receive() external payable {
        contribute();
    }

    modifier requiresAdmin {
        require(msg.sender == admin);
        _;
    }

    
}