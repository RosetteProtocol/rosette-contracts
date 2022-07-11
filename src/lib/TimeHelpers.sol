// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Uint256Helpers.sol";

contract TimeHelpers {
    using Uint256Helpers for uint256;

    /**
     * @dev Returns the current timestamp.
     *      Using a function rather than `block.timestamp` allows us to easily mock it in
     *      tests.
     */
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Returns the current timestamp, converted to uint64.
     *      Using a function rather than `block.timestamp` allows us to easily mock it in
     *      tests.
     */
    function getTimestamp64() internal view returns (uint64) {
        return getTimestamp().toUint64();
    }
}
