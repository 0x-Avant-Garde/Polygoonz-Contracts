pragma solidity ^0.8.2;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface IGoonzBases is IERC1155Upgradeable {
   
    function setPower(uint256 _tokenID, uint256 _power) external; 

     function updatePower(uint256 _tokenID, uint256 _power, uint256 _direction) external;

    function getPower(uint256 _tokenID) external;

    function setItem(uint256 _tokenID, uint256 _layer, uint256 _1155_tokenID)  external;

     function removeItem(uint256 _tokenID, uint256 _layer) external;

    function getItems(uint256 _tokenID, uint256 _layer) external;

    function balanceOf(address owner) external;

    function ownerOf(uint256 tokenId) external returns(address);

}