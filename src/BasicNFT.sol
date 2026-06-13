// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNFT is ERC721 {
    uint256 private s_tokenIdCounter;

    constructor() ERC721("Dogie", "DOG") {
        s_tokenIdCounter = 0;
    }

    function mintNft() public returns (uint256) {
        uint256 newTokenId = s_tokenIdCounter;
        _safeMint(msg.sender, newTokenId);
        s_tokenIdCounter += 1;
        return newTokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return "ipfs://bafybeigs5lojzzear4gyuizxgmdabdam7jftguarspv4rcxw665pkioxdy/3054";
    }
}
