/*
 ________  ___  ________ _________        ________  ___  ___  _______   ________  _________  ________      
|\   __  \|\  \|\  _____\\___   ___\     |\   __  \|\  \|\  \|\  ___ \ |\   ____\|\___   ___\\   ____\     
\ \  \|\  \ \  \ \  \__/\|___ \  \_|     \ \  \|\  \ \  \\\  \ \   __/|\ \  \___|\|___ \  \_\ \  \___|_    
 \ \   _  _\ \  \ \   __\    \ \  \       \ \  \\\  \ \  \\\  \ \  \_|/_\ \_____  \   \ \  \ \ \_____  \   
  \ \  \\  \\ \  \ \  \_|     \ \  \       \ \  \\\  \ \  \\\  \ \  \_|\ \|____|\  \   \ \  \ \|____|\  \  
   \ \__\\ _\\ \__\ \__\       \ \__\       \ \_____  \ \_______\ \_______\____\_\  \   \ \__\  ____\_\  \ 
    \|__|\|__|\|__|\|__|        \|__|        \|___| \__\|_______|\|_______|\_________\   \|__| |\_________\
                                                   \|__|                  \|_________|         \|_________|
                                                                                                                                                                                                                                                        
by chris and tony                                  
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IRift.sol";
import "./IRift.sol";

/// @title Quests in the Rift
contract RiftQuests is ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    ReentrancyGuard,
    Ownable,
    Pausable {

    struct QuestLogEntry {
        address quest;
        uint256 bagId;
        uint64 stepsCompleted;
        bool turnedIn;
    }

    struct QuestingStats {
        uint256 questsBegan;
        uint256 questsCompleted;
    }

    // look up by quest id
    mapping(uint256 => QuestLogEntry) public questLog;

    // look up by bag id
    mapping(uint256 => QuestingStats) public bagQuestStats;
    mapping(uint256 => address[]) public bagDiscoveredQuests;
    mapping(uint256 => address[]) public bagCompletedQuests;
    mapping(uint256 => mapping(address => uint256)) public bagQuestIds; // bagId questAddress questId

    // look up by quest address
    mapping(address => bool) approvedQuests;
    mapping(address => mapping(uint32 => uint16)) public questXPMap;

    uint256 questsBegan;

    IRift public iRift;

    constructor(address rift) ERC721("Rift Quests", "RFTQST") Ownable() {
        iRift = IRift(rift);
     }

    function completeStep(address quest, uint32 step, uint256 bagId) external whenNotPaused nonReentrant {
        require(approvedQuests[quest], "Only complete step on approved quests");
        iRift.isBagHolder(bagId, _msgSender());
        IRiftQuest(quest).completeStep(step, bagId, _msgSender());
        
        uint256 questId = bagQuestIds[bagId][quest];
        // quest just started
        if (questId == 0) {
            questsBegan += 1;

            bagQuestIds[bagId][quest] = questsBegan;
            questId = questsBegan;
            questLog[questId].quest = quest;
            questLog[questId].bagId = bagId;

            bagQuestStats[bagId].questsBegan += 1;
        }

        if (IRiftQuest(quest).bagsProgress(bagId).completedQuest) {
            bagCompletedQuests[bagId].push(quest);
        }

        questLog[questId].stepsCompleted = step;
        iRift.awardXP(uint32(bagId), questXPMap[quest][step]);
    }

    // todo: what sort of payment should this function support? 
    function mintQuest(address quest, uint256 bagId)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        require(IRiftQuest(quest).isCompleted(bagId), "your quest is not complete");
        
        uint256 questId = bagQuestIds[bagId][quest];
        questLog[questId].turnedIn = true;
        bagQuestStats[bagId].questsCompleted += 1;

        _safeMint(_msgSender(), questId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

     function tokenURI(uint256 questId) 
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory) 
    {
        return IRiftQuest(questLog[questId].quest).tokenURI(questLog[questId].bagId);
    }

    // owner

    function ownerSetXP(address quest, uint32 step, uint16 xp) external onlyOwner {
        questXPMap[quest][step] = xp;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    /**
    * enables an address 
    * @param quest the address to enable
    */
    function addQuest(address quest) external onlyOwner {
        approvedQuests[quest] = true;
    }

    /**
    * disables an address 
    * @param quest the address to disbale
    */
    function removeQuest(address quest) external onlyOwner {
        approvedQuests[quest] = true;
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    modifier unminted(uint256 tokenId) {
        require(ownerOf(tokenId) == address(0), "MNTD");
        _;
    }
}