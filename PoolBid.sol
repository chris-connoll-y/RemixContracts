// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721Receiver.sol";


contract PoolBid{
    event Withdraw (address withdrawer);
    uint256 public totalValue;
    address [] public members;
    
    IERC721 public nft;
    uint256 public nftID;
    
    
    constructor (IERC721 _nft, uint256 _nftID, address [] memory _members) {
        nft = _nft;
        nftID = _nftID;
        members = _members;
    }
    
    function addToPool () payable public isAMember() {
        totalValue += msg.value;
    }
    
    function withDrawPrize () isAMember () public {
        nft.safeTransferFrom(address(this), msg.sender, nftID);
        emit Withdraw (msg.sender);
    }
    
    function findMember (address toBeFound) view internal returns (bool) {
        for (uint256 i = 0; i < members.length; i++){
            if (members [i] == toBeFound){
                return true;
            }
        }
        return false;
    }
    
    modifier isAMember (){
        require (findMember(msg.sender) == true, "Not a member of this pool bid.");
        _;
    }
}