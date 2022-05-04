// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/chiru-labs/ERC721A/blob/0f88c36f9d63c765d22d0aa7b92e3cc6a8f90900/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract FOMOdrop is ERC721A, Ownable {

  using Strings for uint256;

  uint256 public cost = 12340000000000000000;
  uint256 public topbid;
  uint256 public bidendblock;
  string public baseURI;
  string public baseExtension = ".json";
  bool public closed = false;
  address public ashContract = 0x64D91f12Ece7362F91A6f8E7940Cd55F05060b92;
  address payable public topbidder;
  mapping (address => bool) public minters;


  constructor() ERC721A("FOMOdrop", "FD") {
    _safeMint(address(this), 1);
    topbidder = payable(msg.sender);
    topbid = 0;
  }


  // external 

  function mint() external {
    require(!closed);
    require(!checkMinted(msg.sender));
    minters[msg.sender]=true;
    require(IERC20(ashContract).balanceOf(msg.sender) >= 25000000000000000000);
    IERC20(ashContract).transferFrom(msg.sender, address(this), cost);
    _mint(msg.sender, 1);
  }

  function bid() payable external {
      uint256 curblock = block.number;

      require (curblock <= bidendblock);
      require (msg.value > topbid);
      topbidder.transfer(topbid);


      //assign values to new top bider
      topbidder = payable(msg.sender);
      topbid = msg.value;

      //bids made in last 100 blocks extend the auction 50 blocks. (Approx +10 minutes)
      if (curblock + 100 >= bidendblock) {
          bidendblock = bidendblock + 50;
        }
  }


  // internal

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }


    // View 

    function checkMinted(address _wallet) public view returns (bool) {
        return minters[_wallet];
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
        {
            uint256 ownerTokenCount = balanceOf(_owner);
            uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
            uint256 currentTokenId = 1;
            uint256 ownedTokenIndex = 0;

    while (ownedTokenIndex < ownerTokenCount) {
        address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {
            ownedTokenIds[ownedTokenIndex] = currentTokenId;

            ownedTokenIndex++;
            }

        currentTokenId++;
    }

        return ownedTokenIds;
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
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }


  //only owner

  function beginauction() external onlyOwner {
      bidendblock = block.number + 6750;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function biddermints(uint256 quantity) external onlyOwner {
    require(quantity > 0);
    _mint(msg.sender, quantity);
  }

  function stop(bool _state) external onlyOwner {
    closed = _state;
  }
 
  function withdraw(uint256 ashamount) external onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
    if(ashamount>0){
    IERC20(ashContract).transfer(msg.sender, ashamount);
    }
  }
}
