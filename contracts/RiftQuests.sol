/*
   __ _  __ _       ____                 _   
  /__(_)/ _| |_    /___ \_   _  ___  ___| |_ 
 / \// | |_| __|  //  / / | | |/ _ \/ __| __|
/ _  \ |  _| |_  / \_/ /| |_| |  __/\__ \ |_ 
\/ \_/_|_|  \__| \___,_\ \__,_|\___||___/\__|

by chris and tony                                  
*/

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./Interfaces.sol";
import "./IRiftQuest.sol";

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

    mapping(uint256 => QuestLogEntry) public questLog;
    mapping(uint256 => QuestStep) public steps;
    mapping(uint256 => mapping(address => uint256)) public bagQuests;

    uint256 questsBegan;
    uint256 questsCompleted;

    IRift public iRift;

    constructor(address rift) ERC721("Rift Quests", "RFTQST") Ownable() {
        iRift = IRift(rift);
     }

    function completeStep(address quest, uint64 step, uint256 bagId) external whenNotPaused nonReentrant {
        iRift.bagCheck(uint32(bagId));
        IRiftQuest(quest).completeStep(step, bagId, _msgSender());

        uint256 questId = bagQuests[bagId][quest];
        // quest just started
        if (questId == 0) {
            bagQuests[bagId][quest] = questsBegan;
            questId = questsBegan;
            questLog[questId].quest = quest;
            questLog[questId].bagId = bagId;

            questsBegan += 1;
        }

        questLog[questId].stepsCompleted = step;
        iRift.awardXP(uint32(bagId), IRiftQuest(quest).awardXP(step));
    }

    // todo: what sort of payment should this function support? 
    function mintQuest(address quest, uint256 bagId)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        require(IRiftQuest(quest).isCompleted(bagId), "your quest is not complete");
        
        uint256 questId = bagQuests[bagId][quest];
        questLog[questId].turnedIn = true;

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

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
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

    modifier ownsCrystal(uint256 tokenId) {
        require(ownerOf(tokenId) == _msgSender(), "UNAUTH");
        _;
    }

    modifier unminted(uint256 tokenId) {
        require(ownerOf(tokenId) == address(0), "MNTD");
        _;
    }
}