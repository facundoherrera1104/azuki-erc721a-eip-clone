// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./NFT.sol";

contract CloneFactory {
    address public implementation;

    mapping(address => address[]) public allClones;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function _clone(address _implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, _implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function clone(string memory _tokenName, string memory _tokenSymbol, uint256 _tokenPrice, string memory _tokenBaseUri) external {
        address identicalChild = _clone(implementation);
        allClones[msg.sender].push(identicalChild);

        EipTestToken(identicalChild).initialize(msg.sender, _tokenName, _tokenSymbol, _tokenPrice, _tokenBaseUri);        
    }

    function returnClones(address _owner) external view returns (address[] memory) {
        return allClones[_owner];
    }
}