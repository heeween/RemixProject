// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@rari-capital/solmate/src/tokens/ERC20.sol";

contract WETH is ERC20 {
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor() ERC20("Wraped Ether", "WETH", 18) {}

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }
}
