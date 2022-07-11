// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/RosetteStone.sol";

contract RosetteStoneTest is Test {
    RosetteStone rosetteStone;

    // accounts
    address sender = address(1);
    address notAuthorized = address(2);

    bytes32 testScope =
        0x8c6753027d3e741bbfe01da77ac0b8feea667348cba07fad62f937782d475fdf;
    // upsertEntry(bytes32,bytes4,bytes)
    bytes4 testSig = bytes4(0xd3cd7efa);
    // QmWtGzMy7aNbMnLpmuNjKonoHc86mL1RyxqD2ghdQyq7Sm
    bytes testCID =
        "0x516d5774477a4d7937614e624d6e4c706d754e6a4b6f6e6f486338366d4c3152797871443267686451797137536d";

    function setUp() public {
        rosetteStone = new RosetteStone();

        // labels
        vm.label(sender, "sender");
        vm.label(notAuthorized, "notAuthorizedAddress");
    }

    function upsertEntry() public {
        vm.prank(sender);
        rosetteStone.upsertEntry(testScope, testSig, testCID);
    }

    function testUpsertEntryWithInvalidScope() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                RosetteStone.InvalidEntry.selector,
                address(0),
                testSig,
                testCID
            )
        );
        rosetteStone.upsertEntry(bytes32(0), testSig, testCID);
    }

    function testUpsertEntryWithInvalidSig() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                RosetteStone.InvalidEntry.selector,
                testScope,
                bytes4(0),
                testCID
            )
        );
        rosetteStone.upsertEntry(testScope, bytes4(0), testCID);
    }

    function testUpsertEntryWithInvalidContent() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                RosetteStone.InvalidEntry.selector,
                testScope,
                testSig,
                ""
            )
        );
        rosetteStone.upsertEntry(testScope, testSig, "");
    }

    function testUpsertEntry() public {
        upsertEntry();

        (
            bytes memory cid,
            address submitter,
            RosetteStone.EntryStatus status
        ) = rosetteStone.getEntry(testScope, testSig);

        assertEq(uint256(status), uint256(RosetteStone.EntryStatus.Added));
        assertTrue(cid.length > 0);
        assertEq(submitter, sender);
    }

    function testUpsertEntryAndUpdate() public {
        upsertEntry();
        vm.prank(sender);
        rosetteStone.upsertEntry(testScope, testSig, testCID);
    }

    function testUpsertEntryAndTryUpdateWithNotAuthorizedAddress() public {
        upsertEntry();

        vm.expectRevert("RosetteStone: not authorized address");

        vm.prank(notAuthorized);
        rosetteStone.upsertEntry(testScope, testSig, testCID);
    }

    function testUpsertEntries() public {
        bytes32 testScope2 = 0x9c6753027d3e741bbfe01da77ac0b8feea667348cba07fad62f937782d475fdf;
        bytes32 testScope3 = 0xac6753027d3e741bbfe01da77ac0b8feea667348cba07fad62f937782d475fdf;
        bytes4 testSig2 = bytes4(0xe3cd7efa);
        bytes4 testSig3 = bytes4(0xf3cd7efa);
        bytes
            memory testCID2 = "0x616d5774477a4d7937614e624d6e4c706d754e6a4b6f6e6f486338366d4c3152797871443267686451797137536d";
        bytes
            memory testCID3 = "0x716d5774477a4d7937614e624d6e4c706d754e6a4b6f6e6f486338366d4c3152797871443267686451797137536d";
        bytes32[] memory scopes = new bytes32[](3);
        scopes[0] = testScope;
        scopes[1] = testScope2;
        scopes[2] = testScope3;
        bytes4[] memory signatures = new bytes4[](3);
        signatures[0] = testSig;
        signatures[1] = testSig2;
        signatures[2] = testSig3;
        bytes[] memory cids = new bytes[](3);
        cids[0] = testCID;
        cids[1] = testCID2;
        cids[2] = testCID3;

        vm.prank(sender);
        rosetteStone.upsertEntries(scopes, signatures, cids);

        (
            bytes memory cid,
            address submitter,
            RosetteStone.EntryStatus status
        ) = rosetteStone.getEntry(testScope, testSig);

        assertEq(uint256(status), uint256(RosetteStone.EntryStatus.Added));
        assertTrue(cid.length > 0);
        assertEq(submitter, sender);

        (cid, submitter, status) = rosetteStone.getEntry(testScope2, testSig2);

        assertEq(uint256(status), uint256(RosetteStone.EntryStatus.Added));
        assertTrue(cid.length > 0);
        assertEq(submitter, sender);

        (cid, submitter, status) = rosetteStone.getEntry(testScope3, testSig3);

        assertEq(uint256(status), uint256(RosetteStone.EntryStatus.Added));
        assertTrue(cid.length > 0);
        assertEq(submitter, sender);
    }

    function testRemoveEntry() public {
        upsertEntry();

        vm.prank(sender);
        rosetteStone.removeEntry(testScope, testSig);

        (, , RosetteStone.EntryStatus status) = rosetteStone.getEntry(
            testScope,
            testSig
        );

        assertEq(uint256(status), uint256(RosetteStone.EntryStatus.Empty));
    }

    function testRemoveEntryWithNotAuthorizedAddress() public {
        vm.prank(sender);
        rosetteStone.upsertEntry(testScope, testSig, testCID);

        vm.expectRevert("RosetteStone: not authorized address");

        vm.prank(notAuthorized);
        rosetteStone.removeEntry(testScope, testSig);
    }

    // TODO testRemoveEntries
}
