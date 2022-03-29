// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";

contract EipTestToken is ERC721ABurnable, Ownable {
    using SafeMath for uint8;
    using SafeMath for uint256; 
    using Strings for string;

    
    address internal _owner;
    
    bool internal _paused;

    uint256 internal _maxSupply = 1000;
    uint256 internal _maxMintAmount = 20;

    uint256 internal _price = .02 ether;

    string internal _baseUri = "";
    string internal _baseExtension = ".json";

    uint256 internal _currentTokenId;

    bool internal _isNotClone;

    string internal _name;
    string internal _symbol;

    modifier whenNotPaused() {
        require(!_paused, "ERROR: This contract was paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "ERROR: This contract was not paused");
        _;
    }    

    // constructor
    constructor(string memory _tokenName, string memory _tokenSymbol) ERC721A(_tokenName, _tokenSymbol) {        
        _owner = address(msg.sender);

        _name = _tokenName;
        _symbol = _tokenSymbol;

        _isNotClone = true;      


    }

    function initialize(address _caller, string memory _tokenName, string memory _tokenSymbol, uint256 _mintPrice, string memory _cloneBaseUri) external {
        require(_isNotClone == false, "ERROR!: This contract cannnot be intialized"); 

        _owner = _caller;
        
        _name = _tokenName;
        _symbol = _tokenSymbol;

        _maxSupply = 1000;
        _maxMintAmount = 20;
        _price = _mintPrice;
        _baseUri = _cloneBaseUri;
        _baseExtension = ".json";
    }    

    function mint(address[] memory _mintAddresses, uint256 _mintAmount) external payable whenNotPaused onlyOwner returns(uint256) {
        require(_mintAddresses.length > 0, "ERROR: parameters are not matched");
        require(_mintAmount > 0, "ERROR: parameters are not matched");
        require(_mintAmount <= _maxMintAmount, "ERROR: connot exceed max mint amount");
        
        uint256 totalMintAmount = _mintAddresses.length * _mintAmount;
        require(_currentTokenId + totalMintAmount <= _maxSupply, "ERROR: cannot exceed max supply"); 

        if(msg.sender != _owner) {
            require(msg.value >= _price * totalMintAmount, "ERROR: not enough ether sent");
        }

        for(uint8 i=0; i<_mintAddresses.length; i++) {
            _safeMint(_mintAddresses[i], _mintAmount);    
        }
        _currentTokenId += totalMintAmount;
        
        return _currentTokenId;
    }

    function owner() public view override returns(address) {
        return _owner;
    }

    function name() public view override returns(string memory) {
        return _name;
    }

    function symbol() public view override returns(string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERORR: URI query for nonexistent token");

        bytes memory strBaseURI = bytes(_baseUri);
        return strBaseURI.length > 0 ? string(abi.encodePacked(_baseUri, Strings.toString(tokenId), _baseExtension))  : "";
    }

    function withdraw() external whenNotPaused onlyOwner {        
        uint256 balance = address(this).balance;
        require(balance > _price, "ERROR: Balance is so less or zero");

        payable(msg.sender).transfer(balance);
    }

    function burn(uint256 tokenId) override(ERC721ABurnable) public {
        _burn(tokenId, true);
    }

    function maxSupply() public view returns(uint256) {
        return _maxSupply;
    }

    function setMaxSupply(uint256 _newMaxSupply) external onlyOwner {
        _maxSupply = _newMaxSupply;
    }

    function maxMintAmount() public view returns(uint256) {
        return _maxMintAmount;
    }

    function setMaxMintAmount(uint256 _newMaxMintAmount) external onlyOwner {
        _maxMintAmount = _newMaxMintAmount;
    }

    function paused() public view returns(bool) {
        return _paused;
    }    

    function pause() external onlyOwner {
        _paused = true;
    }

    function resume() external onlyOwner {
        _paused = false;
    }    

    function baseUri() public view returns(string memory) {
        return _baseUri;
    }

    function setBaseUri(string memory _newBaseUri) external onlyOwner {
        _baseUri = _newBaseUri;
    }

    function baseExtension() public view returns(string memory) {
        return _baseExtension;
    }

    function setBaseExtension(string memory _newBaseExtension) external onlyOwner {
        _baseExtension = _newBaseExtension;
    }    

    function price() public view returns(uint256) {
        return _price;
    }

    function setPrice(uint256 _newPrice) external onlyOwner {
        _price = _newPrice;
    }

}
