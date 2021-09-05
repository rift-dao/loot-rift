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
    // Loot contract is available at https://etherscan.io/address/0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7
    address public ccAddress = address(0);
    IERC721Enumerable public crystalsContract;

    constructor() Ownable() ERC20("Mana", "MANA") {
        _mint(_msgSender(), 20);
    }

   	function decimals() public pure override returns (uint8) {
	    	return 0;
	  }

    /// @notice function for Crystals contract to mint on behalf of to
    /// @param recipient address to send mana to
    /// @param amount number of mana to mint
    function ccMintTo(address recipient, uint256 amount) external {
        // Check that the msgSender is from Crystals
        require(_msgSender() == ccAddress, "MUST_BE_FROM_CRYSTALS_CONTRACT");

        _mint(recipient, amount);
    }

    function burn(uint256 amount) external {
      _burn(_msgSender(), amount);
    }

    /// @dev Internal function to mint Loot upon claiming
    // function _claim(uint256 amount, address to) internal {
    //     _mint(to, amount);
    // }

    /// @notice Allows the DAO to mint new tokens for use within the Loot
    /// Ecosystem
    /// @param amountDisplayValue The amount of Loot to mint. This should be
    /// input as the display value, not in raw decimals. If you want to mint
    /// 100 Loot, you should enter "100" rather than the value of 100 * 10^18.
    // function daoMint(uint256 amountDisplayValue) external onlyOwner {
    //     _mint(owner(), amountDisplayValue * (10**decimals()));
    // }

    /// @notice Allows Crystals to migrate
    /// @param ccAddress_ The new contract address for Crystals
    function ownerSetCContractAddress(address ccAddress_)
        external
        onlyOwner
    {
        ccAddress = ccAddress_;
        crystalsContract = IERC721Enumerable(ccAddress);
    }
}