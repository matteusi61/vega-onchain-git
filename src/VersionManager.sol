// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {MyProxy} from "./MyProxy.sol";

contract VersionManager is Ownable {
    address[] public versionHistory;
    address public currentVersion;
    uint256 public currentIndex;
    MyProxy proxy;

    constructor(address payable _proxy, address implementation) Ownable(msg.sender) {
        versionHistory.push(implementation);
        currentVersion = implementation;
        currentIndex = 0;
        proxy = MyProxy(_proxy);
    }

    function upgradeTo(address newImplementation) public onlyOwner {
        versionHistory.push(newImplementation);
        currentVersion = newImplementation;
        currentIndex = versionHistory.length - 1;
        proxy._upgradeTo(newImplementation);
    }

    function rollbackTo() public onlyOwner {
        require(currentIndex > 0, "No previous version");
        currentIndex = currentIndex - 1;
        currentVersion = versionHistory[currentIndex];
        proxy._upgradeTo(currentVersion);
    }
}
