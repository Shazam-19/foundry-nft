// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/***
 * @title MoodNFT
 * @author Abdelrahman Semeda
 * @notice An on-chain NFT whose metadata and image are generated dynamically based on its mood.
 * @dev NFT metadata is stored entirely on-chain using Base64-encoded JSON and SVG images.
 * */
contract MoodNFT is ERC721 {
    /// @dev Tracks the next token ID to be minted.
    uint256 private s_tokenIdCounter;

    /// @dev Base64-encoded SVG image displayed when the NFT mood is SAD.
    string private s_sadSvgImageURI;

    /// @dev Base64-encoded SVG image displayed when the NFT mood is HAPPY.
    string private s_happySvgImageURI;

    /// @notice Represents the possible emotional states of an NFT.
    enum Mood {
        SAD,
        HAPPY
    }

    /// @dev Maps a token ID to its current mood.
    mapping(uint256 => Mood) private s_tokenIdToMood;

    /**
     * @notice Initializes the MoodNFT contract.
     * @dev Sets the SVG images used for each mood and initializes the token counter.
     * @param _sadSvgImageURI Base64-encoded SVG image URI for the SAD mood.
     * @param _happySvgImageURI Base64-encoded SVG image URI for the HAPPY mood.
     */
    constructor(string memory _sadSvgImageURI, string memory _happySvgImageURI) ERC721("MoodNFT", "MOOD") {
        s_tokenIdCounter = 0;
        s_sadSvgImageURI = _sadSvgImageURI;
        s_happySvgImageURI = _happySvgImageURI;
    }

    /**
     * @notice Mints a new MoodNFT to the caller.
     * @dev Workflow:
     *      1. Mint the NFT to msg.sender.
     *      2. Assign the default mood (HAPPY).
     *      3. Increment the token ID counter.
     *
     * Example:
     * - If token ID 0 is minted, its initial mood will be HAPPY.
     *
     */
    function mintNft() public {
        _safeMint(msg.sender, s_tokenIdCounter);

        s_tokenIdToMood[s_tokenIdCounter] = Mood.HAPPY;

        s_tokenIdCounter++;
    }

    /**
     * @notice Returns the base URI prefix used for NFT metadata.
     * @dev Indicates that metadata is stored as Base64-encoded JSON on-chain.
     * @return The data URI prefix for JSON metadata.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    /**
     * @notice Returns the metadata URI for a given NFT.
     * @dev Workflow:
     *      1. Verify the token exists.
     *      2. Retrieve the token's current mood.
     *      3. Select the corresponding SVG image.
     *      4. Build the NFT metadata as a JSON object.
     *      5. Base64-encode the JSON.
     *      6. Return the metadata as a data URI.
     *
     * Example output:
     * data:application/json;base64,<encoded-json>
     *
     * The decoded JSON contains:
     * - name
     * - description
     * - mood attribute
     * - image URI
     *
     * @param tokenId The ID of the NFT whose metadata is being requested.
     * @return A Base64-encoded JSON metadata URI.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        Mood mood = s_tokenIdToMood[tokenId];

        string memory imageURI = mood == Mood.HAPPY ? s_happySvgImageURI : s_sadSvgImageURI;

        string memory moodValue = mood == Mood.HAPPY ? "HAPPY" : "SAD";

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '","description":"A Mood NFT that changes based on the mood of the owner.",',
                            '"attributes":[{"trait_type":"Mood","value":"',
                            moodValue,
                            '"}],',
                            '"image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
