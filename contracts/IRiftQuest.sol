// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

struct QuestStep {
    string description;
    uint32 xp;
}

interface IRiftQuest {
    function title() external view returns (string memory);
    function numSteps() external view returns (uint64);
    function isCompleted(uint256 bagId) external view returns (bool);
    function currentStep(uint256 bagId) external view returns (QuestStep memory);
}