// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBasicNFT} from "../script/DeployBasicNFT.s.sol";
import {BasicNFT} from "../src/BasicNFT.sol";

contract BasicNFTTest is Test {
    DeployBasicNFT public deploy;
    BasicNFT public basicNft;

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
