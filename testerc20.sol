// SPDX-License-Identifier: Unlicensed



pragma solidity ^0.8.23;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol";

contract ERC20test {

    string public name;
    string public symbol;

    mapping(address => uint256) public balanceOf;
    address public owner;
    uint8 public decimals;

    uint256 public totalSupply;
    uint256 public maxSupply;

    mapping(address => mapping(address => uint256)) public allowance;

    //emits events as seen in functions 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _burner, uint256 _amount);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;

        owner = msg.sender;
        maxSupply = 1000000 * 10 ** decimals;
    }

    //Modifier for owner-only access to burn or mint functionality 
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can mint and burn tokens");
        _;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(msg.sender == owner, "only owner can create tokens");
        require(totalSupply + amount <= maxSupply, "exceeds maximum supply");
        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        return helperTransfer(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        if (msg.sender != from) {
            require(allowance[from][msg.sender] >= amount, "not enough allowance");

            allowance[from][msg.sender] -= amount;
        }

       return helperTransfer(from, to, amount);
    }

    function helperTransfer(address from, address to, uint256 amount) internal returns (bool) {
        require(balanceOf[from] >= amount && to != address(0), "not enough tokens or cannot send to address(0)");
        require(decimals == getDecimalsAmount(amount), "Incorrect decimals for transfer");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);

        return true;
    }

    function getDecimalsAmount(uint256 amount) internal pure returns (uint8) {
        uint256 divisor = 10**18;
        while (amount % divisor == 0) {
            divisor /= 10;
        }
        return uint8(Math.log10(divisor));
    }

    //Burn function accessible only to owner
    function burn(uint256 amount) public onlyOwner {
        require(balanceOf[msg.sender] >= amount && totalSupply - amount >= 0, "Insufficient balance or exceeding total supply");

        balanceOf[msg.sender] -= amount; //Reduce msg sender balance
        totalSupply -= amount; //Reduce total supply

        emit Burn(msg.sender, amount); //emits burn event
    }


}
