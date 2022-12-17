// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.6 <=0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./ERC721A.sol";

contract HELLSITA2 is Ownable, ReentrancyGuard, ERC721A {
using Strings for uint256;

  uint256 public maxMintAmount = 4;
  mapping(address => bool) public whitelist;
  uint256 Price = 0.00000001  ether;
  uint256 public maxSupply = 20;
  bool public paused = true;
  bool public revealed = false;
  uint256 public constant WHITELIST_PRICE = 0 ether;
  string private  baseTokenUri;
  string public   placeholderTokenUri;

    struct SaleConfig {
    uint256 Price;
    uint256 AmountForWhitelist;
  }

  SaleConfig public saleConfig;

  constructor() ERC721A("Luck or Death", "LoD") {
     
    whitelist[0x5826ffD4A1c087760C4Fa05c694bE2E3fEf3D011] = true;
    whitelist[0xD6b5Aa725c814A71Bb70D3AaD792F790D301fB3f] = true;
    whitelist[0x99b9b3BfBCDe0ea30a0D9B20A6D7a38b8F50f275] = true;
  }

     function _baseURI() internal view virtual override returns (string memory) {return baseTokenUri;}

  modifier callerIsUser() {require(tx.origin == msg.sender, "The caller is another contract");
    _;}

   function addToWhitelist(address[] calldata toAddAddresses) 
    external onlyOwner
    {
        for (uint i = 0; i < toAddAddresses.length; i++) {whitelist[toAddAddresses[i]] = true;}
    }

  function getMaxSupply() view public returns(uint256){return maxSupply;}

  function whitelistMint(uint256 quantity)  public payable callerIsUser
    {
    require(whitelist[msg.sender], "NOT_IN_WHITELIST");
    require(!paused, "contract paused");    
    require(totalSupply() + quantity <= maxSupply, "reached max supply"); 
    require(numberMinted(msg.sender) + quantity <= saleConfig.AmountForWhitelist, "can not mint this many");
      _safeMint(msg.sender, quantity);
      refundIfOver(WHITELIST_PRICE);
  }
    
    function mint(uint256 quantity) public payable callerIsUser {
      require(!paused, "contract paused");    
      require(totalSupply() + quantity <= maxSupply, "reached max supply");   
      require(quantity <= maxMintAmount, "can not mint this many");
      uint256 totalCost = saleConfig.Price * quantity;
     _safeMint(msg.sender, quantity);
      refundIfOver(totalCost);
  }

  function refundIfOver(uint256 price) private {
    require(msg.value >= price, "Need to send more ETH.");
    if (msg.value > price) {
      payable(msg.sender).transfer(msg.value - price);
    }
  }
    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {tokenIds[i] = tokenOfOwnerByIndex(_owner, i);}
    return tokenIds;
  }

     function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        uint256 trueId = tokenId + 1;
        if(!revealed){return placeholderTokenUri;}
        return bytes(baseTokenUri).length > 0 ? string(abi.encodePacked(baseTokenUri, trueId.toString(), ".json")) : "";
    }

   function setTokenUri(string memory _baseTokenUri) external onlyOwner{
        baseTokenUri = _baseTokenUri;}

  function reveal() public onlyOwner {
      revealed = true;}

  function setPlaceholderTokenUri(string memory _notRevealedURI) public onlyOwner {
    placeholderTokenUri = _notRevealedURI;}

   function isPublicSaleOn() public view returns (bool) {
    return saleConfig.Price != 0;
  }
  
  uint256 public constant PRICE = 0.00000001 ether;

  function InitInfoOfSale(uint256 price, uint256 amountForWhitelist) external onlyOwner {
    saleConfig = SaleConfig(price, amountForWhitelist);}

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;}

  function setPrice(uint256 price) external onlyOwner {
    saleConfig.Price = price;}

    function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);}

  function pause(bool _state) public onlyOwner {
    paused = _state;}
  
  function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);}

  function getOwnershipData(uint256 tokenId) external view returns (TokenOwnership memory) {
    return ownershipOf(tokenId);}  
}