// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "ERC721URIStorage.sol";

contract SimpleCollectible is ERC721 {
    
    uint256 public tokenCounter;
    
    constructor () public ERC721 ("Test Nft", "TNFT"){
        tokenCounter = 0;
    }
    
    function createCollectible (address owner, string memory tokenURI) external returns (uint256){
        uint256 newItemId = tokenCounter;
        _safeMint (owner, newItemId);
        _tokenURI(tokenURI);
        tokenCounter = tokenCounter++;
        return newItemId;
    }
}