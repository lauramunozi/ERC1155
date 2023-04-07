// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract Token is ERC1155 {

    struct TokenMetadata {
        string name;
        string symbol;
        uint256 maxSupply;
    }
   
    mapping(uint256 => TokenMetadata) public mapeo;
    string name;
    string symbol;
    uint tier;
    uint256 ethPerToken;
    address ownAddress;

    constructor(string memory _name, string memory _symbol) ERC1155("https://ipfs.io/ipfs/QmaLdy9TL1H4ee531xQ46FECYQ3qw2g7VHuNUhQgnMToWD?filename=aux.json") {
        name = _name;
        symbol = _symbol;
        tier = 0;
    }

    function TokenAddress(address _ownAddress) public {
        ownAddress = _ownAddress;
    }

    function _createToken(uint256 id, uint256 supply, TokenMetadata memory _metaData) private {
        _mint(msg.sender,id,supply,"");
        mapeo[id] = _metaData;
    }
    function mintT1(uint256 supply) public {
        TokenMetadata memory _metaData = TokenMetadata(name,symbol,supply);
        _createToken(1,supply,_metaData);
        tier = 1;
    }
    function mintT2(uint256 supply) public {
        TokenMetadata memory _metaData = TokenMetadata(name,symbol,supply);
        _createToken(2,supply,_metaData);
        tier = 2;
    }
    function finProyect() public {
        tier = 3;
        uint256 supplyTier1 = mapeo[1].maxSupply;
        uint256 supplyTier2 = mapeo[2].maxSupply;
        uint256 totalSupply = supplyTier1 + supplyTier2;
        ethPerToken = address(this).balance / totalSupply;
    }


    function buyTokens() public payable {
        uint256 ethValue = msg.value;
        uint256 priceETH = 2000;
        uint256 usdtValue = (priceETH/1e18) * ethValue;
        require(tier != 0);
        uint256 precioToken = 0;
        if(tier == 1){ precioToken = 1; }
        else if(tier == 2){ precioToken = 2; }
        else{ precioToken = 1; }
        uint256 numberTokens = usdtValue/ precioToken;
        numberTokens= numberTokens * 1e18;
        _safeTransferFrom(ownAddress,msg.sender,tier,numberTokens,"");
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) public returns (bytes4) {
        // Check that the token being transferred is the one we want to refund for
        uint256 refundAmount = value * ethPerToken;
        if (id == 1 || id == 2) {
            // Transfer Ether back to the user who sent the token
            payable(from).transfer(refundAmount);
        }
        return this.onERC1155Received.selector;
    }

}
