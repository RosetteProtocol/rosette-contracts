// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "src/RosetteStone.sol";

contract RosetteStoneScript is Script {
    function run() external {
        vm.startBroadcast();

        new RosetteStone();

        vm.stopBroadcast();
    }
}
