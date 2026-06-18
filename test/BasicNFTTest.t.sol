// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBasicNFT} from "../script/DeployBasicNFT.s.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract BasicNFTTest is Test {
    DeployBasicNFT public deploy;
    BasicNFT public basicNft;

    address public USER = makeAddr("user");

    string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() external {
        deploy = new DeployBasicNFT();
        basicNft = deploy.run();
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "Dogie";
        string memory actualName = basicNft.name();
        // Built-in assertion function in Foundry to compare expected and actual values
        // assertEq(expectedName, actualName);

        // Genral Solidity code
        assert(keccak256(abi.encodePacked(expectedName)) == keccak256(abi.encodePacked(actualName)));
    }

    /**
     * @notice Tests that a user can successfully mint an NFT and that the contract
     *         state correctly reflects the mint (token URI and balance).
     * @dev This test simulates a mint call from USER, then verifies two things:
     *      1. The minted token's URI matches the URI passed into mintNft().
     *      2. The user's NFT balance increased to 1 after minting.
     *
     *      Foundry's `vm.prank(USER)` makes the *next* call appear as if it was
     *      sent by USER, even though the test contract is the actual caller.
     *
     *      Since Solidity strings can't be compared directly with `==`,
     *      we hash both strings with keccak256 and compare the hashes instead.
     */
    function testCanMintAndHaveBalance() public {
        // Make the next call appear to come from USER instead of the test contract
        vm.prank(USER);

        // USER mints an NFT, passing in PUG as the token URI (e.g., an image/metadata link)
        basicNft.mintNft(PUG);

        // The first NFT ever minted should have token ID 0 (IDs start at 0 and increment)
        uint256 expectedTokenId = 0;

        // We expect the stored token URI to match what we passed into mintNft()
        string memory expectedTokenURI = PUG;

        // --- Check 1: Token URI correctness ---
        // Fetch the actual URI stored on-chain for token ID 0
        string memory actualTokenURI = basicNft.tokenURI(expectedTokenId);

        // Compare strings by hashing them (Solidity has no native string equality operator)
        assert(keccak256(abi.encodePacked(expectedTokenURI)) == keccak256(abi.encodePacked(actualTokenURI)));

        // --- Check 2: Balance correctness ---
        // USER should now own exactly 1 NFT after minting once
        uint256 expectedBalance = 1;

        // Fetch USER's actual NFT balance from the contract
        uint256 actualBalance = basicNft.balanceOf(USER);

        // assertEq gives clearer failure output than assert() (shows both values on failure)
        assertEq(expectedBalance, actualBalance);
    }

    /**
     * @notice Tests that token IDs increment correctly across multiple mints.
     * @dev Mints two NFTs in a row and checks that the second one gets ID 1,
     *      proving the internal s_tokenIdCounter increments after every mint.
     *      Also confirms each token's URI was stored independently.
     */
    function testTokenCounterIncrementsOnMultipleMints() public {
        vm.prank(USER);
        basicNft.mintNft(PUG);

        string memory secondURI = "ipfs://second-token-uri";
        vm.prank(USER);
        basicNft.mintNft(secondURI);

        // Second mint should land on token ID 1 (counter started at 0, incremented once)
        string memory actualSecondURI = basicNft.tokenURI(1);

        assertEq(keccak256(abi.encodePacked(secondURI)), keccak256(abi.encodePacked(actualSecondURI)));

        // USER minted twice, so balance should now be 2
        assertEq(basicNft.balanceOf(USER), 2);
    }

    /**
     * @notice Tests that ownerOf() correctly reports who owns a freshly minted token.
     * @dev This confirms _safeMint() inside mintNft() actually assigns ownership
     *      to msg.sender (USER in this case), not to some default/zero address.
     */
    function testOwnerOfMintedTokenIsCorrect() public {
        vm.prank(USER);
        basicNft.mintNft(PUG);

        address actualOwner = basicNft.ownerOf(0);
        assertEq(actualOwner, USER);
    }

    /**
     * @notice Tests that different users can each mint their own NFTs independently.
     * @dev Mints from two different addresses and checks that each owns exactly
     *      one token, and that their balances don't interfere with each other.
     */
    function testMultipleUsersCanMintIndependently() public {
        address USER2 = makeAddr("userTwo");

        vm.prank(USER);
        basicNft.mintNft(PUG);

        vm.prank(USER2);
        basicNft.mintNft("ipfs://another-uri");

        assertEq(basicNft.balanceOf(USER), 1);
        assertEq(basicNft.balanceOf(USER2), 1);

        // Confirm ownership didn't get mixed up between the two mints
        assertEq(basicNft.ownerOf(0), USER);
        assertEq(basicNft.ownerOf(1), USER2);
    }

    /**
     * @notice Tests that querying tokenURI() for a token that was never minted
     *         reverts, following ERC721 best practice.
     * @dev tokenURI() calls _requireOwned(tokenId) internally, which reverts with
     *      ERC721NonexistentToken(tokenId) if the token has no owner (i.e., was
     *      never minted or has been burned). vm.expectRevert() asserts that the
     *      very next call reverts; without it, this test would fail since a
     *      successful call wouldn't trigger a revert.
     */
    function testTokenURIRevertsForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 0));
        basicNft.tokenURI(0);
    }

    /**
     * @notice Tests that minting emits the ERC721 Transfer event with correct arguments.
     * @dev The ERC721 standard requires a Transfer event on every mint, with the
     *      `from` address set to address(0) to signal that the token was created
     *      (not transferred from an existing owner).
     *
     *      vm.expectEmit(checkTopic1, checkTopic2, checkTopic3, checkData) tells
     *      Foundry to intercept the next emitted event and verify each argument:
     *      - topic1 = `from`    (address(0) for mints)
     *      - topic2 = `to`      (USER)
     *      - topic3 = `tokenId` (0)
     *      The test fails if the event is never emitted or any argument doesn't match.
     */
    function testMintEmitsTransferEvent() public {
        vm.expectEmit(true, true, true, false);
        emit IERC721.Transfer(address(0), USER, 0);

        vm.prank(USER);
        basicNft.mintNft(PUG);
    }

    /**
     * @notice Tests that querying the balance of the zero address reverts.
     * @dev OZ ERC721 v5 explicitly prohibits address(0) as a valid owner.
     *      Calling balanceOf(address(0)) reverts with ERC721InvalidOwner(address(0)).
     *      This follows the ERC721 standard, which states the zero address is never
     *      a legitimate token holder — it represents burned or non-existent ownership.
     */
    function testBalanceOfZeroAddressReverts() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidOwner.selector, address(0)));
        basicNft.balanceOf(address(0));
    }
}

/* Comparing two strings in 'chisel'
 *
 * 1. Create the strings:
 *
 *      string memory cat = "cat";
 *      string memory dog = "dog";
 *
 * 2. Encode each string as bytes:
 *
 *      bytes memory encodedCat = abi.encodePacked(cat);
 *      bytes memory encodedDog = abi.encodePacked(dog);
 *
 * 3. Hash the encoded bytes:
 *
 *      bytes32 catHash = keccak256(encodedCat);
 *      bytes32 dogHash = keccak256(encodedDog);
 *
 * 4. Compare the hashes:
 *
 *      catHash == dogHash; // false
 *
 *      keccak256(encodedCat) == keccak256(encodedDog); // false
 *
 * Since Solidity does not support direct string comparison with `==`,
 * comparing the keccak256 hashes of the encoded strings is a common
 * way to determine whether two strings contain the same value.
 */
