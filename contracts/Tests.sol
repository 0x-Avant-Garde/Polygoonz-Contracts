// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "./IGoonzItems.sol";


contract Tests is Initializable, ERC721Upgradeable, ERC1155HolderUpgradeable,  OwnableUpgradeable {
    using StringsUpgradeable for uint256;
    
    struct Giveaway {
        uint256 amount;
        uint256 numberClaimed;
    }

    // string public baseExtension;
    string public baseURI;
    uint256 public cost;
    uint256 public maxSupply;
    uint256 public maxRegularMint;
    uint256 public maxMintAmount;
    bool public paused;

    mapping(address => Giveaway) public giveawayTracker;

    address public devWallet;
    address public artistWallet;
    address public teamWallet;
    address public marketingWallet;

    IGoonzItems public goonzItemsContract;
    address public goonzItemsAddress;

    // 721 tokenID => power
    mapping(uint256 => uint256) goonPower;
    // 721 tokenID => 1155 layer => 1155 token_id
     mapping(uint256 => mapping(uint256 => uint256)) goonItem;

    // Supply Tracker
    uint256 public totalSupply;
    uint256 public totalGiveaway;

// Events Log

    event PolygoonMinted(address indexed user, uint256 indexed tokenId);
    event GiveawayMinted(address indexed user, uint256 indexed tokenId);

/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer public {
        __ERC721_init("Polygoonz", "PGoonz");
     
        __Ownable_init();
        __ERC1155Holder_init();
        baseURI = "https://polygoonz.artsydefi.app/metadata/bases/";
        // baseExtension = ".json";
        cost = 10 ether;
        maxSupply = 8000;
        maxRegularMint = 7800;
        maxMintAmount = 10;


        paused = false;
        devWallet = 0x818c98b66E47B20f8f93C1CBAE352a47ab6CA24B;
        artistWallet = 0x89e12425d3eDD174baB9A8677D3bcA8b7F34f1AB;
        teamWallet = 0x82a40213b91Ca47Ebb733493175e9C64329b466c;
        marketingWallet = 0x884e2016FBF07aBB312AD66c4EC7E015Ea358843;

        goonzItemsAddress = 0xDd90F6527067e731E121044f638d413217EEF8fc;
        goonzItemsContract = IGoonzItems(goonzItemsAddress);

    }

    modifier onlyAdmin() {
        require(devWallet == msg.sender || artistWallet == msg.sender || owner() == msg.sender, "Only Team can do this");
        _;
    }
    
    modifier onlyDev() {
        require(devWallet == msg.sender, "Only Dev");
        _;
    }

    modifier onlyArtist() {
        require(artistWallet == msg.sender, "Only Artist");
        _;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function isAdmin() internal view returns (bool){
        if(devWallet == msg.sender || artistWallet == msg.sender || owner() == msg.sender){
            return true;
        }
        else{
            return false;
        }
    }

    function safeMint(uint256 _mintAmount) payable public {
        require(!paused, "the contract is paused");
        uint256 supply = totalSupply;
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");
        require(supply + _mintAmount <= maxRegularMint, "max NFT limit exceeded");
        if(!isAdmin() ){
            require(msg.value >= cost * _mintAmount, "insufficient funds");
        }
      
        for (uint i = 1; i <= _mintAmount; i++) {
            totalSupply ++;
            _safeMint(msg.sender, supply + i);
            
        emit PolygoonMinted(msg.sender, supply + i);
        }
    }

    function claimGiveaway() public payable {
          require(!paused, "the contract is paused");
        uint i = 1;
        uint256 supply = totalSupply;
        uint256 userClaimedAmount = giveawayTracker[msg.sender].numberClaimed;
        require(giveawayTracker[msg.sender].amount > 0, "Not a winner");
        require(userClaimedAmount + i <= giveawayTracker[msg.sender].amount, "User has already claimed");
        require(supply + i <= maxSupply, "max NFT limit exceeded");
       
        giveawayTracker[msg.sender].numberClaimed += i;
        
            totalSupply ++;
            _safeMint(msg.sender, supply + i);
       
      
        emit GiveawayMinted(msg.sender, supply + i);
        
    }

    function listGiveawayWinners(address[] memory addresses, uint256[] memory amounts) public onlyAdmin {
        uint256 amount = amounts.length;
        require(addresses.length == amounts.length, "lengths don't match");
        require(totalGiveaway + amount <= 200, "Too many listed");
        for(uint i = 0; i < addresses.length; i++){
            giveawayTracker[addresses[i]].amount += amounts[i];
            totalGiveaway++;
        }
    }

    function isGiveawayWinner(address _user) public view returns(bool winner){
        if(giveawayTracker[_user].amount > 0){
            return true;
        } else {
            return false;
        }
    }

    function stakeToGoon(uint256 _toTokenID, uint256 _1155ID) public {
        uint256 power = goonzItemsContract.getItemPower(_1155ID);
        uint256 layer = goonzItemsContract.getItemLayer(_1155ID);
        require(goonItem[_toTokenID][layer] == 0, "Item already assigned to this layer");
        require(goonzItemsContract.balanceOf(msg.sender, _1155ID) > 0, "You don't have one to stake");

        updatePower(_toTokenID, power, 0);
        setItem(_toTokenID, layer, _1155ID );

        goonzItemsContract.safeTransferFrom(msg.sender, address(this), _1155ID, 1, "");
    }

    function unstakeFromGoon(uint256 _fromTokenID, uint256 _1155ID) public {
        uint256 power = goonzItemsContract.getItemPower(_1155ID);
        uint256 layer = goonzItemsContract.getItemLayer(_1155ID);

        require(msg.sender == ownerOf(_fromTokenID), "You don't own this");
        require(goonItem[_fromTokenID][layer] == _1155ID, "You don't have anything staked in this layer");

        updatePower(_fromTokenID, power, 1);
        removeItem(_fromTokenID, layer);

        goonzItemsContract.safeTransferFrom(address(this), msg.sender, _1155ID, 1, "");
    }

    function updateItemsAddress(address _newAddress) public onlyAdmin {
        goonzItemsAddress = _newAddress;
        goonzItemsContract = IGoonzItems(goonzItemsAddress);
    }

    function setPower(uint256 _tokenID, uint256 _power) external{
         require(msg.sender == owner(), "Unauthorized");
        goonPower[_tokenID] = _power;
    }

     function updatePower(uint256 _tokenID, uint256 _power, uint256 _direction) internal {
        
        _direction == 0 ? goonPower[_tokenID] += _power : goonPower[_tokenID] -= _power;
    }

    function getPower(uint256 _tokenID) public view returns(uint256){
        return goonPower[_tokenID];
    }

    function setItem(uint256 _tokenID, uint256 _layer, uint256 _1155_tokenID) internal {
      
        require(_layer != 0 && _layer < 16, "Outside layer range");
        goonItem[_tokenID][_layer] = _1155_tokenID;
    }

     function removeItem(uint256 _tokenID, uint256 _layer) internal {
       
       goonItem[_tokenID][_layer] = 0;
    }

    function getItems(uint256 _tokenID) public view returns(uint256[] memory goonItems){
         uint256[] memory items = new uint256[](16);
         uint256 j;
        for(uint i = 1; i < 17; i++){
            items[j] = goonItem[_tokenID][j];
            j++;
        }

        return items;
    }

    function getTotalSupply() public view returns(uint256 total_supply){
        return totalSupply;
    }
    
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );
        
       string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString()))
            : "";
    }

