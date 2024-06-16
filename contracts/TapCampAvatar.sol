// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface ITapCamp {
    function mint(address to) external;
    function resetBalance(address holder) external;
    function getHighestHolder() external view returns (address payable);
}

contract TapCampAvatar is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    uint256 constant NFTPRICE = 0.0001 * 10 ** 18;
    uint256 POTSIZE = 0.002 * 10 ** 18;
    address tapcampAddress;
    string dirURI;
    mapping(address => uint256) internal tokenIdToAddress;
    mapping(uint256 => bool) internal nullifierHashes;
    mapping(address => uint256) internal addressHashes;
    mapping(address => uint256) internal addressToNFCHash;
    mapping(uint256 => address) internal NFCHashToaddress;
    mapping(address => mapping(uint256 => bool)) internal Connections;

    constructor(
        address _tapcampAddress,
        string memory _dirURI
    ) ERC721("TapCampAvatar", "TCAAVATAR") {
        tapcampAddress = _tapcampAddress;
        dirURI = _dirURI;
    }

    modifier onlyNewUser(uint256 nullifierHash) {
        require(!nullifierHashes[nullifierHash], "User already registered");
        _;
    }

    function idToFilename(uint256 tokenId) public pure returns (string memory) {
        return string.concat("metadata-", Strings.toString(tokenId), ".json");
    }

    function safeMint(
        uint256 nullifierHash,
        uint256 nfcSerialHash
    ) public payable onlyNewUser(nullifierHash) {
        require(msg.value >= NFTPRICE, "Insufficient funds");
        uint256 tokenId = _nextTokenId++;

        // mint avatar
        _safeMint(msg.sender, tokenId);

        // mint welcome points
        ITapCamp(tapcampAddress).mint(msg.sender);

        // update mappings
        tokenIdToAddress[msg.sender] = tokenId;
        _updateMaps(msg.sender, nullifierHash, nfcSerialHash);

        // _setTokenURI(tokenId, idToFilename(tokenId));
        checkRaffle();
    }

    function getTokenIdForAddress(
        address holder
    ) public view returns (uint256) {
        require(addressHashes[msg.sender] != 0, "Unregistered user");
        return tokenIdToAddress[holder];
    }

    function connekted(
        address from,
        uint256 nfcSerialHash
    ) public view returns (bool) {
        return Connections[from][nfcSerialHash];
    }

    function connekt(uint256 nfcSerialHash) public {
        require(addressHashes[msg.sender] != 0, "Unregistered user");
        require(
            !Connections[msg.sender][nfcSerialHash],
            "Users already connected"
        );
        ITapCamp(tapcampAddress).mint(msg.sender);

        Connections[msg.sender][nfcSerialHash] = true;
    }

    function updateNFC(uint256 nfcSerialHash) public {
        require(addressHashes[msg.sender] != 0, "Unregistered user");
        uint256 previousNFC = addressToNFCHash[msg.sender];
        addressToNFCHash[msg.sender] = nfcSerialHash;
        NFCHashToaddress[nfcSerialHash] = msg.sender;
        NFCHashToaddress[previousNFC] = address(0);
    }

    function checkRaffle() internal {
        if (address(this).balance >= POTSIZE) {
            address payable holder = ITapCamp(tapcampAddress)
                .getHighestHolder();
            holder.transfer(address(this).balance);
            ITapCamp(tapcampAddress).resetBalance(holder);
        }
    }

    function _updateMaps(
        address to,
        uint256 nullifierHash,
        uint256 nfcSerialHash
    ) internal {
        nullifierHashes[nullifierHash] = true;
        addressHashes[to] = nullifierHash;
        addressToNFCHash[to] = nfcSerialHash;
        NFCHashToaddress[nfcSerialHash] = to;
    }

    // The following functions are overrides required by Solidity.
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return dirURI;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
