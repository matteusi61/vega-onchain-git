// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/VersionManager.sol";
import "../src/CounterV1.sol";
import "../src/CounterV2.sol";
import "../src/CounterV3.sol";
import "../src/MyProxy.sol";

contract DeployScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

        vm.startBroadcast(deployerPrivateKey);

        CounterV1 v1 = new CounterV1(deployer);
        CounterV2 v2 = new CounterV2(deployer);
        CounterV3 v3 = new CounterV3(deployer);

        MyProxy proxy = new MyProxy(address(v1), "", deployer);
        VersionManager manager = new VersionManager(payable(address(proxy)), address(v1));

        proxy.transferOwnership(address(manager));

        vm.stopBroadcast();

        console.log("CounterV1:", address(v1));
        console.log("CounterV2:", address(v2));
        console.log("CounterV3:", address(v3));
        console.log("Proxy:", address(proxy));
        console.log("VersionManager:", address(manager));
    }
}
