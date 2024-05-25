// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

contract ERC20 is IERC20 {
    uint256 public totalSuplly;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "Test";
    string public symbol = "TEST";
    uint256 public decimals = 18;

    function transfer(address to, uint256 value) external returns (bool) {
        balanceOf(msg.sender) -= value;
        balanceOf(to) += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function mint(uint amount) external {
        balanceOf(msg.sender) += amount;
        totalSuplly += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf(msg.sender) -= amount;
        totalSuplly -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
