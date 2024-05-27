// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract MultiDelegateCall {
    error DelegatecallFailed();

    function multiDelegateCall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        for (uint256 i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegatecallFailed();
            }
            results[i] = res;
        }
    }
        function multiCall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        for (uint256 i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).call(data[i]);
            if (!ok) {
                revert DelegatecallFailed();
            }
            results[i] = res;
        }
    }
}

contract TestMultiDelegateCall is MultiDelegateCall {
    event Log(address caller, string func, uint256 i);

    function func1(uint256 x, uint256 y) external {
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint256) {
        emit Log(msg.sender, "func2", 42);
        return 111;
    }

    mapping (address => uint) public balanceOf;

    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function getFunc1Data(uint256 x, uint256 y)
        external
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(TestMultiDelegateCall.func1.selector, x, y);
    }

    function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegateCall.func2.selector);
    }

    function getMintData() external pure returns(bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegateCall.mint.selector);
    }
}
