// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import "../src/CounterV1.sol";
import "../src/CounterV2.sol";
import "../src/CounterV3.sol";
import "../src/VersionManager.sol";

contract VersionManagerTest is Test {
    CounterV1 v1;
    CounterV2 v2;
    CounterV3 v3;
    VersionManager manager;
    MyProxy proxy;
    address owner = address(0x666);
    address user = address(0x777);

    function setUp() public {
        v1 = new CounterV1(owner);
        v2 = new CounterV2(owner);
        v3 = new CounterV3(owner);
        proxy = new MyProxy(address(v1), "", owner);
        vm.prank(owner);
        manager = new VersionManager(payable(address(proxy)), address(v1));
        vm.prank(owner);
        proxy.transferOwnership(address(manager));
    }

    function testUpgrade() public {
        CounterV1 old = CounterV1(address(proxy));
        old.increment();
        old.increment();

        assertEq(old.number(), 2);

        vm.prank(owner);
        manager.upgradeTo(address(v3));

        CounterV3 neww = CounterV3(address(proxy));

        assertEq(neww.number(), 2);

        neww.increment(); // 3
        neww.squareNumber(); // 9
        neww.decrement(); // 8

        assertEq(neww.number(), 8);
    }

    function testRollback() public {
        CounterV1 inst = CounterV1(address(proxy));

        inst.increment();
        inst.increment();

        assertEq(inst.number(), 2);

        vm.prank(owner);
        manager.upgradeTo(address(v2));

        CounterV2 up = CounterV2(address(proxy));

        up.increment();

        assertEq(up.number(), 3);

        vm.prank(owner);
        manager.rollbackTo();

        CounterV1 back = CounterV1(address(proxy));

        assertEq(back.number(), 3);

        back.increment();

        assertEq(back.number(), 4);
    }

    function testSecurity() public {
        vm.prank(user);
        vm.expectRevert();
        manager.upgradeTo(address(v2));

        vm.prank(user);
        vm.expectRevert();
        manager.rollbackTo();

        vm.prank(owner);
        vm.expectRevert();
        manager.rollbackTo();
    }

    function testMultipleUpgrades() public {
        vm.prank(owner);
        manager.upgradeTo(address(v2));
        vm.prank(owner);
        manager.upgradeTo(address(v3));

        assertEq(manager.currentVersion(), address(v3));

        CounterV3 third = CounterV3(address(proxy));

        assertEq(third.number(), 0);

        for (uint256 i = 0; i < 100; i++) {
            third.increment();
        }

        assertEq(third.number(), 100);

        third.squareNumber(); // 10000

        assertEq(third.number(), 10000);

        vm.prank(owner);
        manager.rollbackTo();

        CounterV2 second = CounterV2(address(proxy));

        assertEq(second.number(), 10000);

        for (uint256 i = 0; i < 111; i++) {
            second.decrement();
        }

        assertEq(second.number(), 10000 - 111);

        second.increment();
        second.increment();
        second.increment();

        assertEq(second.number(), 10000 - 111 + 3);

        vm.prank(owner);
        manager.rollbackTo();

        CounterV1 first = CounterV1(address(proxy));

        first.increment();
        first.increment();
        first.increment();

        assertEq(first.number(), 10000 - 111 + 3 + 3);
    }
}
