// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract NFTMarket is ERC721URIStorage {
    struct Listing {
        uint256 price;
        address seller;
    }

    using Strings for uint256;
    uint256 _tokenIds;

    mapping(uint256 => Listing) public listings;

    constructor() ERC721("sideyo", "SPY") {}

    function simplifiedFormatTokenURI(string memory imageURI)
        public
        pure
        returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        string memory json = string(
            abi.encodePacked(
                '{"name": "LCM ON-CHAINED", "description": "A simple SVG based on-chain NFT", "image":"',
                imageURI,
                '"}'
            )
        );
        string memory jsonBase64Encoded = Base64.encode(bytes(json));
        return string(abi.encodePacked(baseURL, jsonBase64Encoded));
    }

    function mint(string memory imageURI) public {
        /* Encode the SVG to a Base64 string and then generate the tokenURI */
        // string memory imageURI = svgToImageURI(svg);
        string memory tokenURI = simplifiedFormatTokenURI(imageURI);

        /* Increment the token id everytime we call the mint function */
        uint256 newItemId = _tokenIds;

        /* Mint the token id and set the token URI */
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds= _tokenIds + 1;
    }

    function transferNFT(address _to, uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "Only owner can transfer");
        require(listings[_tokenId].seller == address(0), "NFT is listed for sale");

        _transfer(msg.sender, _to, _tokenId);
    }

    function listNFT(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "Only owner can list");
        listings[_tokenId] = Listing({price: _price, seller: msg.sender});
    }


    function buyNFT(uint256 _tokenId) public payable {
        Listing storage listing = listings[_tokenId];
        require(listing.seller != address(0), "NFT is not listed"); 
        require(msg.value >= listing.price, "Insufficient funds");

        _transfer(listing.seller, msg.sender, _tokenId);

        payable(listing.seller).transfer(msg.value);

        delete listings[_tokenId];
    }
}