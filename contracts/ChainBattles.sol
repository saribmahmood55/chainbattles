//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    struct CharacterAttributes {
        uint256 levels;
        uint256 hp;
        uint256 strength;
        uint256 speed;
    }

    mapping(uint256 => CharacterAttributes) public tokenIdToAttributes;

    constructor() ERC721("Chain Battles", "CB") {

    }

    function generateCharacter(uint256 tokenId) public returns(string memory){

        CharacterAttributes memory _attributes = getAttributes(tokenId);
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",_attributes.levels.toString(),'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "HP: ",_attributes.hp.toString(),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",_attributes.strength.toString(),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",_attributes.speed.toString(),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }

    function getAttributes(uint256 tokenId) public view returns(CharacterAttributes memory) {
        return tokenIdToAttributes[tokenId];
    }

    function getTokenURI(uint256 tokenId) public returns(string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToAttributes[newItemId] = CharacterAttributes(0,0,0,0);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use existing token ID");
        require(ownerOf(tokenId) == msg.sender, "Please train your own warrior");
        CharacterAttributes memory _attributes = tokenIdToAttributes[tokenId];
        _attributes.levels = _attributes.levels + generateRandom(1);
        _attributes.hp = _attributes.hp + generateRandom(2);
        _attributes.strength = _attributes.strength + generateRandom(3);
        _attributes.speed = _attributes.speed + generateRandom(4);
        tokenIdToAttributes[tokenId] = _attributes;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function generateRandom(uint256 _pos) private returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _pos))) % 10;
    }
}
