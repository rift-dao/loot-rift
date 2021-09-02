/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 private _storedData;

    function set(uint256 x) public {
        _storedData = x;
    }

    function get() public view returns (uint256) {
        return _storedData;
    }
}
