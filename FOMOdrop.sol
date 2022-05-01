// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/chiru-labs/ERC721A/blob/0f88c36f9d63c765d22d0aa7b92e3cc6a8f90900/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract FOMOdrop is ERC721A, Ownable {

  using Strings for uint256;

  uint256 public cost = 25000000000000000000;
  string public baseURI;
  string public baseExtension = ".json";
  bool public closed = false;
  address public ashContract = 0x64D91f12Ece7362F91A6f8E7940Cd55F05060b92;


  constructor() ERC721A("FOMOdrop", "FD") {
    _safeMint(address(this), 1);
  }


  // external 

  function mint(uint256 quantity) external {
    require(!closed);
    require(quantity > 0);
    require(IERC20(ashContract).balanceOf(msg.sender) >= cost * quantity);
    require(IERC20(ashContract).balanceOf(msg.sender) >= 50000000000000000000);
    IERC20(ashContract).transferFrom(msg.sender, address(this), cost * quantity);
    _safeMint(msg.sender, quantity);
  }


  // internal

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }


    // View 

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

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function Biddermints(uint256 quantity) external onlyOwner {
    require(quantity > 0);
    _safeMint(msg.sender, quantity);
  }

  function stop(bool _state) external onlyOwner {
    closed = _state;
  }
 
  function withdraw(uint256 amount) external payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
    IERC20(ashContract).transfer(msg.sender, amount);
  }
}