// Only Owner/Admin Setters

    function pause(bool _state) public onlyAdmin {
        paused = _state;
    }

    function setCost(uint256 _newCost) public onlyAdmin {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyAdmin {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyAdmin {
        baseURI = _newBaseURI;
    }

    function setMaxSupply(uint256 _newMaxSupply) public onlyAdmin {
        maxSupply = _newMaxSupply;
    }

    // function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    //     baseExtension = _newBaseExtension;
    // }

    function setDevWallet(address _walletAddress) public onlyDev {
        devWallet = _walletAddress;
    }
    function setArtistWallet(address _walletAddress) public onlyArtist {
        artistWallet = _walletAddress;
    }
    function setDesignerWallet(address _walletAddress) public onlyAdmin {
        teamWallet = _walletAddress;
    }
    function setMarketingWallet(address _walletAddress) public onlyAdmin {
        marketingWallet = _walletAddress;
    }

    function checkBalance() external view onlyAdmin returns(uint256 balance) {
      return address(this).balance;
    }

    function withdraw() public payable onlyAdmin {
        require(address(this).balance > 0, "No funds to withdraw");
        uint256 devShare = ((address(this).balance) * 3)/10;
        uint256 artistShare = ((address(this).balance) * 3)/10;
        uint256 teamShare = ((address(this).balance) * 1)/10;
        uint256 marketingShare = address(this).balance - devShare - artistShare - teamShare;

        (bool sentDev, ) = payable(devWallet).call{value: devShare}("");
        require(sentDev);

        (bool sentArtist, ) = payable(artistWallet).call{value: artistShare}("");
        require(sentArtist);

        (bool sentTeam, ) = payable(teamWallet).call{value: teamShare}("");
        require(sentTeam);

        (bool sentMarketing, ) = payable(marketingWallet).call{value: marketingShare}("");
        require(sentMarketing);
    }


// The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721Upgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC1155ReceiverUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
