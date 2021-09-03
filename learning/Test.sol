/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.8.0;

contract Test {
    uint256 private _MAX = 1000;

    function get(uint256 input) public view returns (uint256) {
        uint256 depth = input/1000;
        return depth;
    }
}
