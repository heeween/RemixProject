// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract GasGolf {
    // start 50760
    // use calldata 49032
    // load state variables to memory 48821
    // short circuit 48509
    // loop increments 47435
    // cache array length 47399
    // load array elements to memory 47231
    uint256 public total;

    // [1,2,3,4,5,100]
    function sumIfEventAndLessThan99(uint256[] calldata nums) external {
        uint256 temp = total;
        uint len = nums.length;
        // for (uint256 i = 0; i < nums.length; i += 1) {
        for (uint256 i = 0; i < len; ++i) {
            // bool isEven = nums[i] % 2 == 0;
            // bool isLessThan99 = nums[i] < 99;
            uint num = nums[i];
            if (num % 2 == 0 && num < 99) {
                temp += num;
            }
        }
        total = temp;
    }
}
