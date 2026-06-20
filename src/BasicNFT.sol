// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title BasicNFT
 * @notice A minimal ERC721 NFT contract where anyone can mint a token by
 *         supplying their own metadata URI.
 * @dev Inherits OpenZeppelin's ERC721 implementation. Token metadata (the
 *      `tokenURI`) is stored manually in a mapping rather than computed from
 *      a base URI, since each token here can point to a completely different
 *      URI (e.g. different IPFS files).
 */
contract BasicNFT is ERC721 {
    /// @dev Tracks the next token ID to be minted. Starts at 0 and increments
    ///      by 1 after every successful mint, so IDs are assigned sequentially
    ///      (0, 1, 2, ...).
    uint256 private s_tokenIdCounter;

    /// @dev Maps each token ID to its metadata URI (e.g. an IPFS link to a
    ///      JSON file describing the NFT's image and attributes).
    mapping(uint256 => string) private s_tokenIdToURI;

    /**
     * @notice Deploys the NFT collection with the name "Dogie" and symbol "DOG".
     * @dev Calls the OpenZeppelin ERC721 constructor to set the collection's
     *      name/symbol, then explicitly initializes the token counter to 0
     *      (this is already the default for uint256, but it's set here for
     *      clarity).
     */
    constructor() ERC721("Dogie", "DOG") {
        s_tokenIdCounter = 0;
    }

    /**
     * @notice Mints a new NFT to the caller with the given metadata URI.
     * @dev Anyone can call this function — there is no access control or
     *      payment required. The flow is:
     *      1. Store the provided URI against the current token ID.
     *      2. Mint the token to `msg.sender` using `_safeMint`, which also
     *         checks that the recipient can safely receive ERC721 tokens.
     *      3. Increment the counter so the next mint gets a fresh, unused ID.
     * @param _tokenURI The metadata URI to associate with the newly minted
     *                  token (e.g. "ipfs://.../metadata.json").
     *
     * Example:
     *   mintNft("ipfs://bafy.../0-PUG.json")
     *   -> mints token ID 0 to the caller, with that URI attached.
     *   A second call mints token ID 1, and so on.
     */
    function mintNft(string memory _tokenURI) public {
        s_tokenIdToURI[s_tokenIdCounter] = _tokenURI;

        _safeMint(msg.sender, s_tokenIdCounter);

        s_tokenIdCounter++;
    }

    /**
     * @notice Returns the metadata URI for a given token ID.
     * @dev Overrides OpenZeppelin's default tokenURI(). Calls _requireOwned()
     *      first to follow ERC721 best practice: querying the URI of a token
     *      that was never minted (or has been burned) reverts with
     *      ERC721NonexistentToken instead of silently returning an empty string.
     * @param tokenId The ID of the token to query.
     * @return The URI string associated with `tokenId`.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return s_tokenIdToURI[tokenId];
    }
}
