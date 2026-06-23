// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployMoodNFT} from "../script/DeployMoodNFT.s.sol";

contract DeployMoodNFTTest is Test {
    DeployMoodNFT public deployer;

    function setUp() external {
        deployer = new DeployMoodNFT();
    }

    function testConvertSVGToImageURI() external view {
        string memory expectedURI =
            "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MDAiIGhlaWdodD0iNTAwIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+CiAgPGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iNDAiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMyIgZmlsbD0icmVkIiAvPgogIDx0ZXh0IHg9IjUwIiB5PSI1NSIgZm9udC1zaXplPSIxOCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0id2hpdGUiPlNoYXphbSE8L3RleHQ+Cjwvc3ZnPiA=";

        string memory svg = '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" viewBox="0 0 100 100">\n'
            '  <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />\n'
            '  <text x="50" y="55" font-size="18" text-anchor="middle" fill="white">Shazam!</text>\n' "</svg> ";

        string memory actualURI = deployer.svgToImageURI(svg);

        assert(keccak256(abi.encodePacked(actualURI)) == keccak256(abi.encodePacked(expectedURI)));
    }
}
