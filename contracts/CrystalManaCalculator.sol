// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ICrystalManaCalculator {
    function claimableMana(uint256 tokenId) public view returns (uint256);
}

struct Crystal {
    bool minted;
    uint64 lastClaim;
    uint64 lastLevelUp;
    uint64 lastTransfer;
    uint64 numOfTransfers;
    uint256 manaProduced;
    uint256 level;
    uint256 regNum;
}

interface ICrystals {
    function crystalsMap(uint256 tokenID) external view returns (Crystal memory);
    function collabMap(uint256 tokenID) external view returns (Collab memory);
    function getMultiplier(uint256 tokenId) external view returns (uint256);
    function getResonance(uint256 tokenId) external view returns (uint256);
    function getSpin(uint256 tokenId) external view returns (uint256);
}

contract CrystalManaCalculator is Ownable, IManaGeneration {
    address public crystalsAddress;

    function claimableMana(uint256 tokenId) override public view returns (uint256) {
        ICrystals crystals = ICrystals(crystalsAddress);

        uint256 daysSinceClaim = diffDays(
            crystals.crystalsMap(tokenId).lastClaim,
            block.timestamp
        );

        require(daysSinceClaim >= 1, "NONE");

        uint256 manaToProduce = daysSinceClaim * crystals.getResonance(tokenId);

        // amount generatable is capped to the crystals spin
        if (daysSinceClaim > crystals.crystalsMap(tokenId).level) {
            manaToProduce = crystals.crystalsMap(tokenId).level * crystals.getResonance(tokenId);
        }

        // bonus for crystals staying with the wallet
        manaToProduce = (getMultiplier(tokenId) * manaToProduce) / 100;

        // if cap is hit, limit mana to cap or level, whichever is greater
        if ((manaToProduce + crystals.crystalsMap(tokenId).manaProduced) > crystals.getSpin(tokenId)) {
            if (crystals.getSpin(tokenId) >= crystals.crystalsMap(tokenId).manaProduced) {
                manaToProduce = crystals.getSpin(tokenId) - crystals.crystalsMap(tokenId).manaProduced;
            } else {
                manaToProduce = 0;
            }

            if (manaToProduce < crystals.crystalsMap(tokenId).level && getMultiplier(tokenId) >= 100) {
                manaToProduce = crystals.crystalsMap(tokenId).level;
            }
        }

        return manaToProduce;
    }
}