// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract HackQuest is ERC721, ERC721URIStorage, Ownable {
    using ECDSA for bytes32;

    string[3] private ipfsUris = [
        "ipfs://QmaWKA1oQ7DMurioZ7fpyJWF8jkZN4w43bKmsYS8hgQQoT",
        "ipfs://QmTsxJitqqqfJYYvEU3q3ogKMadU8mnbtWWwtNg9BkcVXa",
        "ipfs://QmZooiszjSdiGpG2ZUKjrPykHaMjMKRFTigxY2HMVMYdYv"
    ];

    enum CourseProgress {
        INIT,
        PROGRESS_HALF,
        PROGRESS_COMPLETE
    }

    uint256 private _nextTokenId;
    address public _signer;
    mapping(bytes => bool) public _signatures;
    mapping(uint256 => CourseProgress) public _courseProgress;

    constructor(address signer)
        ERC721("HackQuest", "HQ")
        Ownable(msg.sender)
    {
        _signer = signer;
    }

    function safeMint() public {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, ipfsUris[0]);
        _courseProgress[tokenId] = CourseProgress.INIT;
    }

    // The following functions are overrides required by Solidity.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
