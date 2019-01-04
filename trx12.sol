pragma solidity ^0.4.0;

contract TronPlay {
    /*=================================
    = MODIFIERS =
    =================================*/
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress] == true);
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /*==============================
    = EVENTS =
    ==============================*/
    event onGame(
        address indexed player,
        uint256 bet_number,
        uint256 result_number,
        uint256 income,
        uint256 payout,
        uint256 issueNum
    );

    // token转移完成后出发
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // approve(address _spender, uint256 _value)调用后触发
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /*================================
    = DATASETS =
    ================================*/
    // amount of shares for each address (scaled number)
    using SafeMath for *;
    uint256 public horseEdge = 98;

    // administrator list (see above on what they can do)
    mapping(address => bool) public administrators;

    // trc20
    string public constant symbol = "PLAY";
    string public constant name = "PLAY";
    uint8 public constant decimals = 6;
    uint256 _totalSupply = 100000000000000;

    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;


    /*=======================================
    = PUBLIC FUNCTIONS =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --
    */
    constructor () public
    {
        administrators[msg.sender] = true;

        owner = msg.sender;
        balances[owner] = _totalSupply;
    }


    // trc20
    function totalSupply()
    public
    view
    returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount
        && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        if (balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    // trc20


    function play(uint256 bet_number)
    payable
    public
    {
        uint256 income = msg.value;
        address sender = msg.sender;

        assert(bet_number >= 1 && bet_number <= 14);
        // Check that the bet_number to bet is within the range
        require(income >= 1 trx && income <= 1000 trx);

        uint256 payout = 0;

        uint256 result = randomResult();

        if (1 <= bet_number && bet_number <= 12 && bet_number == result) {
            payout = income * 12 * horseEdge / 100;
        } else if (bet_number == 13 && result % 2 == 1) {
            payout = income * 2 * horseEdge / 100;
        } else if (bet_number == 14 && result % 2 == 0) {
            payout = income * 2 * horseEdge / 100;
        }
        if (payout > 0) {
            sender.transfer(payout);
        }

        // issue token to player
        uint256 issueNum = income * 100;

        if (balances[owner] >= issueNum && issueNum > 0 && balances[sender] + issueNum > balances[sender]) {
            balances[owner] -= issueNum;
            balances[sender] += issueNum;
        }

        emit onGame(sender, bet_number, result, income, payout, issueNum);

    }

    function withdraw(uint256 num)
    onlyOwner()
    public
    {
        owner.transfer(num);
    }


    function randomResult()
    private
    view
    returns (uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(

                (block.timestamp).add
                (block.difficulty).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                (block.gaslimit).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                (block.number)

            )));
        return seed % 12;
    }


}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
