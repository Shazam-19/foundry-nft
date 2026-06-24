// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MoodNFT} from "../../src/MoodNFT.sol";
import {DeployMoodNFT} from "../../script/DeployMoodNFT.s.sol";

/**
 *  @title MoodNFTTest
 *  @author Abdelrahman Semeda
 *  @notice Test suite for the MoodNFT contract.
 *  @dev Uses Foundry's Test framework to verify NFT minting and metadata generation.
 */
contract MoodNFTTest is Test {
    /// @notice Instance of the MoodNFT contract under test.
    MoodNFT public moodNft;

    /// @notice Deployment script instance.
    /// @dev Kept around (not just used locally in setUp()) so its public
    ///      `svgToImageURI()` helper can be reused here to compute the exact
    ///      same image URIs the deployment produced.
    DeployMoodNFT deployer;

    /**
     * @notice Base64-encoded SVG data URI expected for NFTs in the HAPPY state.
     *  @dev Computed in setUp() from `./img/happy.svg` using the same
     *       `svgToImageURI()` helper `DeployMoodNFT` uses. This keeps the test
     *       in sync with whatever art is actually deployed, instead of
     *       duplicating a hardcoded base64 string that could drift out of
     *       sync if the SVG file changes. Not `constant` since `vm.readFile`
     *       can only be called at test/runtime, not at compile time.
     */
    string public happySvgImageUri;

    /// @notice Base64-encoded SVG data URI expected for NFTs in the SAD state.
    /// @dev See `happySvgImageUri` above — same approach, sourced from
    ///      `./img/sad.svg`.
    string public sadSvgImageUri;

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
     * 1. Deploy MoodNFT via DeployMoodNFT — internally this reads
     *    `./img/sad.svg` and `./img/happy.svg`, base64-encodes each, and
     *    passes both image URIs into MoodNFT's constructor.
     * 2. Recompute those same image URIs here (same files, same
     *    `svgToImageURI()` helper) so tests have a reliable expected value
     *    to assert against, derived from a single source of truth.
     * 3. Store the deployed contract instance for use in tests.
     */
    function setUp() external {
        deployer = new DeployMoodNFT();
        moodNft = deployer.run();

        /* MoodNFT stores the image URIs as private state with no getters
           (s_sadSvgImageURI / s_happySvgImageURI), so we can't read them
           back off the deployed instance. Recomputing them here via
           'svgToImageURI()' - the same pure function the deployer used — is
           safe: the constructor assigns these URIs directly with no
           transformation, so the recomputed value is guaranteed to match
           what's actually in contract storage, not just what was passed
           into the constructor.
        */
        happySvgImageUri = deployer.svgToImageURI(vm.readFile("./img/happy.svg"));
        sadSvgImageUri = deployer.svgToImageURI(vm.readFile("./img/sad.svg"));

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
    function testViewTokenURIIntegration() public {
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
    function testOwnerCanFlipMoodIntegration() public {
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

    // ERC721 authorization check:
    // - Owner: can always manage their NFT.
    // - Approved address: can manage a specific token via approve().
    // - Operator: can manage all owner's NFTs via setApprovalForAll().

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
    function testApprovedAddressCanFlipMoodIntegration() public {
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
    function testOperatorCanFlipMoodIntegration() public {
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
    function testNonOwnerCannotFlipMoodIntegration() public {
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
