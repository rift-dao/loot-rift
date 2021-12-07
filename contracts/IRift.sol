// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

struct RiftBag {
        uint16 charges;
        uint16 chargesUsed;
        uint16 level;
        uint256 xp;
        uint64 lastChargePurchase;
    }

interface IRift {
    function useCharge(uint16 amount, uint256 bagId, address from) external;
    function bags(uint256 bagId) external view returns (RiftBag memory);
    function awardXP(uint32 bagId, XP_AMOUNT xp) external;
    function isBagHolder(uint256 bagId, address owner) external;
}

struct QuestStep {
    string requirements;
    string[] description;
    string[] result;
    XP_AMOUNT xp;
}

struct BagProgress {
    uint64 lastCompletedStep;
    bool completedQuest;
}

enum XP_AMOUNT { NONE, TINY, MODERATE, LARGE, EPIC }

interface IRiftQuest {
    function bagsProgress(uint256 bagId) external view returns (BagProgress memory);
    function title() external view returns (string memory);
    function numSteps() external view returns (uint64);
    function canStartQuest(uint256 bagId) external view returns (bool);
    function isCompleted(uint256 bagId) external view returns (bool);
    function currentStep(uint256 bagId) external view returns (QuestStep memory);
    function completeStep(uint32 step, uint256 bagId, address from) external;
    function stepAwardXP(uint64 step) external view returns (XP_AMOUNT);
    function tokenURI(uint256 bagId) external view returns (string memory);
}

interface IRiftBurnable {
    function riftPower(uint256 tokenId) external view returns (uint256);
}

interface IMana {
    function ccMintTo(address recipient, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}