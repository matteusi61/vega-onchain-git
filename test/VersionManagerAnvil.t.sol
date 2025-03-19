// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import "../src/CounterV1.sol";
import "../src/CounterV2.sol";
import "../src/CounterV3.sol";
import "../src/VersionManager.sol";

contract VersionManagerAnvilTest is Test {
    address constant V1_ADDRESS = 0x82Dc47734901ee7d4f4232f398752cB9Dd5dACcC;
    address constant V2_ADDRESS = 0x196dBCBb54b8ec4958c959D8949EBFE87aC2Aaaf;
    address constant V3_ADDRESS = 0x82C6D3ed4cD33d8EC1E51d0B5Cc1d822Eaa0c3dC;
    address payable public constant PROXY_ADDRESS = payable(0x05B4CB126885fb10464fdD12666FEb25E2563B76);
    address public constant MANAGER_ADDRESS = 0x2a264F26859166C5BF3868A54593eE716AeBC848;

    CounterV1 v1;
    CounterV2 v2;
    CounterV3 v3;
    VersionManager manager;
    MyProxy proxy;
    address owner = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
    address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        console.log("Current chainId:", block.chainid);
        if (block.chainid != 31337) {
            vm.skip(true);
            return;
        }
        v1 = CounterV1(V1_ADDRESS);
        v2 = CounterV2(V2_ADDRESS);
        v3 = CounterV3(V3_ADDRESS);
        proxy = MyProxy(PROXY_ADDRESS);
        manager = VersionManager(MANAGER_ADDRESS);
    }

    function testUpgrade() public {
        if (block.chainid != 31337) {
            vm.skip(true);
            return;
        }
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
        if (block.chainid != 31337) {
            vm.skip(true);
            return;
        }
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
        if (block.chainid != 31337) {
            vm.skip(true);
            return;
        }

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
        if (block.chainid != 31337) {
            vm.skip(true);
            return;
        }

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
