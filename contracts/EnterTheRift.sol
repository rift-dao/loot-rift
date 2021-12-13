// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Interfaces.sol";
import "./IRift.sol";

contract EnterTheRift is Ownable, IRiftQuest {

    mapping(uint64 => QuestStep) public steps;
    mapping(uint256 => BagProgress) public bagsProgress_;
    // address[] public chainedQuests;
    uint32 private _numSteps;

    ICrystals public iCrystals;
    ERC20 public iMana;
    
    address riftQuest;

    constructor(address riftQuest_, address crystals_, address mana_) Ownable() {
        iCrystals = ICrystals(crystals_);
        riftQuest = riftQuest_;
        iMana = ERC20(mana_);

        _numSteps = 3;
        
        steps[1].requirements = "Step into the Rift";
        steps[1].description = ["Ever since you first picked up that bag, you've",
                                "felt drawn to this place. Now you see what beckons",
                                "you, a chaotic rip in reality. You're struck with",
                                "pure fear, and yet you cannot help but step towards it."];
        steps[1].result =       ["You didn't venture far, a few feet maybe. You couldn't",
                                "stand the tremendous force for more than a few moments.",
                                "You're not ready.", 
                                "","~~you got a rift charge~~"];
        steps[1].xp = 50;

        steps[2].requirements = "Distill a Crystal";
        steps[2].description =  ["You've returned to camp to make sense of what you",
                                "experienced, when you notice that same strange force",
                                "emanating from your bag."];
        steps[2].result =       ["You peek inside, and see the glowing force crystalize",
                                "before your eyes. It's glowing with the Rift's power...",
                                "","~~you made a crystal!~~"];
        steps[2].xp = 50;

        steps[3].requirements = "Claim Mana";
        steps[3].description = ["You take the Crystal out of your bag, it's heavier ",
                                "than it looks."];
        steps[3].result =       ["Its glow intensifies, and you feel a powerful energy",
                                "move from the Crystal into you.",
                                "","~~you gained mana~~"];
        steps[3].xp = 50;
    }

    // step logic 
    
    function completeStep(uint32 step, uint256 bagId, address from) override public {
        require(_msgSender() == riftQuest, "must be interacted through RiftQuests");
        require(bagsProgress_[bagId].lastCompletedStep < step, "you've completed this step already");

        if (step == 1) {
            // owner bag check performed by RiftQuests
            bagsProgress_[bagId].lastCompletedStep = 1;

        } else if (step == 2) {
            // verify bag made a crystal
            require(iCrystals.bags(bagId).mintCount > 0, "Make a Crystal");
            bagsProgress_[bagId].lastCompletedStep = 2;
        } else if (step == 3) {
            require(iMana.balanceOf(from) > 0, "Claim your Mana");
            bagsProgress_[bagId].lastCompletedStep = 3;
            bagsProgress_[bagId].completedQuest = true;
        }
    }

    //IRiftQuest

    function title() override public pure returns (string memory) {
        return "Enter the Rift";
    }

    function numSteps() override public view returns (uint64) {
        return _numSteps;
    }

    function canStartQuest(uint256 /*bagId*/) override public pure returns (bool) {
        return true;
    }

    function isCompleted(uint256 bagId) override public view returns (bool) {
        return bagsProgress_[bagId].completedQuest;
    }

    function currentStep(uint256 bagId) override public view returns (QuestStep memory) {
        return steps[bagsProgress_[bagId].lastCompletedStep + 1];
    }

    function stepAwardXP(uint64 step) external view returns (uint16) {
        return steps[step].xp;
    }

    function bagsProgress(uint256 bagId) override public view returns (BagProgress memory) {
        return bagsProgress_[bagId];
    }

    function buildMessage(uint start, string[] memory strings) internal pure returns (string memory) {
        string memory output;

        uint _i = 0;
        uint _xoffset = 20;
        while (_i < strings.length) {
            if (_i > 0) { _xoffset = 10; }
            output = string(
                abi.encodePacked(
                    output,
                    '</text><text x="',
                    toString(_xoffset),
                    '" y="',
                    toString(_i * 20 + start),
                    '">',
                    strings[_i]
                )
            );
            _i+=1;
        }

        return output;
    }

    // function testTokenURI(uint64 step) external view returns (string memory) {
    //     string memory output;

    //     string memory status = string(
    //         abi.encodePacked(
    //             'Step ',
    //             toString(step),
    //             ' out of 3'
    //         )
    //     );
    //     if (step == 4) {
    //         status = "Complete";
    //     }

    //     output = string(
    //         abi.encodePacked(
    //             '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>text{ fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">',
    //             title(),
    //             ' -- ',
    //             status
    //         )
    //     );

    //     uint _offset = 80;
    //     if (step == 4) {
    //         output = string(
    //             abi.encodePacked(
    //                 output,
    //                 buildMessage(_offset, steps[3].result)
    //             )
    //         );
    //         _offset += 20 * steps[3].result.length;
                                
    //         output = string(
    //             abi.encodePacked(
    //                 output,
    //                 '</text></svg>'
    //             )
    //         );
    //     } else {
    //         if (step == 1) {
    //             // hasn't started quest, no result to show
    //             output = string(
    //                 abi.encodePacked(
    //                     output,
    //                     buildMessage(_offset, steps[1].description)
    //                 )
    //             );
    //             _offset += 20 * steps[1].description.length;
                                
    //             output = string(
    //                 abi.encodePacked(
    //                     output,
    //                     '</text><text x="10" y="',
    //                     toString(_offset + 40),
    //                     '">Requirement: ',
    //                     steps[1].requirements,
    //                     '</text></svg>'
    //                 )
    //             );
    //         } else {
    //             output = string(
    //                 abi.encodePacked(
    //                     output,
    //                     buildMessage(_offset, steps[step - 1].result)
    //                 )
    //             );
    //             _offset += 20 * steps[step - 1].result.length + 20;

    //             output = string(
    //                 abi.encodePacked(
    //                     output,
    //                     buildMessage(_offset, steps[step].description)
    //                 )
    //             );
    //             _offset += 20 * steps[step].description.length;
                                
    //             output = string(
    //                 abi.encodePacked(
    //                     output,
    //                     '</text><text x="10" y="',
    //                     toString(_offset + 40),
    //                     '">Requirement: ',
    //                     steps[step].requirements,
    //                     '</text></svg>'
    //                 )
    //             );
    //         }
    //     }

    //     string memory metadata = string(
    //         abi.encodePacked(
    //             '{"id": 0001, "name": "',
    //             title(),
    //             '", "bagId": 0001, "description": "The first steps into the Rift!", "background_color": "000000", "attributes": [{ "trait_type": "Step Count", "value":',
    //             toString(numSteps()),
    //             ' }, { "trait_type": "Completed", "value": ',
    //             step == numSteps() ? 'true' : 'false'
    //     ));


    //     return string(
    //         abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(string(
    //             abi.encodePacked(
    //                 metadata,
    //                 '" }], "image": "data:image/svg+xml;base64,',
    //                 Base64.encode(bytes(output)), '"}'
    //             )
    //     )))));
    // }

    function tokenURI(uint256 bagId) override external view returns (string memory) {
        string memory output;

        QuestStep memory _currentStep = currentStep(bagId);

        output = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>text{ fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">',
                title(),
                isCompleted(bagId) ? " -- Complete!" : ""
            )
        );

        uint _offset = 80;
        if (isCompleted(bagId)) {
            output = string(
                abi.encodePacked(
                    output,
                    buildMessage(_offset, steps[bagsProgress_[bagId].lastCompletedStep].result),
                    '</text></svg>'
                )
            );
        } else {
            if (bagsProgress_[bagId].lastCompletedStep == 0) {
                // hasn't started quest, no result to show
                output = string(
                    abi.encodePacked(
                        output,
                        buildMessage(_offset, _currentStep.description)
                    )
                );
                _offset += 20 * _currentStep.description.length;
                                
                output = string(
                    abi.encodePacked(
                        output,
                        '</text><text x="10" y="',
                        toString(_offset + 40),
                        '">Requirement: ',
                        _currentStep.requirements,
                        '</text></svg>'
                    )
                );
            } else {
                output = string(
                    abi.encodePacked(
                        output,
                        buildMessage(_offset, steps[bagsProgress_[bagId].lastCompletedStep].result)
                    )
                );
                _offset += 20 * steps[bagsProgress_[bagId].lastCompletedStep].result.length + 20;

                output = string(
                    abi.encodePacked(
                        output,
                        buildMessage(_offset, _currentStep.description)
                    )
                );
                _offset += 20 * _currentStep.description.length;
                                
                output = string(
                    abi.encodePacked(
                        output,
                        '</text><text x="10" y="',
                        toString(_offset + 40),
                        '">Requirement: ',
                        _currentStep.requirements,
                        '</text></svg>'
                    )
                );
            }
        }

        string memory metadata = string(
            abi.encodePacked(
                '{"id": ',
                toString(bagId),
                ', "name": "',
                title(),
                '", "bagId": ',
                toString(bagId),
                ', "description": "The first steps into the Rift!", "background_color": "000000", "attributes": [{ "trait_type": "Step Count", "value":',
                toString(numSteps()),
                ' }, { "trait_type": "Completed", "value": ',
                isCompleted(bagId) ? 'true' : 'false'
        ));


        return string(
            abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(string(
                abi.encodePacked(
                    metadata,
                    '" }], "image": "data:image/svg+xml;base64,',
                    Base64.encode(bytes(output)), '"}'
                )
        )))));
    }

    //owner

    function ownerSetCrystalsAddress(address crystals_) external onlyOwner {
        iCrystals = ICrystals(crystals_);
    }

    function ownerSetManaAddress(address mana_) external onlyOwner {
        iMana = ERC20(mana_);
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