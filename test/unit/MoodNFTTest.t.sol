// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MoodNFT} from "../../src/MoodNFT.sol";

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

    /// @notice Address used to test token approvals.
    address public APPROVED = makeAddr("approved");

    /// @notice Address used to test unauthorized access attempts.
    address public ATTACKER = makeAddr("attacker");

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

        vm.etch(USER, "");
        vm.etch(APPROVED, "");
        vm.etch(ATTACKER, "");
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

    // ERC721 authorization check:
    // - Owner: can always manage their NFT.
    // - Approved address: can manage a specific token via approve().
    // - Operator: can manage all owner's NFTs via setApprovalForAll().

    /**
     * @notice Verifies that an NFT owner can successfully flip the mood of their NFT.
     * @dev This test validates the mood transition workflow:
     *      1. Mint a new NFT as USER.
     *      2. Confirm the NFT starts with the default HAPPY mood.
     *      3. Flip the NFT mood as the owner.
     *      4. Confirm the mood changes from HAPPY to SAD.
     *
     * Expected Result:
     * - The NFT is initially assigned the HAPPY mood when minted.
     * - The owner can successfully call flipMood().
     * - The mood changes from HAPPY to SAD after the call.
     *
     * Example:
     * - Before flip: HAPPY
     * - After flip: SAD
     */
    function testOwnerCanFlipMood() public {
        /// Simulate USER as msg.sender and mint a new NFT.
        vm.prank(USER);
        moodNft.mintNft();

        /// The first NFT minted by the contract receives tokenId 0.
        uint256 tokenId = 0;

        /// Capture the NFT's mood before performing the flip operation.
        MoodNFT.Mood moodBefore = moodNft.getMood(tokenId);

        /// Simulate the NFT owner calling flipMood().
        vm.prank(USER);
        moodNft.flipMood(tokenId);

        /// Capture the NFT's mood after the flip operation.
        MoodNFT.Mood moodAfter = moodNft.getMood(tokenId);

        /// Verify that newly minted NFTs start with the HAPPY mood.
        assertEq(uint256(moodBefore), uint256(MoodNFT.Mood.HAPPY));

        /// Verify that flipMood() successfully changed the mood to SAD.
        assertEq(uint256(moodAfter), uint256(MoodNFT.Mood.SAD));
    }

    /**
     * @notice Verifies that an approved address can successfully flip an NFT's mood.
     * @dev This test validates the ERC721 approval workflow:
     *      1. Mint a new NFT as USER.
     *      2. Approve APPROVED to manage the NFT.
     *      3. Confirm the NFT starts with the HAPPY mood.
     *      4. Flip the mood using the approved address.
     *      5. Confirm the mood changes from HAPPY to SAD.
     *
     * Expected Result:
     * - An approved address can call flipMood().
     * - The NFT mood changes from HAPPY to SAD.
     */
    function testApprovedAddressCanFlipMood() public {
        /// Simulate USER minting a new NFT.
        vm.prank(USER);
        moodNft.mintNft();

        uint256 tokenId = 0;

        /// Grant approval for APPROVED to manage this NFT.
        vm.prank(USER);
        moodNft.approve(APPROVED, tokenId);

        /// Capture the NFT's mood before the update.
        MoodNFT.Mood moodBefore = moodNft.getMood(tokenId);

        /// Simulate the approved address flipping the mood.
        vm.prank(APPROVED);
        moodNft.flipMood(tokenId);

        /// Capture the NFT's mood after the update.
        MoodNFT.Mood moodAfter = moodNft.getMood(tokenId);

        /// Verify the NFT initially starts in the HAPPY state.
        assertEq(uint256(moodBefore), uint256(MoodNFT.Mood.HAPPY));

        /// Verify the approved address successfully changed the mood to SAD.
        assertEq(uint256(moodAfter), uint256(MoodNFT.Mood.SAD));
    }

    /**
     * @notice Verifies that an approved operator can successfully flip an NFT's mood.
     * @dev This test validates the operator approval workflow:
     *      1. Mint a new NFT as USER.
     *      2. Grant operator permissions using setApprovalForAll().
     *      3. Confirm the NFT starts with the HAPPY mood.
     *      4. Flip the mood using the approved operator.
     *      5. Confirm the mood changes from HAPPY to SAD.
     *
     * Expected Result:
     * - An approved operator can call flipMood().
     * - The NFT mood changes from HAPPY to SAD.
     *
     * Example:
     * - USER owns token #0.
     * - USER approves APPROVED as an operator.
     * - APPROVED successfully flips the NFT mood.
     */
    function testOperatorCanFlipMood() public {
        /// Simulate USER minting a new NFT.
        vm.prank(USER);
        moodNft.mintNft();

        /// The first NFT minted by the contract receives tokenId 0.
        uint256 tokenId = 0;

        /// Grant APPROVED operator permissions for all NFTs owned by USER.
        vm.prank(USER);
        moodNft.setApprovalForAll(APPROVED, true);

        /// Capture the NFT's mood before the update.
        MoodNFT.Mood moodBefore = moodNft.getMood(tokenId);

        /// Simulate the approved operator flipping the mood.
        vm.prank(APPROVED);
        moodNft.flipMood(tokenId);

        /// Capture the NFT's mood after the update.
        MoodNFT.Mood moodAfter = moodNft.getMood(tokenId);

        /// Verify the NFT initially starts in the HAPPY state.
        assertEq(uint256(moodBefore), uint256(MoodNFT.Mood.HAPPY));

        /// Verify the operator successfully changed the mood to SAD.
        assertEq(uint256(moodAfter), uint256(MoodNFT.Mood.SAD));
    }

    /**
     * @notice Verifies that unauthorized users cannot flip an NFT's mood.
     * @dev This test validates the access control mechanism:
     *      1. Mint a new NFT as USER.
     *      2. Record the NFT's initial mood.
     *      3. Attempt to flip the NFT mood as ATTACKER.
     *      4. Verify the transaction reverts with the expected custom error.
     *      5. Verify the NFT's mood remains unchanged.
     *
     * Expected Result:
     * - The transaction reverts.
     * - The NFT mood remains unchanged.
     * - The custom error MoodNFT__CantFlipMoodNotOwner is emitted.
     * - The NFT remains in its original HAPPY state.
     *
     * Example:
     * - USER owns token #0.
     * - ATTACKER attempts to call flipMood().
     * - The transaction reverts.
     * - The NFT mood remains HAPPY.
     */
    function testNonOwnerCannotFlipMood() public {
        /// Simulate USER minting a new NFT.
        vm.prank(USER);
        moodNft.mintNft();

        /// The first NFT minted by the contract receives tokenId 0.
        uint256 tokenId = 0;

        /// Capture the NFT's mood before the unauthorized action.
        MoodNFT.Mood moodBefore = moodNft.getMood(tokenId);

        /// Verify the NFT starts in the HAPPY state.
        assertEq(uint256(moodBefore), uint256(MoodNFT.Mood.HAPPY));

        /// Expect the transaction to revert with the custom authorization error.
        vm.expectRevert(MoodNFT.MoodNFT__CantFlipMoodNotOwner.selector);

        /// Simulate an unauthorized user attempting to flip the NFT mood.
        vm.prank(ATTACKER);
        moodNft.flipMood(tokenId);

        /// Capture the NFT's mood after the failed transaction.
        MoodNFT.Mood moodAfter = moodNft.getMood(tokenId);

        /// Verify the mood was not modified by the unauthorized caller.
        assertEq(uint256(moodAfter), uint256(MoodNFT.Mood.HAPPY));

        /// Verify the mood remained unchanged.
        assertEq(uint256(moodBefore), uint256(moodAfter));
    }
}
