pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MuseumGATicket is ERC721URIStorage, Ownable {
    using SafeMath for uint256;

    uint256 public tokenId;
    address payable private _artist;
    uint256 private _mintFee;
    uint256 private _royaltyFee;

    constructor () public ERC721 ("MuseumGATicket", "Cr3w") Ownable(){
        tokenId = 1;
        _artist = payable(msg.sender);
        _mintFee = .001 ether;
        _royaltyFee = 1;
    }

    function GetRoyaltyFee() external view returns(uint){
        return _royaltyFee;
    }

    function GetMintFee() external view returns(uint){
        return _mintFee;
    }

    function GetCurrentTokenId() external view returns(uint){
        return tokenId;
    }

    function GetArtist() external view onlyOwner() returns(address){
        return _artist;
    }

    function SetArtistAddress(address payable _artistAddress) external onlyOwner() {
        _artist = _artistAddress;
    }

    function SetMintFee(uint256 _feeAmount) external onlyOwner() {
        _mintFee = _feeAmount;
    }

    function SetRoyaltyFee(uint _feePercentage) external onlyOwner() {
        _royaltyFee = _feePercentage;
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(),tokenId), 'ERC721: transfer caller is not owner or approved');

        if(_msgSender() != _artist){
            _payRoyaltyFee();
        }

        _transfer(from,to,tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(),tokenId), 'ERC721: transfer caller is not owner or approved');

        if(_msgSender() != _artist){
            _payRoyaltyFee();
        }

        _safeTransfer(from, to, tokenId, '');
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        require(_isApprovedOrOwner(_msgSender(),tokenId), 'ERC721: transfer caller is not owner or approved');

        if(_msgSender() != _artist){
            _payRoyaltyFee();
        }

        _safeTransfer(from, to, tokenId, _data);
    }

    function createNFT(string memory tokenURI) public payable hasMintFee() returns (uint256) {
        require(tokenId <= 777, 'All 777 tokens have been minted!');
        if(msg.sender != owner()){
            require(balanceOf(msg.sender) < 1, 'Only one Per Address');
        }
        _artist.transfer(msg.value);

        uint256 newNFTTokenId = tokenId;

        _safeMint(msg.sender,newNFTTokenId);

        _setTokenURI(newNFTTokenId, tokenURI);

        tokenId.add(1);

        return newNFTTokenId;
    }

    modifier hasMintFee() {
        if(_msgSender() != _artist){
            require(msg.value >= _mintFee, 'Mint fee was not included with call');
        }
        _;
    }

    function _payRoyaltyFee() internal {
        _artist.transfer(msg.value * (_royaltyFee/100));
    }
}