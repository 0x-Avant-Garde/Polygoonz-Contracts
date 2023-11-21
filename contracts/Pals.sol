// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";


contract GoonzPals is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155SupplyUpgradeable {
    using StringsUpgradeable for uint256;

    
    string public _baseURI;
    address public devWallet;
    address public artistWallet;
    mapping(uint256 => uint256) power;


     event PalMinted(address indexed to, uint256 indexed tokenId, uint256 amount);
     event PalsBatchMinted(address indexed to, uint256[] indexed tokenId, uint256[] indexed amounts);
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer public {
        __ERC1155_init("");
        __Ownable_init();
        __ERC1155Supply_init();
        setBaseURI("https://polygoonz.artsydefi.app/pals/");
           devWallet = 0x960Eb4ca782499a9B4Aee9Bad3554428660fCdaf;
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

    function setPower(uint256 _tokenID, uint256 _power) public onlyOwner {
        power[_tokenID] = _power;
    }

    function getPower(uint256 _tokenID) public view returns(uint256 powers){
        return power[_tokenID];
    }

    function mint(address account, uint256 id, uint256 amount, bytes calldata data)
        public
        onlyAdmin
    {
        _mint(account, id, amount, data);
       
        emit PalMinted(account, id, amount);
    }

    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data)
        public
        onlyAdmin
    {
        _mintBatch(to, ids, amounts, data);
       
        emit PalsBatchMinted(to, ids, amounts);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}