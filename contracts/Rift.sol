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
      uint16 attunement;
      address owner;
      uint256 consumed;
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
  // IMana public iMana;

  string public description = "Unknown";

  mapping(uint256 => RiftBag) public bags;
  mapping(address => uint256) public karma;
  
  mapping(address => uint32) public naughty;

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
      bags[bagId] = RiftBag({
        attunement: _msgSender() != bags[bagId].owner ? 1 : bags[bagId].attunement + 1,
        charges: amount,
        consumed: bags[bagId].consumed,
        owner: _msgSender()
      });

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

    bags[bagId].attunement += 1;
    bags[bagId].charges -= amount;
    bags[bagId].consumed += amount;

    emit ChargesConsumed(_msgSender(), bagId, amount);
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
}
