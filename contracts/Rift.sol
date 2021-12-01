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
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IMANA {
    function ccMintTo(address recipient, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

struct Bag {
        uint64 generation;
        bool isCharged;
    }   

interface IRift {
    function bagsMap(uint256 bagId) external view returns (Bag memory);
    function useCharge(uint256 bagId, address bagOwner) external; 
}

/// @title a Rift has opened 
contract Rift is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    ReentrancyGuard,
    Ownable,
    Pausable
{  
    mapping(address => bool) controllers;

    IMANA public iMana;
    ERC721 public iLoot = ERC721(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7);
    ERC721 public iMLoot = ERC721(0x1dfe7Ca09e99d10835Bf73044a23B73Fc20623DF);

    /// @dev indexed by bagId
    mapping(uint256 => Bag) public bagsMap;

    struct RiftVentureCost {
        uint256 manaCost;
    }
    mapping(uint256 => RiftVentureCost) public riftCost;

    mapping(uint64 => uint256) public generationRegistry;

    constructor(address manaAddress) ERC721("The Rift", "RIFT") Ownable() {
        iMana = IMANA(manaAddress);
    }

    //WRITE

    function chargeBag(uint256 bagId) external whenNotPaused nonReentrant {
        require(bagsMap[bagId].isCharged == false, "already charged");

        isBagHolder(bagId, _msgSender());

        uint256 cost = 0;
        // first taste is always free
        if (bagsMap[bagId].generation > 0) {
            require(riftCost[bagsMap[bagId].generation + 1].manaCost > 0, "GEN NOT AVL"); 
            cost = getRegistrationCost(bagsMap[bagId].generation + 1);
            if (bagId > 8000) cost = cost / 10; // mLoot discount
        }

        iMana.burn(_msgSender(), cost);
        bagsMap[bagId].isCharged = true;

        generationRegistry[bagsMap[bagId].generation + 1] += 1;
    }

    function useCharge(uint256 bagId, address from) external whenNotPaused nonReentrant {
        require(controllers[msg.sender], "Only controllers can use charge");
        require(bagsMap[bagId].isCharged, "not charged");
        isBagHolder(bagId, from);

        bagsMap[bagId].isCharged = false;
        bagsMap[bagId].generation += 1;
    }

    // READ 

    function getRegistrationCost(uint64 genNum) public view returns (uint256) {
        uint256 cost = riftCost[genNum].manaCost - generationRegistry[genNum];
        return cost < (riftCost[genNum].manaCost / 10) ? (riftCost[genNum].manaCost / 10) : cost;
    }

    // Owner

    function ownerSetLootAddress(address addr) external onlyOwner {
        iLoot = ERC721(addr);
    }

    function ownerSetManaAddress(address addr) external onlyOwner {
        iMana = IMANA(addr);
    }

    function ownerSetMLootAddress(address addr) external onlyOwner {
        iMLoot = ERC721(addr);
    }

    /**
    * enables an address to mint / burn
    * @param controller the address to enable
    */
    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    /**
    * disables an address from minting / burning
    * @param controller the address to disbale
    */
    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }

    function ownerSetRiftVentureCost(uint256 generation, uint256 manaCost_) external onlyOwner {
        riftCost[generation].manaCost = manaCost_;
    }

    function ownerWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    // HELPER

    function isBagHolder(uint256 bagId, address owner) private view {
        if (bagId < 8001) {
            require(iLoot.ownerOf(bagId) == owner, "UNAUTH");
        } else {
            require(iMLoot.ownerOf(bagId) == owner, "UNAUTH");
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

     function tokenURI(uint256 tokenId) 
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory) 
    {
        return super.tokenURI(tokenId);
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
}