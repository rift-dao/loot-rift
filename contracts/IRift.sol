pragma solidity ^0.8.9;

interface IRift {
    function useCharge(uint32 bagId, uint16 amount, bool unstake) external;
    function bagCheck(uint32 bagId) external;
    function awardXP(uint32 bagId, uint32 xp) external;
}

struct QuestStep {
    string action;
    string description;
    string result;
    uint32 xp;
}

struct BagProgress {
    uint64 lastCompletedStep;
    bool completedQuest;
}

interface IRiftQuest {
    function title() external view returns (string memory);
    function numSteps() external view returns (uint64);
    function canStartQuest(uint256 bagId) external view returns (bool);
    function isCompleted(uint256 bagId) external view returns (bool);
    function currentStep(uint256 bagId) external view returns (QuestStep memory);
    function completeStep(uint64 step, uint256 bagId, address from) external;
    function stepAwardXP(uint64 step) external view returns (uint32);
    function tokenURI(uint256 bagId) external view returns (string memory);
}

interface IRiftBurnable {
    function riftPower(uint256 tokenId) external view returns (uint256);
}

interface IMana {
    function ccMintTo(address recipient, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}