// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {BasicNFT} from "../src/BasicNFT.sol";

/**
 * @title MintBasicNFT
 * @notice Foundry script that mints one NFT on the most recently deployed
 *         BasicNFT contract.
 * @dev Useful for quickly testing a deployed contract without writing a new
 *      script every time — it auto-discovers the latest deployment address
 *      via foundry-devops instead of requiring it to be hardcoded.
 */
contract MintBasicNFT is Script {
    /// @dev Sample IPFS metadata URI used for the test mint (a "Pug" dog image/JSON).
    string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    /**
     * @notice Entry point for the script. Finds the latest BasicNFT
     *         deployment on the current chain and mints an NFT on it.
     * @dev `DevOpsTools.get_most_recent_deployment` reads Foundry's broadcast
     *      logs to find the address of the last "BasicNFT" contract deployed
     *      on `block.chainid`, so this only works after `DeployBasicNFT` has
     *      been run at least once on that chain.
     */
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("BasicNFT", block.chainid);

        mintNFTOnContract(mostRecentlyDeployed);
    }

    /**
     * @notice Mints an NFT (using the PUG URI) on a specific BasicNFT contract.
     * @dev Separated from `run()` so it can be called directly in tests or
     *      other scripts with an arbitrary address, instead of always relying
     *      on auto-discovery.
     * @param basicNFTAddress The address of the deployed BasicNFT contract.
     */
    function mintNFTOnContract(address basicNFTAddress) public {
        vm.startBroadcast();
        BasicNFT(basicNFTAddress).mintNft(PUG);
        console.log("Basic NFT minted! Token URI:", BasicNFT(basicNFTAddress).tokenURI(0));
        vm.stopBroadcast();
    }
}
