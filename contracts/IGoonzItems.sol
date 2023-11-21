pragma solidity ^0.8.2;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface IGoonzItems is IERC1155Upgradeable {
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        external;
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external;
    function getItemPower(uint256 _tokenID) external returns(uint256 power);
    function getItemLayer(uint256 _tokenID) external returns(uint256 layer);
}

