// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {BasicNFT} from "../src/BasicNFT.sol";

/**
 * @title DeployBasicNFT
 * @notice Foundry deployment script for the BasicNFT contract.
 * @dev Run with `forge script script/DeployBasicNFT.s.sol --broadcast` (plus
 *      `--rpc-url` and a signing method) to actually send the deployment
 *      transaction to a network.
 */
contract DeployBasicNFT is Script {
    /**
     * @notice Deploys a new BasicNFT contract.
     * @dev `vm.startBroadcast()` / `vm.stopBroadcast()` mark the section of
     *      code that should be sent as real transactions when broadcasting
     *      (as opposed to simulated locally). Everything between them is
     *      signed and sent using the script's configured sender.
     * @return The deployed BasicNFT contract instance.
     */
    function run() external returns (BasicNFT) {
        vm.startBroadcast();

        BasicNFT nft = new BasicNFT();

        vm.stopBroadcast();

        return nft;
    }
}
