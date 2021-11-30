pragma solidity ^0.8.9;

struct Crystal {
    bool minted;
    uint64 lastClaim;
    uint64 lastLevelUp;
    uint64 lastTransfer;
    uint64 numOfTransfers;
    uint64 level;
    uint256 manaProduced;
    uint256 regNum;
}

struct Collab {
    address contractAddress;
    string namePrefix;
    uint256 levelBonus;
}

interface ICrystalManaCalculator {
    function claimableMana(uint256 tokenId) external view returns (uint256);
}

interface ICrystals {
    function crystalsMap(uint256 tokenID) external view returns (Crystal memory);
    function collabMap(uint256 tokenID) external view returns (Collab memory);
    function getResonance(uint256 tokenId) external view returns (uint256);
    function getSpin(uint256 tokenId) external view returns (uint256);
    function claimableMana(uint256 tokenID) external view returns (uint256);
}

interface ICrystalsMetadata {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IMana {
    function ccMintTo(address recipient, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}
