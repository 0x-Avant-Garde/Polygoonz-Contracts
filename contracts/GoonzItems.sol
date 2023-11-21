// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";


contract GoonzItems is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155SupplyUpgradeable {
    using StringsUpgradeable for uint256;

    struct ItemInfo {
        uint256 power;
        uint256 layer;
    }

    string public _baseURI;
    address public devWallet;
    address public artistWallet;
    mapping(uint256 => ItemInfo) itemInfoTracker;


     event ItemMinted(address indexed to, uint256 indexed tokenId, uint256 amount);
     event ItemsBatchMinted(address indexed to, uint256[] indexed tokenId, uint256[] indexed amounts);
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer public {
        __ERC1155_init("");
        __Ownable_init();
        __ERC1155Supply_init();
        setBaseURI("https://polygoonz.artsydefi.app/metadata/items/");
        devWallet = 0x818c98b66E47B20f8f93C1CBAE352a47ab6CA24B;
        artistWallet = 0x89e12425d3eDD174baB9A8677D3bcA8b7F34f1AB;
    }

    modifier onlyAdmin() {
        require(devWallet == msg.sender || artistWallet == msg.sender || owner() == msg.sender, "Only Team can do this");
        _;
    }
    
    function setBaseURI(string memory newuri) public onlyOwner {
        _baseURI = newuri;
    }

    function uri(uint256 _tokenID) override public view returns (string memory) {
    
    return bytes(_baseURI).length > 0
        ? string(abi.encodePacked(_baseURI, _tokenID.toString()))
        : "";
    }

    // function contractURI() public view returns (string memory) {
      
    // return bytes(_baseURI).length > 0
    //     ? string(abi.encodePacked(_baseURI, "_contract_metadata", baseExtension))
    //     : "";
    // }

    function setItemInfo(uint256[] calldata _tokenIDs, uint256[] calldata _powers, uint256[] calldata _layers) public onlyAdmin {
        require(_tokenIDs.length == _powers.length && _tokenIDs.length == _layers.length, "Arrays don't match");
        
        for(uint i = 0; i < _layers.length; i++){
             require(_layers[i] != 0 && _layers[i] < 16, "Outside of layer range");
            itemInfoTracker[_tokenIDs[i]].power = _powers[i];
            itemInfoTracker[_tokenIDs[i]].layer = _layers[i];
        }
    }

    function getItemPower(uint256 _tokenID) public view returns(uint256 power){
        return itemInfoTracker[_tokenID].power;
    }

    function getItemLayer(uint256 _tokenID) public view returns(uint256 power){
        return itemInfoTracker[_tokenID].layer;
    }

    function mint(address account, uint256 id, uint256 amount, bytes calldata data)
        public
        onlyAdmin
    {
        _mint(account, id, amount, data);
       
        emit ItemMinted(account, id, amount);
    }

    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data)
        public
        onlyAdmin
    {
        _mintBatch(to, ids, amounts, data);
       
        emit ItemsBatchMinted(to, ids, amounts);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}