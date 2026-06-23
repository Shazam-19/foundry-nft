// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MoodNFT} from "../src/MoodNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title DeployMoodNFT
 * @notice Foundry deployment script for the MoodNFT contract.
 * @dev Inherits from forge-std's `Script`, which provides cheatcodes like
 *      `vm.startBroadcast()` / `vm.stopBroadcast()` for sending real
 *      transactions when this script is executed (e.g. via `forge script`).
 *
 * Flow:
 *  1. Foundry calls `run()` as the entry point when the script is executed.
 *  2. `run()` is expected to read in the happy/sad SVG files, convert each
 *     to a base64 image URI via `svgToImageURI()`, deploy `MoodNFT` with
 *     those two URIs passed to its constructor, and return the deployed
 *     instance.
 *  3. `svgToImageURI()` is a standalone helper; it doesn't depend on
 *     deployment state, so it can be called independently any time raw SVG
 *     markup needs to be converted into an on-chain image URI.
 */
contract DeployMoodNFT is Script {
    /**
     * @notice Entry point Foundry runs when this script is executed.
     * @dev Reads the sad and happy SVG files from disk, converts each to a
     *      base64 data URI, then deploys `MoodNFT` with those URIs passed
     *      to its constructor (sad first, happy second, matching the
     *      constructor's parameter order). Broadcasting is wrapped between
     *      `vm.startBroadcast()` / `vm.stopBroadcast()` so only the
     *      deployment transaction itself is sent on-chain.
     * @return The deployed MoodNFT contract instance.
     */
    function run() external returns (MoodNFT) {
        string memory sadSvg = vm.readFile("./img/sad.svg");
        string memory happySvg = vm.readFile("./img/happy.svg");

        string memory sadImageURI = svgToImageURI(sadSvg);
        string memory happyImageURI = svgToImageURI(happySvg);

        vm.startBroadcast();
        MoodNFT moodNFT = new MoodNFT(sadImageURI, happyImageURI);
        vm.stopBroadcast();

        return moodNFT;
    }

    /**
     * @notice Converts raw SVG markup into a base64-encoded data URI that can
     *         be embedded directly as an NFT's on-chain image.
     * @dev Encoding the SVG as base64 lets the full image live inside the
     *      token metadata itself, instead of pointing to an off-chain file —
     *      this is what makes dynamic NFTs like MoodNFT fully on-chain.
     *
     * Example:
     *  Input:  svg = '<svg height="200" width="200" ...>...</svg>'
     *  Output: "data:image/svg+xml;base64,PHN2ZyBoZWlnaHQ...=="
     *
     * @param svg The raw SVG markup as a string (e.g. loaded from a .svg file).
     * @return A ready-to-use data URI string for an NFT's "image" field.
     */
    function svgToImageURI(string memory svg) public pure returns (string memory) {
        // This prefix tells anything reading the URI (browser, wallet,
        // marketplace) that what follows is base64-encoded SVG XML.
        string memory baseURL = "data:image/svg+xml;base64,";

        // Base64.encode (OpenZeppelin) converts the raw SVG bytes into a
        // base64 string so it can be safely embedded in a URI.
        string memory svgBase64Encoded = Base64.encode(bytes(svg));

        // Concatenate the prefix with the encoded SVG, then cast the
        // resulting bytes back into a string to return.
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
