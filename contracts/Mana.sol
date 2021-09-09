// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Mana (for Adventurers)
/// @notice This contract mints Mana for Crystals
/// @custom:unaudited This contract has not been audited. Use at your own risk.
contract Mana is Context, Ownable, ERC20 {
    address public ccAddress;
    IERC721Enumerable public crystalsContract;

    constructor() Ownable() ERC20("Mana", "MANA") {
        _mint(_msgSender(), 100);
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    /// @notice function for Crystals contract to mint on behalf of to
    /// @param recipient address to send mana to
    /// @param amount number of mana to mint
    function ccMintTo(address recipient, uint256 amount) external {
        // Check that the msgSender is from Crystals
        require(_msgSender() == ccAddress, "Address Not Allowed");

        _mint(recipient, amount);
    }

    function burnFrom(address account, uint256 amount) external {
        uint256 amountAllowed = allowance(account, _msgSender());
        require(amount <= amountAllowed, "Not allowed to burn from this address");
        _approve(account, _msgSender(), balanceOf(account) - amount);
        _burn(account, amount);
    }

    function mint(uint256 amount) external {
        _mint(_msgSender(), amount);
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    /// @notice Allows Crystals to migrate
    /// @param ccAddress_ The new contract address for Crystals
    function ownerSetCContractAddress(address ccAddress_) external onlyOwner {
        ccAddress = ccAddress_;
        crystalsContract = IERC721Enumerable(ccAddress);
    }
}
