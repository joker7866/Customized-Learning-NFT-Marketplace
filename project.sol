// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CustomizedLearningNFT {
    address public owner;

    struct NFT {
        uint256 id;
        string name;
        string metadataURI;
        uint256 price;
        address creator;
        bool isListed;
    }

    uint256 public nextNFTId;
    mapping(uint256 => NFT) public nfts;
    mapping(address => uint256[]) public ownerNFTs;

    event NFTCreated(uint256 id, string name, string metadataURI, uint256 price, address creator);
    event NFTPurchased(uint256 id, address buyer);
    event NFTListed(uint256 id, uint256 price);
    event NFTRemovedFromListing(uint256 id);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyNFTOwner(uint256 _id) {
        require(msg.sender == nfts[_id].creator, "Only NFT creator can perform this action");
        _;
    }

    function createNFT(string memory _name, string memory _metadataURI, uint256 _price) public {
        require(bytes(_name).length > 0, "NFT name cannot be empty");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");
        require(_price > 0, "Price must be greater than zero");

        nfts[nextNFTId] = NFT(nextNFTId, _name, _metadataURI, _price, msg.sender, false);
        ownerNFTs[msg.sender].push(nextNFTId);

        emit NFTCreated(nextNFTId, _name, _metadataURI, _price, msg.sender);
        nextNFTId++;
    }

    function listNFT(uint256 _id, uint256 _price) public onlyNFTOwner(_id) {
        require(_price > 0, "Price must be greater than zero");
        nfts[_id].price = _price;
        nfts[_id].isListed = true;

        emit NFTListed(_id, _price);
    }

    function removeNFTFromListing(uint256 _id) public onlyNFTOwner(_id) {
        nfts[_id].isListed = false;

        emit NFTRemovedFromListing(_id);
    }

    function purchaseNFT(uint256 _id) public payable {
        NFT storage nft = nfts[_id];
        require(nft.isListed, "NFT is not listed for sale");
        require(msg.value == nft.price, "Incorrect price sent");

        address previousOwner = nft.creator;
        nft.isListed = false;
        nft.creator = msg.sender;

        payable(previousOwner).transfer(msg.value);

        emit NFTPurchased(_id, msg.sender);
    }

    function getNFTsByOwner(address _owner) public view returns (uint256[] memory) {
        return ownerNFTs[_owner];
    }

    function getNFT(uint256 _id) public view returns (NFT memory) {
        return nfts[_id];
    }
}