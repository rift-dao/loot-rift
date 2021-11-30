// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Interfaces.sol";

contract Rift is Ownable {
  ICrystals public iCrystals;
  IMana public iMana;

  string public description;

  constructor() Ownable() {
      description = "Unknown";
  }

  function ownerSetDescription(string memory desc) public onlyOwner {
      description = desc;
  }

  function ownerSetCrystalsAddress(address addr) public onlyOwner {
      iCrystals = ICrystals(addr);
  }

  function ownerSetManaAddress(address addr) public onlyOwner {
      iMana = IMana(addr);
  }
}
