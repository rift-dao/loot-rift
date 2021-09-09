/*

 _______  _______           _______ _________ _______  _        _______ 
(  ____ \(  ____ )|\     /|(  ____ \\__   __/(  ___  )( \      (  ____ \   (for Adventurers) 
| (    \/| (    )|( \   / )| (    \/   ) (   | (   ) || (      | (    \/
| |      | (____)| \ (_) / | (_____    | |   | (___) || |      | (_____ 
| |      |     __)  \   /  (_____  )   | |   |  ___  || |      (_____  )
| |      | (\ (      ) (         ) |   | |   | (   ) || |            ) |
| (____/\| ) \ \__   | |   /\____) |   | |   | )   ( || (____/\/\____) |
(_______/|/   \__/   \_/   \_______)   )_(   |/     \|(_______/\_______)
                                                                       
                                                                        
    by chris and tony
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IMANA {
    function approve(address spender, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function balanceOf(address owner) external returns (uint256);
    function ccMintTo(address recipient, uint256 amount) external;
}

contract Crystals is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    ReentrancyGuard,
    Ownable
{
    using strings for string;
    using strings for strings.slice;

    // https://etherscan.io/address/0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7
    ERC721 public constant loot =
        ERC721(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7);
    // https://etherscan.io/address/0x1dfe7Ca09e99d10835Bf73044a23B73Fc20623DF
    ERC721 public constant mLoot =
        ERC721(0x1dfe7Ca09e99d10835Bf73044a23B73Fc20623DF);

    address public manaAddress;
    IMANA public mana;

    string private constant cursedPrefixes =
        "Dull,Broken,Twisted,Cracked,Fragmented,Splintered,Beaten,Ruined";
    uint256 private constant cursedPrefixesLength = 8;

    string private constant cursedSuffixes =
        "of Rats,of Crypts,of Nightmares,of Sadness,of Darkness,of Death,of Doom,of Gloom,of Madness";
    uint256 private constant cursedSuffixesLength = 9;

    string private constant prefixes =
        "Gleaming,Glowing,Shiny,Smooth,Faceted,Glassy,Polished,Sheeny,Luminous";
    uint256 private constant prefixesLength = 9;

    string private constant suffixes =
        "of Power,of Giants,of Titans,of Skill,of Perfection,of Brilliance,of Enlightenment,of Protection,of Anger,of Rage,of Fury,of Vitriol,of the Fox,of Detection,of Reflection,of the Twins,of Relevance,of the Rift";
    uint256 private constant suffixesLength = 18;

    string private constant colors =
        "Beige,Blue,Green,Red,Cyan,Yellow,Orange,Pink,Gray,White,Brown,Purple";
    uint256 private constant colorsLength = 12;

    string private constant specialColors =
        "Aqua,black,Crimson,Ghostwhite,Indigo,Turquoise,Maroon,Magenta,Fuchsia,Firebrick,Hotpink";
    uint256 private constant specialColorsLength = 11;

    string private constant slabs = "&#9698;,&#9699;,&#9700;,&#9701;";
    uint256 private constant slabsLength = 4;

    uint256 private constant _MAX = 10000000;

    struct Visits {
        uint64 lastCharge;
        uint64 lastLevelUp;
    }
    mapping(uint256 => Visits) public visits;

    constructor(address manaAddress_)
        ERC721("Loot Crystals", "CRYSTAL")
        Ownable()
    {
        manaAddress = manaAddress_;
        mana = IMANA(manaAddress);
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input, "%CRYSTALS")));
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256)
    {
        require(fromTimestamp <= toTimestamp);
        return (toTimestamp - fromTimestamp) / (24 * 60 * 60);
    }

    
    function slabRow(uint256 tokenId, uint256 row, uint256 y) internal pure returns (string memory output) {
        output = "";
        for (uint i = 1; i < 19; i++) {
            output = string(abi.encodePacked(
                output,
                getSlab(tokenId, i + ((row - 1) * 18))
            ));
        }

        output = string(abi.encodePacked(
            '<text class="slab" x="285" y="', toString(y), '">',
            output,
            '</text>'
        ));

        return output;
    }


    // function getSlab(uint256 tokenId, uint256 indexX, uint indexY) internal pure returns (string memory)  {
    //     uint256 rand = getRandom(tokenId, string(abi.encodePacked("SLAB_", toString(indexX), toString(indexY))), true);

    //     return getItemFromCSV(slabs, rand % slabsLength);
    // }

    // function sqrt(uint x) internal pure returns (uint y) {
    //     uint z = (x + 1) / 2;
    //     y = x;
    //     while (z < y) {
    //         y = z;
    //         z = (x / z + z) / 2;
    //     }
    // }

    function tokenURI(uint256 tokenId)
        public
        pure
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        string memory output;
        // rate at which opacity changes
        uint256 period = (getResonance(tokenId) % 4) + 1;

        // max opacity
        // uint256 rotation = getSpin(tokenId) % 360;

        string memory color = getColor(tokenId);

        string memory styles = string(
            abi.encodePacked(
                "<style>@keyframes glow{0%{text-shadow:0 0 12px ",
                color,
                "}77%{text-shadow:0 0 20px ",
                color,
                "}99%{text-shadow:0 0 11px ",
                color,
                "; }}",
                "@keyframes blink {",
                toString(period * 10),
                "% { opacity: 0; }",
                toString((period * 10) + 20),
                "% { opacity: 1; }}"
            )
        );

        styles = string(
            abi.encodePacked(
                styles,
                "text{fill:",
                color,
                ";font-family:serif;font-size:14px}.slab{transform:rotate(180deg)translate(75px, 79px);",
                "transform-origin:bottom right;font-size:22px; animation:glow ",
                toString(period + 1),
                "s ease-in-out infinite}</style>"
            )
        );

        output = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
                styles,
                '<rect width="100%" height="100%" fill="',
                getRandom(tokenId, "%IS_ANCIENT") % 100000 == 1 ? "white" : "black",
                '" /><text x="10" y="20">',
                getName(tokenId),
                (
                    getLevel(tokenId) > 1
                        ? string(
                            abi.encodePacked(
                                " +",
                                toString(getLevel(tokenId) - 1)
                            )
                        )
                        : ""
                )
            )
        );

        output = string(
            abi.encodePacked(
                output,
                '</text><text x="10" y="40">',
                "Resonance: ",
                toString(getResonance(tokenId)),
                '</text>'
            )
        );
        output = string(
            abi.encodePacked(
                output,
                '<text x="10" y="60">',
                "Spin: ",
                toString(getSpin(tokenId)),
                '</text>'
            )
        );

        // output = string(
        //     abi.encodePacked(
        //         output, 
        //         formSlabs(tokenId), '</text></svg>'
        //     )
        // );

        // ROW 1
        output = string(
            abi.encodePacked(
                output,
                slabRow(tokenId, 1, 295),
                slabRow(tokenId, 2, 314),
                slabRow(tokenId, 3, 333),
                slabRow(tokenId, 4, 352),
                slabRow(tokenId, 5, 371),
                slabRow(tokenId, 6, 390)
        ));

        output = string(
            abi.encodePacked(
                output,
                slabRow(tokenId, 7, 409),
                slabRow(tokenId, 8, 428),
                slabRow(tokenId, 9, 447),
                slabRow(tokenId, 10, 466),
                slabRow(tokenId, 11, 485),
                '</svg>'
        ));

        // output = string(
        //     abi.encodePacked(
        //         output,
        //         getSlab(tokenId, 7),
        //         getSlab(tokenId, 8),
        //         getSlab(tokenId, 9),
        //         getSlab(tokenId, 10),
        //         getSlab(tokenId, 11),
        //         getSlab(tokenId, 12)
        //     )
        // );

        // // ROW 2
        // output = string(
        //     abi.encodePacked(
        //         output,
        //         '</text><text x="285" y="314" class="slab">',
        //         getSlab(tokenId, 13),
        //         getSlab(tokenId, 14),
        //         getSlab(tokenId, 15),
        //         getSlab(tokenId, 16),
        //         getSlab(tokenId, 17),
        //         getSlab(tokenId, 18)
        // ));
                
        // output = string(
        //     abi.encodePacked(
        //         output,
        //         getSlab(tokenId, 19),
        //         getSlab(tokenId, 20),
        //         getSlab(tokenId, 21),
        //         getSlab(tokenId, 22),
        //         getSlab(tokenId, 23),
        //         getSlab(tokenId, 24)
        //     )
        // );

        // // ROW 3
        // output = string(
        //     abi.encodePacked(
        //         output,
        //         '<text x="285" y="333" class="slab">',
        //         getSlab(tokenId, 25),
        //         getSlab(tokenId, 26),
        //         getSlab(tokenId, 27),
        //         getSlab(tokenId, 28),
        //         getSlab(tokenId, 29),
        //         getSlab(tokenId, 30)
        // ));

        // output = string(
        //     abi.encodePacked(
        //         output,
        //         getSlab(tokenId, 31),
        //         getSlab(tokenId, 32),
        //         getSlab(tokenId, 33),
        //         getSlab(tokenId, 34),
        //         getSlab(tokenId, 35),
        //         getSlab(tokenId, 36),
        //         "</text></svg>"
        //     )
        // );

        string memory stats = string(
            abi.encodePacked(
                '"stats": { "level": ',
                toString(getLevel(tokenId)),
                ', "resonance": ',
                toString(getResonance(tokenId)),
                ', "spin": ',
                toString(getSpin(tokenId)),
                " }"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"id": ',
                        toString(tokenId),
                        ', "name": "Crystal #',
                        toString(originalSeed(tokenId)),
                        '", ',
                        stats,
                        ', "description": "This crystal vibrates with energy from the Rift!", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function claim(uint256 tokenId) public {
        uint256 asLoot = tokenId < 8001 ? 1 : 0;
        mana.ccMintTo(_msgSender(), asLoot == 1 ? 3 : 1);
        _claim(tokenId);
    }

    function claimWithMLoot(uint256 tokenId) public {
        require(tokenId > 8000 && tokenId < _MAX, "Token ID for mLoot invalid");
        require(mLoot.ownerOf(tokenId) == _msgSender(), "Not mLoot owner");
        mana.ccMintTo(_msgSender(), 1);
        _claim(tokenId);
    }

    function claimWithLoot(uint256 tokenId) public nonReentrant {
        require(tokenId > 0 && tokenId < 8001, "Token ID for Loot invalid");
        require(loot.ownerOf(tokenId) == _msgSender(), "Not Loot owner");
        mana.ccMintTo(_msgSender(), 3);
        _claim(tokenId);
    }

    function _claim(uint256 tokenId) internal {
        visits[tokenId].lastCharge = uint64(block.timestamp);
        visits[tokenId].lastLevelUp = uint64(block.timestamp);

        _safeMint(_msgSender(), tokenId);
    }

    function chargeCrystal(uint256 tokenId) public nonReentrant {
        require(ownerOf(tokenId) == _msgSender(), "Not Crystal owner");

        uint256 daysSinceCharge = diffDays(
            visits[tokenId].lastCharge,
            block.timestamp
        );
        require(
            daysSinceCharge >= 1,
            "You must wait before you can charge this Crystal again"
        );

        uint256 manaGained = daysSinceCharge * getResonance(tokenId);
        if (manaGained > getSpin(tokenId)) {
            manaGained = getSpin(tokenId);
        }

        visits[tokenId].lastCharge = uint64(block.timestamp);
        mana.ccMintTo(_msgSender(), manaGained);
    }

    // in order to level up the crystal must reach max capacity (d * mb >= cap)
    // leveling up burns the crystal and mints a new one with id = _MAX + old.id
    // leveling up also gains bonus mana equal to level - 1
    function levelUpCrystal(uint256 tokenId) public nonReentrant {
        require(ownerOf(tokenId) == _msgSender(), "Not Crystal owner");
        require(mana.balanceOf(_msgSender()) >= getSpin(tokenId), "Not enough Mana");
        
        // time since last charge
        uint256 dayDiff = diffDays(
            visits[tokenId].lastCharge,
            block.timestamp
        );
        uint256 isMaxCharge = dayDiff * getResonance(tokenId) >=
            getSpin(tokenId)
            ? 1
            : 0;
        require(isMaxCharge == 1, "This crystal is not ready to be leveled up");
        
        // mana.approve(manaAddress, getSpin(tokenId));
        // mana.burn(getSpin(tokenId));

        _burn(tokenId);
        _claim(tokenId + _MAX);
        mana.ccMintTo(_msgSender(), getLevel(tokenId + _MAX) - 1);

        // req
        // last level up was >= (d * mb) days ago
        // has not been transfered in cap days

        // # of days since last level up or transfer * mana bonus
        // if lup.days_ago >= cap
        // levelUpClaim(_MAX + tokenId)
        // mana.mint(level - 1)
    }

    function originalSeed(uint256 tokenId) internal pure returns (uint256) {
        if (tokenId <= _MAX) {
            return tokenId;
        }

        return tokenId - (_MAX * (tokenId / _MAX));
    }

    function getRandom(uint256 tokenId, string memory key)
        internal
        pure
        returns (uint256)
    {
        uint256 oSeed = originalSeed(tokenId);

        return random(string(abi.encodePacked(oSeed, key)));
    }

    // This will always return a random number based on tokenId, NOT the original seed!
    function getRandom(
        uint256 tokenId,
        string memory key,
        bool skipSeed
    ) internal pure returns (uint256) {
        return random(string(abi.encodePacked(tokenId, skipSeed ? key : key)));
    }

    function getRoll(
        uint256 tokenId,
        string memory key,
        uint256 size,
        uint256 times
    ) internal pure returns (uint256) {
        return ((getRandom(tokenId, key) % size) + 1) * times;
    }

    // This will always return a roll based on tokenId, NOT the original seed!
    function getRoll(
        uint256 tokenId,
        string memory key,
        uint256 size,
        uint256 times,
        bool skipSeed
    ) internal pure returns (uint256) {
        return ((getRandom(tokenId, key, skipSeed) % size) + 1) * times;
    }

    // return dice rolls for each level
    function getLevelRolls(
        uint256 tokenId,
        string memory key,
        uint256 size,
        uint256 times
    ) internal pure returns (uint256) {
        uint256 oSeed = originalSeed(tokenId);
        uint256 index = 1;
        uint256 score = getRoll(tokenId, key, size, times);

        while (index < getLevel(tokenId)) {
            score += getRoll((index * _MAX) + oSeed, key, size, times, true);
            index++;
        }

        return score;
    }

    function getLevel(uint256 tokenId) public pure returns (uint256) {
        uint256 oSeed = originalSeed(tokenId);
        if (oSeed == tokenId) {
            return 1;
        }

        return (tokenId / _MAX) + 1;
    }

    function getResonance(uint256 tokenId) public pure returns (uint256) {
        return getLevelRolls(tokenId, "%RESONANCE", 2, 1);
    }

    function getSpin(uint256 tokenId) public pure returns (uint256) {
        uint256 level = getLevel(tokenId);

        if (level == 1) {
            return 1 + getLevelRolls(tokenId, "%SPIN", 2, 1);
        } else {
            return 5 * (level - 1) + getLevelRolls(tokenId, "%SPIN", 2, 1) - 1;
        }
    }

    function getColor(uint256 tokenId) public pure returns (string memory) {
        uint256 rand = getRandom(tokenId, "%COLOR");
        uint256 colorSpecialness = getRoll(tokenId, "%COLOR_RARITY", 20, 1);

        if (colorSpecialness > 18) {
            return getItemFromCSV(specialColors, rand % specialColorsLength);
        }

        return getItemFromCSV(colors, rand % colorsLength);
    }

    function getName(uint256 tokenId) public pure returns (string memory) {
        uint256 oSeed = originalSeed(tokenId);
        uint256 isFromLoot = oSeed > 0 && oSeed < 8001 ? 1 : 0;

        return isFromLoot == 1 ? getLootName(oSeed) : getBasicName(oSeed);
        // return level > 1 ? string(abi.encodePacked(isFromLoot == 1 ? getLootName(oSeed) : getBasicName(oSeed), " +", level)) : isFromLoot == 1 ? getLootName(oSeed) : getBasicName(oSeed);
    }

    function getBasicName(uint256 tokenId)
        internal
        pure
        returns (string memory)
    {
        uint256 rand = getRandom(tokenId, "%BASIC_NAME");
        uint256 alignment = getRoll(tokenId, "%ALIGNMENT", 20, 1);
        uint256 colorSpecialness = getRoll(tokenId, "%COLOR_RARITY", 20, 1);
        uint256 isAncient = getRandom(tokenId, "%IS_ANCIENT") % 100000;

        string memory output = "";

        if (alignment == 10 && colorSpecialness == 10 && isAncient != 1) {
            output = "Average Crystal";
        } else if (alignment == 1) {
            output = string(
                abi.encodePacked(
                    "Crystal ",
                    getItemFromCSV(cursedSuffixes, rand % cursedSuffixesLength)
                )
            );
        } else if (alignment == 20) {
            output = string(
                abi.encodePacked(
                    "Crystal ",
                    getItemFromCSV(suffixes, rand % suffixesLength)
                )
            );
        } else if (alignment < 3) {
            output = string(
                abi.encodePacked(
                    getItemFromCSV(cursedPrefixes, rand % cursedPrefixesLength),
                    " Crystal"
                )
            );
        } else if (alignment > 18) {
            output = string(
                abi.encodePacked(
                    getItemFromCSV(prefixes, rand % prefixesLength),
                    " Crystal"
                )
            );
        } else {
            output = string(abi.encodePacked("Crystal"));
        }

        if (isAncient == 1) {
            output = string(abi.encodePacked("Ancient ", output));
        }

        return output;
    }

    function getLootName(uint256 tokenId)
        internal
        pure
        returns (string memory)
    {
        uint256 rand = getRandom(tokenId, "%LOOT_NAME");
        uint256 alignment = getRoll(tokenId, "%ALIGNMENT", 20, 1);
        uint256 colorSpecialness = getRoll(tokenId, "%COLOR_RARITY", 20, 1);
        uint256 isAncient = getRandom(tokenId, "%IS_ANCIENT") % 100000;

        string memory output = "";

        // average
        if (alignment == 10 && colorSpecialness == 10) {
            output = "Perfectly Average Crystal";
        }
        // cursed
        else if (alignment < 3) {
            output = string(
                abi.encodePacked(
                    (alignment == 1 ? "Demonic Crystal " : "Crystal "),
                    getItemFromCSV(cursedSuffixes, rand % cursedSuffixesLength)
                )
            );
        }
        // standard
        else if (alignment < 17) {
            output = string(
                abi.encodePacked(
                    getItemFromCSV(prefixes, rand % prefixesLength),
                    " Crystal"
                )
            );
        }
        // good
        else if (alignment > 16 && alignment < 20) {
            output = string(
                abi.encodePacked(
                    getItemFromCSV(prefixes, rand % prefixesLength),
                    " Crystal ",
                    getItemFromCSV(suffixes, rand % suffixesLength)
                )
            );
        }
        // great
        else if (alignment == 20) {
            output = string(
                abi.encodePacked(
                    "Divine ",
                    " Crystal ",
                    getItemFromCSV(suffixes, rand % suffixesLength)
                )
            );
        }
        // shouldn't happen lol
        else {
            output = "Forgotten Crystal";
        }

        if (isAncient == 1) {
            output = string(abi.encodePacked("Ancient ", output));
        }

        return output;
        // return string(abi.encodePacked(toString(alignment), " - ", output));
    }

    // each index has a random start
    // slab should be level + rstart
    function getSlab(uint256 tokenId, uint256 slot)
        public
        pure
        returns (string memory)
    {
        uint256 csvIndex = getRandom(
            tokenId,
            string(abi.encodePacked("SLAB_", toString(slot)))
        ) % slabsLength;
        uint256 level = getLevel(tokenId);
        csvIndex = (csvIndex + (level - 1)) % slabsLength;
        if (csvIndex > 3) {
            csvIndex = 0;
        }

        return
            level > 1 && slot < level ? getItemFromCSV(slabs, csvIndex) : " ";
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function getItemFromCSV(string memory str, uint256 index)
        internal
        pure
        returns (string memory)
    {
        strings.slice memory strSlice = str.toSlice();
        string memory separatorStr = ",";
        strings.slice memory separator = separatorStr.toSlice();
        strings.slice memory item;
        for (uint256 i = 0; i <= index; i++) {
            item = strSlice.split(separator);
        }
        return item.toString();
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    // function tokenURI(uint256 tokenId)
    //     public
    //     view
    //     override(ERC721, ERC721URIStorage)
    //     returns (string memory)
    // {
    //     return super.tokenURI(tokenId);
    // }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

// pragma solidity ^0.8.0;

library strings {
    struct slice {
        uint256 _len;
        uint256 _ptr;
    }

    function memcpy(
        uint256 dest,
        uint256 src,
        uint256 len
    ) private pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string memory self) internal pure returns (slice memory) {
        uint256 ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice memory self) internal pure returns (string memory) {
        string memory ret = new string(self._len);
        uint256 retptr;
        assembly {
            retptr := add(ret, 32)
        }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(
        uint256 selflen,
        uint256 selfptr,
        uint256 needlelen,
        uint256 needleptr
    ) private pure returns (uint256) {
        uint256 ptr = selfptr;
        uint256 idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2**(8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly {
                    needledata := and(mload(needleptr), mask)
                }

                uint256 end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly {
                    ptrdata := and(mload(ptr), mask)
                }

                while (ptrdata != needledata) {
                    if (ptr >= end) return selfptr + selflen;
                    ptr++;
                    assembly {
                        ptrdata := and(mload(ptr), mask)
                    }
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly {
                    hash := keccak256(needleptr, needlelen)
                }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly {
                        testHash := keccak256(ptr, needlelen)
                    }
                    if (hash == testHash) return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(
        slice memory self,
        slice memory needle,
        slice memory token
    ) internal pure returns (slice memory) {
        uint256 ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice memory self, slice memory needle)
        internal
        pure
        returns (slice memory token)
    {
        split(self, needle, token);
    }
}
