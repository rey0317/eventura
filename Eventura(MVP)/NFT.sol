pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string private _ipfsImageHash;
    string private _title;

    constructor() ERC721("MyNFT", "NFT") {
        _ipfsImageHash = "QmNwhvN25TYVLiQGkPJe7q3U5c1Ufj6U5b5UZkgP8iJ6kR"; // Replace with your IPFS hash
        _title = "My Awesome NFT"; // Replace with your title
    }

    function mint(address to) public returns (uint256) {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _safeMint(to, newTokenId);

        return newTokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return string(abi.encodePacked("https://ipfs.io/ipfs/", _ipfsImageHash, "/", tokenId.toString(), "/", _title));
    }
}

