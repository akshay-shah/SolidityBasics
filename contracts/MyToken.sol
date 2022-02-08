// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract MyToken is ERC20Interface {
    event Invest(address from, uint256 value, uint256 tokens);

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;

    string public name = "Akshay Shah Coin";
    string public symbol = "ASC";
    uint256 public override totalSupply;
    uint256 public decimals;
    address public founder;

    constructor() {
        totalSupply = 100000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
        decimals = 0;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens)
        public
        virtual
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens);

        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens);
        require(tokens >= 0);

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public virtual override returns (bool success) {
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);

        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;

        emit Transfer(from, to, tokens);

        return true;
    }
}

contract MyTokenICO is MyToken {
    address public admin;
    address payable public deposit;
    uint256 tokenPrice = 0.001 ether;
    uint256 public hardCap = 300 ether;
    uint256 public raisedAmount;

    uint256 public saleStart = block.timestamp;
    uint256 public saleEnd = block.timestamp + 604800;
    uint256 public tokenTradeStart = saleEnd + 604800;

    uint256 maxInvestment = 5 ether;
    uint256 minInvestment = 0.1 ether;

    enum State {
        BEFORE_START,
        RUNNING,
        AFTER_END,
        HALTED
    }
    State public icoState;

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.BEFORE_START;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function halt() public onlyAdmin {
        icoState = State.HALTED;
    }

    function restart() public onlyAdmin {
        icoState = State.RUNNING;
    }

    function changeDepositAddress(address payable newAddress) public onlyAdmin {
        deposit = newAddress;
    }

    function getCurrentState() public view returns (State) {
        if (icoState == State.HALTED) {
            return State.HALTED;
        } else if (block.timestamp < saleStart) {
            return State.BEFORE_START;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.RUNNING;
        } else {
            return State.AFTER_END;
        }
    }

    function invest() public payable returns (bool) {
        require(getCurrentState() == State.RUNNING);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);

        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        uint256 tokens = msg.value / tokenPrice;
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);
        return true;
    }

    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool success)
    {
        require(block.timestamp > tokenTradeStart);
        super.transfer(to, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart);
        super.transferFrom(from, to, tokens);
        return true;
    }

    function burn() public returns (bool) {
        require(getCurrentState() == State.AFTER_END);
        balances[founder] = 0;
        return true;
    }

    receive() external payable {
        invest();
    }
}
