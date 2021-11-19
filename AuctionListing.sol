// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "/PoolBid.sol";


contract AuctionListing  {
    
    //events
    event Start();
    event DeleteListing();
    event Bid(address sender, uint256 amount);
    event TurnToShop ();
    event Purchase (address buyer, uint256 amount);
    event End(address winner, uint256 amount);
    

    address payable public owner;
    
    //auction item info
    IERC721 public nft;
    uint256 public nftID;
    
    //contract statuses
    bool public isActive;
    bool public isAShop;

    //contract time stuff
    uint256 endBlock;
    uint256 timeLimit;
    
    //contract auction info
    uint256 public currentBid;
    address private currentBidder;
    uint256 public priceIncrement;
    uint256 public shopPrice;
    
    constructor (uint256 _startingBid, uint256 _timeLimit, uint256 _shopPrice, uint256 _priceIncrement) {
        owner = payable(msg.sender);
        if (_timeLimit <= 0){
            timeLimit = 2880;
        }
        else if (_timeLimit < 4){
            timeLimit = 4;
        }
        else {
            timeLimit = _timeLimit;
        }
        
        shopPrice = _shopPrice;
        isAShop = false;
        isActive = false;
        
         if (_startingBid >= 0) {
            currentBid = _startingBid;
        } else {
            currentBid = 1;
        }

        if (priceIncrement > 0) {
            priceIncrement = _priceIncrement;
        } else {
            priceIncrement = 1;
        }
    }
    
    function startAuction (address _nft, uint256 _nftID) public validAddress() onlyOwner (){
        require (isActive == false, "Auction has already started.");
        nft = IERC721(_nft);
        nftID = _nftID;
        uint256 startBlock = block.number;
        endBlock = startBlock + timeLimit;
        isActive = true;
    }
    
    function bid() public payable auctionActive() validAddress() isNotAShop(){
        require (msg.value> currentBid, "Your bid does not exceed current bid.");
        currentBidder = msg.sender;
        currentBid = msg.value;
        
        emit Bid (msg.sender, msg.value);
    }
    
    function addPoolBid (PoolBid newPoolBid) public{
        require (newPoolBid.totalValue()>currentBid, "Pool bid total value not great enough");
        currentBidder = address (newPoolBid);
        currentBid = newPoolBid.totalValue();
    }
    
    function end() public payable onlyOwner() isNotAShop() {
        require(isActive == true, "Auction has already been ended");
        isActive = false;
        if (currentBidder != address(0)) {
            nft.safeTransferFrom(address(this), currentBidder, nftID);
            //owner.transfer(currentBid);
            emit End(currentBidder, currentBid);
        } else {
            isAShop = true;
            emit TurnToShop ();
        }
    }
    
    
    function purchase () public payable validAddress() auctionActive () {
        require (isAShop == true, "The listing needs to be a shop.");
        require (msg.value == shopPrice, "Not correct price of item.");
        currentBid = msg.value;
        nft.safeTransferFrom(address(this), msg.sender, nftID);
        isActive = false;
        emit End (msg.sender, msg.value);
    }
    function deleteListing () public validAddress() onlyOwner() {
        require (isActive == true, "This shop has closed.");
        isActive = false;
        nft.safeTransferFrom(address(this), owner, nftID);
        emit DeleteListing();
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }
    modifier auctionActive (){
        if (block.number > endBlock){
            end();
        }
        require (isActive == true, "Listing is not active.");
        _;
    }
    modifier isNotAShop() {
        require (isAShop ==false, "The auction listing has become a shop.");
        _;
    }
    modifier validAddress() {
        require(msg.sender != address(0), "Not valid address");
        _;
    }
}