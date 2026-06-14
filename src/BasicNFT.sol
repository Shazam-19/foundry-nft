// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNFT is ERC721 {
    uint256 private s_tokenIdCounter;
    mapping(uint256 => string) private s_tokenIdToURI;

    constructor() ERC721("Dogie", "DOG") {
        s_tokenIdCounter = 0;
    }

    function mintNft(string memory _tokenURI) public {
        s_tokenIdToURI[s_tokenIdCounter] = _tokenURI;

        _safeMint(msg.sender, s_tokenIdCounter);

        s_tokenIdCounter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenIdToURI[tokenId];
    }
}
