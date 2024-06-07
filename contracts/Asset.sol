// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC5023.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Asset is ERC721URIStorage, Ownable, IERC5023 /* EIP165 */ {
    string baseURI;

    struct SharedTokenData {
        address owner;
        address sharedOwner;
        uint256 value;
        uint256 mainId;
        uint256 sharedId;
    }
    struct MainAssetData {
        address owner;
        uint256 mainId;
        uint256 noOfShares;
        uint256 value;
        mapping(uint256 => SharedTokenData) sharedTokenDetails; // Mapping of shared owners to their shared token details
    }
    //token index of everytime minting token
    uint256 internal _currentIndex;

    //mainId=>mainAssetData
    mapping(uint256 => MainAssetData) public _mainAssetData;
    //[mainId][sharedId]=>sharedTokenData
    mapping(uint256 => mapping(uint256 => SharedTokenData))
        public _sharedTokenData;
    //tokenURIs of all data
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => bool) _tokenExists;

    constructor() ERC721("Sharable NFT", "SHNFT") Ownable(msg.sender) {
        _currentIndex = 1;
    }

    function mint(address account, uint256 tokenId) external onlyOwner {
        _mint(account, tokenId);
    }

    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal override {
        require(_exists(tokenId), "ERC3525: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function setBaseURI(string memory baseURI_) external {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _requireMinted(uint256 tokenId_) internal view virtual {
        require(_exists(tokenId_), "ERC5023: invalid token ID");
    }

    function balanceOfMainAsset(
        uint256 mainId_
    ) public view virtual returns (uint256) {
        _requireMinted(mainId_);
        return _mainAssetData[mainId_].value;
    }

    function balanceOfSharedToken(
        uint256 mainId,
        uint256 sharedId
    ) public view virtual returns (uint256) {
        _requireMinted(mainId);
        return _sharedTokenData[mainId][sharedId].value;
    }

    function ownerOfMainAsset(
        uint256 tokenId_
    ) public view virtual returns (address owner_) {
        _requireMinted(tokenId_);
        //return address
        owner_ = _mainAssetData[tokenId_].owner;
        require(owner_ != address(0), "ERC5023: invalid token ID");
    }

    function ownerOfSharedToken(
        uint256 mainId_,
        uint256 sharedId
    ) public view virtual returns (address owner_) {
        _requireMinted(mainId_);
        //return address
        owner_ = _sharedTokenData[mainId_][sharedId].sharedOwner;
        require(owner_ != address(0), "ERC5023: invalid token ID");
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "ERC5023: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function registerAsset(
        address owner_,
        string memory _tokenURI
    ) external returns (uint256 mainId) {
        require(owner_ != address(0), "ERC721: mint to the zero address");

        _mint(owner_, _currentIndex);
        _tokenExists[_currentIndex] = true;
        MainAssetData storage newAsset = _mainAssetData[_currentIndex];
        newAsset.owner = owner_;
        newAsset.mainId = _currentIndex;
        newAsset.noOfShares = 0;
        _setTokenURI(_currentIndex, _tokenURI);
        mainId = _currentIndex;
        _currentIndex++;
        return mainId;
    }

    function fractionalizeAsset(uint256 mainId, uint256 _totalSupply) external {
        MainAssetData storage asset = _mainAssetData[mainId];
        require(
            msg.sender == asset.owner,
            "Only asset owner can fractionalize"
        );
        require(asset.value == 0, "Asset already fractionalized");

        asset.value = _totalSupply;
    }

    function share(
        address to,
        uint256 tokenIdToBeShared
    ) public returns (uint256 newTokenId) {
        require(to != address(0), "ERC721: mint to the zero address");
        require(
            _exists(tokenIdToBeShared),
            "ShareableERC721: token to be shared must exist"
        );

        require(
            msg.sender == ownerOf(tokenIdToBeShared),
            "Method caller must be the owner of token"
        );

        string memory _tokenURI = tokenURI(tokenIdToBeShared);
        _mint(to, _currentIndex);
        _setTokenURI(_currentIndex, _tokenURI);
        _currentIndex++;
        emit Share(msg.sender, to, _currentIndex, tokenIdToBeShared);

        return _currentIndex;
    }

    function shareAsset(
        address to,
        uint256 tokenIdToBeShared,
        uint256 shares
    ) external returns (uint256 newTokenId) {
        MainAssetData storage asset = _mainAssetData[tokenIdToBeShared];
        require(
            msg.sender == asset.owner,
            "Only asset owner can share the asset"
        );
        require(asset.value >= shares, "Not enough shares available to share");

        asset.value -= shares;
        _sharedTokenData[tokenIdToBeShared][_currentIndex] = SharedTokenData(
            asset.owner,
            to,
            shares,
            tokenIdToBeShared,
            _currentIndex
        );
        asset.sharedTokenDetails[asset.noOfShares] = _sharedTokenData[
            tokenIdToBeShared
        ][_currentIndex];
        asset.noOfShares++;
        _tokenExists[_currentIndex] = true;
        uint256 sharedToken = share(to, tokenIdToBeShared);
        return sharedToken;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public pure override(ERC721, IERC721) {
        revert("In this reference implementation tokens are not transferrable");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public pure override(ERC721, IERC721) {
        revert("In this reference implementation tokens are not transferrable");
    }

    function _exists(uint256 tokenId_) internal view virtual returns (bool) {
        return _tokenExists[tokenId_];
    }

    function noOfShares(uint256 mainId) public view returns (uint256) {
        return _mainAssetData[mainId].noOfShares;
    }
}
