/*

▄▄▄█████▓ ██░ ██ ▓█████     ██▀███   ██▓  █████▒▄▄▄█████▓   (for Adventurers)
▓  ██▒ ▓▒▓██░ ██▒▓█   ▀    ▓██ ▒ ██▒▓██▒▓██   ▒ ▓  ██▒ ▓▒
▒ ▓██░ ▒░▒██▀▀██░▒███      ▓██ ░▄█ ▒▒██▒▒████ ░ ▒ ▓██░ ▒░
░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄    ▒██▀▀█▄  ░██░░▓█▒  ░ ░ ▓██▓ ░ 
  ▒██▒ ░ ░▓█▒░██▓░▒████▒   ░██▓ ▒██▒░██░░▒█░      ▒██▒ ░ 
  ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░   ░ ▒▓ ░▒▓░░▓   ▒ ░      ▒ ░░   
    ░     ▒ ░▒░ ░ ░ ░  ░     ░▒ ░ ▒░ ▒ ░ ░          ░    
  ░       ░  ░░ ░   ░        ░░   ░  ▒ ░ ░ ░      ░      
          ░  ░  ░   ░  ░      ░      ░                   
                                                         
    by chris and tony
    
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import "./Interfaces.sol";
import "./IRift.sol";

contract Rift is ReentrancyGuard, Pausable, Ownable {

    event BagCharged(address owner, uint256 tokenId, uint16 amount);
    event ChargesConsumed(address owner, uint256 tokenId, uint16 amount);
    // event CrystalSacrificed(address owner, uint256 tokenId, uint256 powerIncrease);

    ERC721 public iLoot;
    ERC721 public iMLoot;
    IMana public iMana;

    string public description = "The Great Unknown";

    // rift level variables
    uint32 public riftLevel = 3;
    uint32 internal riftTier = 1;
    uint64 internal riftTierPower = 17500;
    uint8 internal riftTierSize = 5;
    uint8 internal riftTierIncrease = 15; // 15% increase
    uint64 internal riftPowerPerLevel = 5000;

    uint64 public riftObjectsSacrificed = 0;

    uint256 internal karmaTotal;
    uint256 internal karmaHolders;

    uint16 internal xpMultTiny = 10;
    uint16 internal xpMultMod = 50;
    uint16 internal xpMultLrg = 100;
    uint16 internal xpMultEpc = 300;

    mapping(uint256 => RiftBag) public bags;
    mapping(address => uint256) public karma;
    mapping(uint16 => uint16) public xpRequired;
    mapping(uint16 => uint16) public levelChargeAward;
    mapping(address => bool) public riftObjects;
    mapping(address => bool) public riftQuests;
    address[] public riftObjectsArr;

    constructor() Ownable() {
    }

    function ownerSetDescription(string memory desc) public onlyOwner {
        description = desc;
    }

    function ownerSetLootAddress(address addr) public onlyOwner {
        iLoot = ERC721(addr);
    }

    function ownerSetMLootAddress(address addr) public onlyOwner {
        iMLoot = ERC721(addr);
    }

    function addRiftQuest(address addr) public onlyOwner {
        riftQuests[addr] = true;
    }

    function removeRiftQuest(address addr) public onlyOwner {
        riftQuests[addr] = false;
    }

    function ownerUpdateRiftTier(uint8 tierSize, uint8 tierIncrease, uint64 ppl) public onlyOwner {
        riftTierSize = tierSize;
        riftTierIncrease = tierIncrease;
        riftPowerPerLevel = ppl;
    }

    /**
    * enables an address to mint / burn
    * @param controller the address to enable
    */
    function addRiftObject(address controller) external onlyOwner {
        riftObjects[controller] = true;
        riftObjectsArr.push(controller);
    }

    /**
    * disables an address from minting / burning
    * @param controller the address to disbale
    */
    function removeRiftObject(address controller) external onlyOwner {
        riftObjects[controller] = false;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function ownerWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function ownerSetXpRequirement(uint16 level, uint16 xp) external onlyOwner {
        xpRequired[level] = xp;
    }

    function ownerSetLevelChargeAward(uint16 level, uint16 charges) external onlyOwner {
        levelChargeAward[level] = charges;
    }

    function ownerSetManaAddress(address addr) public onlyOwner {
        iMana = IMana(addr);
    }

    function ownerSetXPMultipliers(uint16 tiny, uint16 moderate, uint16 large, uint16 epic) external onlyOwner {
        xpMultTiny = tiny;
        xpMultMod = moderate;
        xpMultLrg = large;
        xpMultEpc = epic;
    }

    // READ

    modifier _isBagHolder(uint256 bagId, address owner) {
        if (bagId < 8001) {
            require(iLoot.ownerOf(bagId) == owner, "UNAUTH");
        } else {
            require(iMLoot.ownerOf(bagId) == owner, "UNAUTH");
        }
        _;
    }

    function isBagHolder(uint256 bagId, address owner) external view {
        if (bagId < 8001) {
            require(iLoot.ownerOf(bagId) == owner, "UNAUTH");
        } else {
            require(iMLoot.ownerOf(bagId) == owner, "UNAUTH");
        }
    }
    
    // WRITE

    // pay to charge. only once per day
    function buyCharge(uint256 bagId) external
        _isBagHolder(bagId, _msgSender()) 
        whenNotPaused 
        nonReentrant {
    
        require(block.timestamp - bags[bagId].lastChargePurchase > 1 days, "Too soon"); 
        
        //one with the rift
        if (topKarmaHolder(_msgSender())) {
            _chargeBag(bagId);
        } else {
            iMana.burn(_msgSender(), bags[bagId].level * (bagId < 8001 ? 100 : 10));
            _chargeBag(bagId);
        }

        bags[bagId].lastChargePurchase = uint64(block.timestamp);
    }

    function useCharge(uint16 amount, uint256 bagId, address from) 
        _isBagHolder(bagId, from) 
        external 
        whenNotPaused 
        nonReentrant 
    {
        require(riftObjects[msg.sender], "Not of the Rift");
        require(bags[bagId].charges >= amount, "Not enough Rift charges");

        bags[bagId].chargesUsed += amount;
        bags[bagId].charges -= amount;
    }

    function awardXP(uint32 bagId, XP_AMOUNT xp) public nonReentrant {
        require(riftQuests[msg.sender], "only the worthy");
        _awardXP(bagId, xp);
    }

    function _awardXP(uint32 bagId, XP_AMOUNT xp) internal {
        // verify the rift has power
        if (bags[bagId].level == 0) {
            bags[bagId].level = 1;
            _chargeBag(bagId);
        }

        bags[bagId].xp += convertXP(xp, bagId);
        
        /*
 _        _______           _______  _                   _______  _ 
( \      (  ____ \|\     /|(  ____ \( \        |\     /|(  ____ )( )
| (      | (    \/| )   ( || (    \/| (        | )   ( || (    )|| |
| |      | (__    | |   | || (__    | |        | |   | || (____)|| |
| |      |  __)   ( (   ) )|  __)   | |        | |   | ||  _____)| |
| |      | (       \ \_/ / | (      | |        | |   | || (      (_)
| (____/\| (____/\  \   /  | (____/\| (____/\  | (___) || )       _ 
(_______/(_______/   \_/   (_______/(_______/  (_______)|/       (_)                                                    
                                                                 
        */
        while (bags[bagId].xp >= xpRequired[bags[bagId].level]) {
            bags[bagId].xp -= xpRequired[bags[bagId].level];
            bags[bagId].level += 1;
            _chargeBag(bagId);
        }
    }

    function _chargeBag(uint256 bagId) internal {
        bags[bagId].charges += levelChargeAward[bags[bagId].level];
        removeRiftPower(levelChargeAward[bags[bagId].level] * bags[bagId].level);
    }

    function setupNewBag(uint256 bagId) external {
        require(bags[bagId].level == 0, "bag must be unregistered");
        bags[bagId].level = 1;
        _chargeBag(bagId);
    }

    function convertXP(XP_AMOUNT xp, uint32 bagId) internal view returns (uint32) {
        if (xp == XP_AMOUNT.NONE) { return 0; }
        else if (xp == XP_AMOUNT.TINY) { return bags[bagId].level * xpMultTiny; }
        else if (xp == XP_AMOUNT.MODERATE) { return bags[bagId].level * xpMultMod; }
        else if (xp == XP_AMOUNT.LARGE) { return bags[bagId].level * xpMultLrg; }
        else if (xp == XP_AMOUNT.EPIC) { return bags[bagId].level * xpMultEpc; }

        return 0;
    }

    function growTheRift(address burnableAddr, uint256 tokenId , uint256 bagId) _isBagHolder(bagId, msg.sender) external {
        require(riftObjects[burnableAddr], "Not of the Rift");
        require(ERC721(burnableAddr).ownerOf(tokenId) == _msgSender(), "Must be yours");
        
        _sacrificeRiftObject(burnableAddr, tokenId, bagId);
    }

    function _sacrificeRiftObject(address burnableAddr, uint256 tokenId, uint256 bagId) internal {
        BurnableObject memory bo = IRiftBurnable(burnableAddr).burnObject(tokenId);
        ERC721Burnable(burnableAddr).burn(tokenId);

        addRiftPower(bo.power);
        if (karma[_msgSender()] == 0) { karmaHolders += 1; }
        karmaTotal += bo.power;
        karma[_msgSender()] += bo.power;
        riftObjectsSacrificed += 1;     

        _awardXP(uint32(bagId), XP_AMOUNT.MODERATE);
        iMana.ccMintTo(_msgSender(), bo.mana, 0);
    }

    function topKarmaHolder(address holder) public view returns (bool) {
        if (karma[holder] == 0) return false;
        uint256 medianKarma = karmaTotal / karmaHolders;
        return karma[holder] > (medianKarma * 2);
    }

    // Rift Power
    function addRiftPower(uint64 power) internal {
        riftTierPower += power;
        riftLevel = uint32(riftTierPower/riftPowerPerLevel);

        // up a tier
        if (riftLevel > (riftTier * riftTierSize)) {
            riftTierPower -= riftTierSize * riftPowerPerLevel;
            riftTier += 1;
            riftPowerPerLevel += (riftPowerPerLevel * riftTierIncrease)/100; // add increase as a percentage
        }
    }

    function removeRiftPower(uint64 power) internal {
        if (power > riftTierPower) {
            riftTierPower = 0;
        } else {
            riftTierPower -= power;
        }

        riftLevel = uint32(riftTierPower/riftPowerPerLevel);
    }
}