// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {console} from "hardhat/console.sol";

contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    string public name; //state variable
    string public symbol; //state variable
    uint8 public immutable decimals; //state variable
    uint256 public totalSupply; //state variable

    mapping(address => uint256) public balanceOf; // state variable

    mapping(address => mapping(address => uint256)) public allowance; // state variable, double mapping

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        console.log("Transferring ", value, " to ", to);
        return _transfer(msg.sender, to, value); // from is the msg.sender
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external virtual returns (bool) {
        require(
            allowance[from][msg.sender] >= value,
            "ERC20: Insufficient allowance"
        );

        allowance[from][msg.sender] -= value; // where are the tokens? = from address. The owner. Who is the spender? =msg.sender which initiates the function call.
        // Decreasing by value the old allowance value

        //  emit Approval (from, msg.sender, allowance[from][msg.sender]); // this is the allowance after the transferFrom call (the new value, what is left of the allowance)
        return _transfer(from, to, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private returns (bool) {
        require(balanceOf[from] >= value, "ERC20: Insufficient sender balance");

        emit Transfer(from, to, value);

        //msg.sender or from address: who sents the tokens (depends in which function is called for the sender address). Decrease token balance by value
        balanceOf[from] -= value; // decreasing by value the tokens of the sender

        //to : where the tokens are going. Increase token balance by value
        balanceOf[to] += value; // increasing by value the tokens of the receiver

        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        emit Approval(msg.sender, spender, value); // here emit the value

        allowance[msg.sender][spender] += value; //msg.sender here is the owner of the tokens and approves (allows) to send tokens to the spender.
        // Increase by value the old allowance value
        return true;
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    function _mint(address to, uint256 value) internal {
        balanceOf[to] += value;
        totalSupply += value;
        emit Transfer(address(0), to, value); //address(0)= zero or null address:special address (absence of valid Ethereum address) which is uninitialized or burn address
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }
}

// test-helper function
/*function giveMeOneToken() external {
        balanceOf[msg.sender]+=1e18;
    }*/
