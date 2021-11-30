// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

struct Crystal {
    bool minted;
    uint64 lastClaim;
    uint64 lastLevelUp;
    uint64 lastTransfer;
    uint64 numOfTransfers;
    uint64 level;
    uint256 manaProduced;
    uint256 mintNum;
}

struct Collab {
        address contractAddress;
        string namePrefix;
        uint256 levelBonus;
    }

interface ICrystals {
    function crystalsMap(uint256 tokenID) external view returns (Crystal memory);
    function collabMap(uint256 tokenID) external view returns (Collab memory);
    function getResonance(uint256 tokenId) external view returns (uint256);
    function getSpin(uint256 tokenId) external view returns (uint256);
    function claimableMana(uint256 tokenID) external view returns (uint256);
}