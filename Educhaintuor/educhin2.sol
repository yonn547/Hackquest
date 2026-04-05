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

    function updateCourseProgress(uint256 tokenId, uint8 progress, bytes memory signature) public {
        // verify signature
        require(!_signatures[signature], "Signature Already Used");
        bytes32 _msgHash = getMessageHash(msg.sender, tokenId, progress);
        bytes32 _ethSignedMessageHash = toEthSignedMessageHash(_msgHash);
        require(verify(_ethSignedMessageHash, signature), "Invalid Signature");
        _signatures[signature] = true;

        // verify tokenId
        address from = _ownerOf(tokenId);
        require(from == msg.sender, "Invalid TokenId");

        // verify course progress
        require(_courseProgress[tokenId] == CourseProgress.INIT || _courseProgress[tokenId] == CourseProgress.PROGRESS_HALF, "Course Progress Error");

        if (progress == uint8(CourseProgress.PROGRESS_HALF)) {
            _courseProgress[tokenId] = CourseProgress.PROGRESS_HALF;
            _setTokenURI(tokenId, ipfsUris[1]);
        } else if (progress == uint8(CourseProgress.PROGRESS_COMPLETE)) {
            _courseProgress[tokenId] = CourseProgress.PROGRESS_COMPLETE;
            _setTokenURI(tokenId, ipfsUris[2]);
        }
    }

    
    function getMessageHash(address _account, uint256 _tokenId, uint8 _progress) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId, _progress));
    }
    
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function verify(bytes32 _msgHash, bytes memory _signature) public view returns (bool) {
        (address recovered,,) = ECDSA.tryRecover(_msgHash, _signature);
        return recovered == _signer;
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