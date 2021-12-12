// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

struct Bag {
    uint64 totalManaProduced;
    uint64 mintCount;
}

struct Crystal {
    uint16 attunement;
    uint64 lastClaim;
    uint64 lastLevelUp;
    uint8 level;
    uint32 levelManaProduced;
    uint32 regNum;
    uint16 lvlClaims;
}

struct Collab {
    address contractAddress;
    string namePrefix;
    uint256 levelBonus;
}

interface ICrystalManaCalculator {
    function claimableMana(uint256 tokenId) external view returns (uint32);
}

interface ICrystals {
    function crystalsMap(uint256 tokenID) external view returns (Crystal memory);
    function bags(uint256 tokenID) external view returns (Bag memory);
    function collabMap(uint256 tokenID) external view returns (Collab memory);
    function getResonance(uint256 tokenId) external view returns (uint32);
    function getSpin(uint256 tokenId) external view returns (uint32);
    function claimableMana(uint256 tokenID) external view returns (uint32);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
}

interface ICrystalsMetadata {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
