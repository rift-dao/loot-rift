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
    address public gaAddress = 0x8dB687aCEb92c66f013e1D614137238Cc698fEdb;
    IERC721Enumerable public crystalsContract;
    IERC721Enumerable public gaContract;

    // GA Mana claim code borrowed from AGLD contract
    // Give out 100,000 Mana for every GA that a user holds
    uint256 public manaPerGATokenId = 100000 * (10**decimals());

     // Seasons are used to allow users to claim tokens regularly. Seasons are
    // decided by the DAO.
    uint256 public gaSeason = 0;
    uint256 public gaTokenIdStart = 1;
    uint256 public gaTokenIdEnd = 2540;

    // Track claimed tokens within a season
    // IMPORTANT: The format of the mapping is:
    // claimedForSeason[season][tokenId][claimed]
    mapping(uint256 => mapping(uint256 => bool)) public gaSeasonClaimedByTokenId;

    constructor() Ownable() ERC20("Mana", "MANA") {
        //_mint(_msgSender(), 100);
        gaContract = IERC721Enumerable(gaAddress);
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function symbol() public pure override returns (string memory) {
        return "AMNA";
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
        require(_msgSender() == ccAddress, "Address Not Allowed");
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

    /// @notice Claim Mana for a given GA ID
    /// @param tokenId The tokenId of the GA NFT
    function claimById(uint256 tokenId) external {
        // Follow the Checks-Effects-Interactions pattern to prevent reentrancy
        // attacks

        // Checks

        // Check that the msgSender owns the token that is being claimed
        require(
            _msgSender() == gaContract.ownerOf(tokenId),
            "MUST_OWN_TOKEN_ID"
        );

        // Further Checks, Effects, and Interactions are contained within the
        // _claim() function
        _claim(tokenId, _msgSender());
    }

    /// @notice Claim Mana for all GA tokens owned by the sender
    /// @notice This function will run out of gas if you have too many GAs! If
    /// this is a concern, you should use claimRangeForOwner and claim 
    /// Mana in batches.
    function claimAllForOwner() external {
        uint256 tokenBalanceOwner = gaContract.balanceOf(_msgSender());

        // Checks
        require(tokenBalanceOwner > 0, "NO_TOKENS_OWNED");

        // i < tokenBalanceOwner because tokenBalanceOwner is 1-indexed
        for (uint256 i = 0; i < tokenBalanceOwner; i++) {
            // Further Checks, Effects, and Interactions are contained within
            // the _claim() function
            _claim(
                gaContract.tokenOfOwnerByIndex(_msgSender(), i),
                _msgSender()
            );
        }
    }

    /// @notice Claim Mana for all tokens owned by the sender within a
    /// given range
    /// @notice This function is useful if you own too many Mana to claim all at
    /// once or if you want to leave some GA unclaimed. If you leave GAs
    /// unclaimed, however, you cannot claim it once the next season starts.
    function claimRangeForOwner(uint256 ownerIndexStart, uint256 ownerIndexEnd)
        external
    {
        uint256 tokenBalanceOwner = gaContract.balanceOf(_msgSender());

        // Checks
        require(tokenBalanceOwner > 0, "NO_TOKENS_OWNED");

        // We use < for ownerIndexEnd and tokenBalanceOwner because
        // tokenOfOwnerByIndex is 0-indexed while the token balance is 1-indexed
        require(
            ownerIndexStart >= 0 && ownerIndexEnd < tokenBalanceOwner,
            "INDEX_OUT_OF_RANGE"
        );

        // i <= ownerIndexEnd because ownerIndexEnd is 0-indexed
        for (uint256 i = ownerIndexStart; i <= ownerIndexEnd; i++) {
            // Further Checks, Effects, and Interactions are contained within
            // the _claim() function
            _claim(
                gaContract.tokenOfOwnerByIndex(_msgSender(), i),
                _msgSender()
            );
        }
    }

    /// @dev Internal function to mint GA upon claiming
    function _claim(uint256 tokenId, address tokenOwner) internal {
        // Checks
        // Check that the token ID is in range
        // We use >= and <= to here because all of the token IDs are 0-indexed
        require(
            tokenId >= gaTokenIdStart && tokenId <= gaTokenIdEnd,
            "TOKEN_ID_OUT_OF_RANGE"
        );

        // Check that Mana have not already been claimed this season
        // for a given tokenId
        require(
            !gaSeasonClaimedByTokenId[gaSeason][tokenId],
            "MANA_CLAIMED_FOR_TOKEN_ID"
        );

        // Effects

        // Mark that Mana has been claimed for this season for the
        // given tokenId
        gaSeasonClaimedByTokenId[gaSeason][tokenId] = true;

        // Interactions

        // Send Mana to the owner of the token ID
        _mint(tokenOwner, manaPerGATokenId);
    }

    /// @notice Allows the DAO to set a new contract address for GA. This is
    /// relevant in the event that GA migrates to a new contract.
    /// @param gaContractAddress_ The new contract address for GA
    function daoSetGAContractAddress(address gaContractAddress_)
        external
        onlyOwner
    {
        gaAddress = gaContractAddress_;
        gaContract = IERC721Enumerable(gaContractAddress_);
    }

    /// @notice Allows the DAO to set the token IDs that are eligible to claim
    /// Mana
    /// @param tokenIdStart_ The start of the eligible token range
    /// @param tokenIdEnd_ The end of the eligible token range
    /// @dev This is relevant in case a future GA contract has a different
    /// total supply of GA
    function daoSetGATokenIdRange(uint256 tokenIdStart_, uint256 tokenIdEnd_)
        external
        onlyOwner
    {
        gaTokenIdStart = tokenIdStart_;
        gaTokenIdEnd = tokenIdEnd_;
    }

    /// @notice Allows the DAO to set a season for new Mana claims
    /// @param season_ The season to use for claiming GA Mana
    function daoSetSeason(uint256 season_) public onlyOwner {
        gaSeason = season_;
    }

    function daoSetManaPerGATokenId(uint256 manaDisplayValue)
        public
        onlyOwner
    {
        manaPerGATokenId = manaDisplayValue * (10**decimals());
    }

    /// @notice Allows the DAO to set the season and Mana per token ID
    /// in one transaction. This ensures that there is not a gap where a user
    /// can claim more Mana than others
    /// @param season_ The season to use for claiming Mana from a GA
    /// @param manaDisplayValue The amount of Mana a user can claim.
    /// This should be input as the display value, not in raw decimals. If you
    /// want to mint 100 Mana, you should enter "100" rather than the value of
    /// 100 * 10^18.
    /// @dev We would save a tiny amount of gas by modifying the season and
    /// Mana variables directly. It is better practice for security,
    /// however, to avoid repeating code. This function is so rarely used that
    /// it's not worth moving these values into their own internal function to
    /// skip the gas used on the modifier check.
    function daoSetSeasonAndManaPerGATokenID(
        uint256 season_,
        uint256 manaDisplayValue
    ) external onlyOwner {
        daoSetSeason(season_);
        daoSetManaPerGATokenId(manaDisplayValue);
    }
}
