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

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Interfaces.sol";

contract Rift is Ownable {
  // struct to store a stake's token, owner, and earning values

    struct RiftBag {
        uint16 charges;
        uint16 chargesUsed;
        uint16 level;
        address owner;
        uint256 consumed;
        uint256 xp;
  }

  event BagCharged(address owner, uint256 tokenId, uint16 amount);
  event ChargesConsumed(address owner, uint256 tokenId, uint16 amount);
  event CrystalSacraficed(address owner, uint256 tokenId, uint256 powerIncrease);

  uint32 public SACRAFICE_COST = 2;
  uint256 public crystalPower = 0;
  uint256 public crystalsSacraficed = 0;
  uint256 public constant CHARGE_TIME = 1 days;

  ERC721 public iLoot;
  ICrystals public iCrystals;
  address public riftQuests;
  // IMana public iMana;

  string public description = "Unknown";

  mapping(uint256 => RiftBag) public bags;
  mapping(address => uint256) public karma;
  
    mapping(address => uint32) public naughty;
    mapping(uint16 => uint16) public xpRequired;
    mapping(uint16 => uint16) public levelChargeAward;

  constructor(address crystalsAddress) Ownable() {
    iCrystals = ICrystals(crystalsAddress);
  }

  function ownerSetDescription(string memory desc) public onlyOwner {
      description = desc;
  }

  function ownerSetCrystalsAddress(address addr) public onlyOwner {
      iCrystals = ICrystals(addr);
  }

  function ownerSetLootAddress(address addr) public onlyOwner {
      iLoot = ERC721(addr);
  }

  function ownerSetRiftQuestsAddress(address addr) public onlyOwner {
      riftQuests = addr;
  }

  // function ownerSetManaAddress(address addr) public onlyOwner {
  //     iMana = IMana(addr);
  // }

  function getRiftLevel() public view returns (uint256) {
    return 1 + crystalPower / SACRAFICE_COST;
  }

  function chargeBags(uint32[] calldata bagIds, uint16 amount) external {
    for (uint256 i = 0; i < bagIds.length; i++) {
      _charge(bagIds[i], amount);
    }
  }

  function _charge(uint32 bagId, uint16 amount) _bagCheck(bagId) internal {
    //   bags[bagId] = RiftBag({
    //     chargesUsed: _msgSender() != bags[bagId].owner ? 1 : bags[bagId].chargesUsed + 1,
    //     charges: amount,
    //     consumed: bags[bagId].consumed,
    //     owner: _msgSender(),
    //     xp: bags[bagId].xp 
    //   });

      emit BagCharged(_msgSender(), bagId, amount);
  }

  function useCharge(uint32 bagId, uint16 amount) external {
    _useCharge(bagId, amount);
  }

  function _useCharge(uint32 bagId, uint16 amount)
    _bagCheck(bagId)
    internal
  {
    require(bags[bagId].charges >= amount, "NOT ENOUGH CHARGE");

    bags[bagId].chargesUsed += 1;
    bags[bagId].charges -= amount;
    bags[bagId].consumed += amount;

    emit ChargesConsumed(_msgSender(), bagId, amount);
  }

    function awardXP(uint32 bagId, uint32 xp) external {
        require(_msgSender() == riftQuests, "only the worthy");
    
        if (bags[bagId].level == 0) {
            bags[bagId].level = 1;
            bags[bagId].charges = 1;
        }

        bags[bagId].xp += xp;
        
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
        while (bags[bagId].xp > xpRequired[bags[bagId].level]) {
            bags[bagId].xp -= xpRequired[bags[bagId].level];
            bags[bagId].level += 1;
            bags[bagId].charges += levelChargeAward[bags[bagId].level];
        }
    }

    function growTheRift(uint256 crystalId) external {
        _sacrificeCrystal(crystalId);
    }

  function growTheRiftMany(uint256[] calldata crystalIds) external {
    for (uint256 i = 0; i < crystalIds.length; i++) {
      _sacrificeCrystal(crystalIds[i]);
    }
  }

  function _sacrificeCrystal(uint256 crystalId) internal {
    uint256 powerIncrease = iCrystals.crystalsMap(crystalId).level;
    (bool success,) = address(iCrystals).delegatecall(
      abi.encodeWithSignature("burn(uint256)", crystalId)
    );

    if (success) {
      crystalPower += powerIncrease;
      karma[_msgSender()] += powerIncrease;
      crystalsSacraficed += 1;
      emit CrystalSacraficed(_msgSender(), crystalId, powerIncrease);
    }
  }

  modifier _bagCheck(uint32 bagId) {
    require(iLoot.ownerOf(bagId) != _msgSender(), "UNAUTH");
    _;
  }

  function backCheck(uint32 bagId) external view {
    require(iLoot.ownerOf(bagId) != _msgSender(), "UNAUTH");
  }
}
