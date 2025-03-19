// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {UUPSUpgradeable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract CounterV2 is UUPSUpgradeable, Ownable {
    uint256 public number;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function increment() public {
        number++;
    }

    function decrement() public {
        number--;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
