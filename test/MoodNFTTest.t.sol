// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MoodNFT} from "../src/MoodNFT.sol";

/// @title MoodNFTTest
/// @author Abdelrahman Semeda
/// @notice Test suite for the MoodNFT contract.
/// @dev Uses Foundry's Test framework to verify NFT minting and metadata generation.
contract MoodNFTTest is Test {
    /// @notice Instance of the MoodNFT contract under test.
    MoodNFT public moodNft;

    /// @notice Base64-encoded SVG image used for NFTs in the HAPPY state.
    /// @dev Stored as a data URI so it can be embedded directly into NFT metadata.
    string public constant HAPPY_SVG_IMAGE_URI =
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgZmlsbD0ieWVsbG93IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNzAiIGN5PSI4MiIgcj0iMTIiLz4KICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJtMTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+Cjwvc3ZnPg==";

    /// @notice Base64-encoded SVG image used for NFTs in the SAD state.
    /// @dev Stored as a data URI so it can be embedded directly into NFT metadata.
    string public constant SAD_SVG_IMAGE_URI =
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAyNHB4IiBoZWlnaHQ9IjEwMjRweCIgdmlld0JveD0iMCAwIDEwMjQgMTAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBmaWxsPSIjMzMzIiBkPSJNNTEyIDY0QzI2NC42IDY0IDY0IDI2NC42IDY0IDUxMnMyMDAuNiA0NDggNDQ4IDQ0OCA0NDgtMjAwLjYgNDQ4LTQ0OFM3NTkuNCA2NCA1MTIgNjR6bTAgODIwYy0yMDUuNCAwLTM3Mi0xNjYuNi0zNzItMzcyczE2Ni42LTM3MiAzNzItMzcyIDM3MiAxNjYuNiAzNzIgMzcyLTE2Ni42IDM3Mi0zNzIgMzcyeiIvPgogIDxwYXRoIGZpbGw9IiNFNkU2RTYiIGQ9Ik01MTIgMTQwYy0yMDUuNCAwLTM3MiAxNjYuNi0zNzIgMzcyczE2Ni42IDM3MiAzNzIgMzcyIDM3Mi0xNjYuNiAzNzItMzcyLTE2Ni42LTM3Mi0zNzItMzcyek0yODggNDIxYTQ4LjAxIDQ4LjAxIDAgMCAxIDk2IDAgNDguMDEgNDguMDEgMCAwIDEtOTYgMHptMzc2IDI3MmgtNDguMWMtNC4yIDAtNy44LTMuMi04LjEtNy40QzYwNCA2MzYuMSA1NjIuNSA1OTcgNTEyIDU5N3MtOTIuMSAzOS4xLTk1LjggODguNmMtLjMgNC4yLTMuOSA3LjQtOC4xIDcuNEgzNjBhOCA4IDAgMCAxLTgtOC40YzQuNC04NC4zIDc0LjUtMTUxLjYgMTYwLTE1MS42czE1NS42IDY3LjMgMTYwIDE1MS42YTggOCAwIDAgMS04IDguNHptMjQtMjI0YTQ4LjAxIDQ4LjAxIDAgMCAxIDAtOTYgNDguMDEgNDguMDEgMCAwIDEgMCA5NnoiLz4KICA8cGF0aCBmaWxsPSIjMzMzIiBkPSJNMjg4IDQyMWE0OCA0OCAwIDEgMCA5NiAwIDQ4IDQ4IDAgMSAwLTk2IDB6bTIyNCAxMTJjLTg1LjUgMC0xNTUuNiA2Ny4zLTE2MCAxNTEuNmE4IDggMCAwIDAgOCA4LjRoNDguMWM0LjIgMCA3LjgtMy4yIDguMS03LjQgMy43LTQ5LjUgNDUuMy04OC42IDk1LjgtODguNnM5MiAzOS4xIDk1LjggODguNmMuMyA0LjIgMy45IDcuNCA4LjEgNy40SDY2NGE4IDggMCAwIDAgOC04LjRDNjY3LjYgNjAwLjMgNTk3LjUgNTMzIDUxMiA1MzN6bTEyOC0xMTJhNDggNDggMCAxIDAgOTYgMCA0OCA0OCAwIDEgMC05NiAweiIvPgo8L3N2Zz4=";

    /// @notice Test account used to simulate NFT ownership.
    /// @dev makeAddr() creates a deterministic address for testing.
    address public USER = makeAddr("user");

    /**
     * @notice Deploys a fresh MoodNFT contract before each test.
     * @dev Foundry automatically executes setUp() before every test function.
     *
     * Workflow:
     * 1. Deploy the MoodNFT contract.
     * 2. Provide the SVG images for HAPPY and SAD moods.
     * 3. Store the deployed contract instance for use in tests.
     */
    function setUp() external {
        moodNft = new MoodNFT(SAD_SVG_IMAGE_URI, HAPPY_SVG_IMAGE_URI);
    }

    /**
     * @notice Verifies that tokenURI() returns metadata for a minted NFT.
     * @dev This test validates the metadata generation workflow:
     *      1. Simulate a transaction from USER.
     *      2. Mint a new NFT.
     *      3. Retrieve its metadata using tokenURI().
     *      4. Verify that metadata was successfully generated.
     *
     * Expected Result:
     * - tokenURI() returns a non-empty string.
     * - The returned string contains Base64-encoded JSON metadata.
     *
     * Example:
     * - The first NFT minted receives token ID 0.
     * - Calling tokenURI(0) should return valid metadata.
     */
    function testViewTokenURI() public {
        /// Simulate USER as msg.sender for the next transaction.
        vm.prank(USER);

        /// Mint the first NFT.
        /// Since no NFTs exist yet, the minted token receives tokenId 0.
        moodNft.mintNft();

        uint256 tokenId = 0;

        /// Retrieve the metadata URI associated with the NFT.
        string memory uri = moodNft.tokenURI(tokenId);

        /// Ensure metadata was generated successfully.
        /// An empty string would indicate a failure in metadata creation.
        assert(bytes(uri).length > 0);

        /// Print the metadata URI to the terminal for inspection.
        console.log("Token URI:", uri);
    }
}
