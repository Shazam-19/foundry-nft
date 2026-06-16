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
}
