// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Event {
    event Log(string message, uint256 val);
    event IndexLog(address indexed sender, uint256 val);

    function example() external {
        emit Log("foo", 1234);
        emit IndexLog(msg.sender, 789);
    }

    event Message(address indexed _from, address indexed _to, string message);

    function sendeMessage(address _to, string calldata message) external {
        emit Message(msg.sender, _to, message);
    }
}
