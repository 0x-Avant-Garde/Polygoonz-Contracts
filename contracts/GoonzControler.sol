// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./IGoonzItems.sol";
import "./IGoonzBases.sol";

contract GoonzControler is Initializable, OwnableUpgradeable {
   
    IGoonzItems public goonzItemsContract;
    address public goonzItemsAddress;
    IGoonzBases public goonzBasesContract;
    address public goonzBasesAddress;
    
    constructor() initializer {}

    function initialize() initializer public {

        goonzItemsAddress = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;
        goonzItemsContract = IGoonzItems(goonzItemsAddress);
       
        goonzBasesAddress = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;
        goonzBasesContract = IGoonzBases(goonzBasesAddress);
    }

    function stakeToGoon(uint256 _toTokenID, uint256 _1155ID) public {
        uint256 power = goonzItemsContract.getItemPower(_1155ID);
        uint256 layer = goonzItemsContract.getItemLayer(_1155ID);

        goonzItemsContract.safeTransferFrom(msg.sender, goonzBasesAddress, _1155ID, 1, "");

        goonzBasesContract.updatePower(_toTokenID, power, 0);
        goonzBasesContract.setItem(_toTokenID, layer, _1155ID );

    }

    function unstakeFromGoon(uint256 _fromTokenID, uint256 _1155ID) public {
        require(msg.sender == goonzBasesContract.ownerOf(_fromTokenID), "You don't own this");

        uint256 power = goonzItemsContract.getItemPower(_1155ID);
            
        goonzItemsContract.safeTransferFrom(address(this), msg.sender, _1155ID, 1, "");

        goonzBasesContract.updatePower(_fromTokenID, power, 1);
    }
}