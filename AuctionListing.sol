// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721Receiver.sol";


contract AuctionListing  {
    event Start();
    event Bid(address sender, uint amount);
    event End(address winner, uint amount);

    address payable public owner;
    IERC721 public nft;
    uint256 public nftID;
    bool public isActive;
    bool public hasStarted;
    uint256 endBlock;
    uint256 timeLimit;
    
    address private currentBidder;
    uint256 public shopPrice;
    
    
    /*
        stored as price * 1,000,000
    */
    uint256 private priceIncrement;
    uint256 public currentBid;
    
    
    
    
    constructor (uint256 _startingBid, uint256 _timeLimit, uint256 _shopPrice, uint256 _priceIncrement) {
        owner = payable(msg.sender);
        timeLimit = _timeLimit;
        shopPrice = _shopPrice;
        
         if (_startingBid >= 0) {
            currentBid = _startingBid;
        } else {
            currentBid = 1000000;
        }

        if (priceIncrement > 0) {
            priceIncrement = _priceIncrement;
        } else {
            priceIncrement = 500000;
        }
    }
    
    function bid() public payable auctionActive() validAddress(){
        require (msg.value> currentBid, "Your bid does not exceed current bid.");
        currentBidder = msg.sender;
        currentBid = msg.value;
        
        emit Bid (msg.sender, msg.value);
    }
    
    function startAuction (address _nft, uint256 _nftID) public onlyOwner (){
        require (isActive == false, "Auction has already started.");
        nft = IERC721(_nft);
        nftID = _nftID;
        uint256 startBlock = block.number;
        endBlock = startBlock + timeLimit;
        isActive = true;
        hasStarted = true;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        
        _;
    }
    
    
    modifier auctionActive (){
        if (block.number > endBlock){
            end();
        }
        require (isActive == true && hasStarted == true, "Auction has already ended or has not begun.");
        _;
    }
    
    function updateNFTAddress (address newAddress) public {
        nft = IERC721(newAddress);
    }
    
    function end() public payable {
        require(isActive == true, "Auction has already been ended");
        isActive = false;
        if (currentBidder != address(0)) {
            //nft.approve (currentBidder, nftID);
            nft.safeTransferFrom(address(this), currentBidder, nftID);
            //owner.transfer(currentBid);
        } else {
            //nft.approve (owner, nftID);
            nft.safeTransferFrom(address(this), owner, nftID);
        }
    
        emit End(currentBidder, currentBid);
    }
    
    modifier validAddress() {
        require(msg.sender != address(0), "Not valid address");
        _;
    }
}