// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1967Proxy} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Address} from "../lib/openzeppelin-contracts/contracts/utils/Address.sol";
import {ERC1967Utils} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract MyProxy is ERC1967Proxy, Ownable {
    constructor(address implementation, bytes memory data, address owner)
        ERC1967Proxy(implementation, data)
        Ownable(owner)
    {
        if (data.length > 0) {
            Address.functionDelegateCall(implementation, data);
        }
    }

    receive() external payable {}

    function _upgradeTo(address newImplementation) external onlyOwner {
        ERC1967Utils.upgradeToAndCall(newImplementation, "");
    }
}
