// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

interface IERC721 {
    function transfer(address, uint) external;
    function transferFrom(address,address, uint) external;
}

contract AuctionListing{
    event Start();
    event End(address winner, uint amount);

    address payable public owner;
    IERC721 public nft;
    uint256 public nftID;
    bool public isActive;
    uint256 endBlock;
    uint256 timeLimit;
    uint256 private priceIncrement;
    address private currentBidder;
    uint256 public currentBid;
    
    
    
    
    constructor (address _nft, uint256 _nftID, uint256 _startingBid, uint256 _timeLimit){
        owner = payable(msg.sender);
        timeLimit = _timeLimit;
        nft = IERC721(_nft);
        nftID = _nftID;
    }
    
    function bid() public payable validAddress(){
        
    }
    
    function startAuction () public onlyOwner (){
        uint256 startBlock = block.number;
        uint256 endBlock = startBlock + timeLimit;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        
        _;
    }
    
    modifier hasNotEnded (){
        if (block.number > endBlock){
            end();
        }
        require (isActive == true, "Auction has ended.");
        _;
    }
    
    function end() public {
        require(isActive == true, "Auction has already been ended");
        isActive = false;
        if (currentBidder != address(0)) {
            nft.transfer(currentBidder, nftID);
            owner.transfer(currentBid);
        } else {
            nft.transfer(owner, nftID);
        }

        emit End(currentBidder, currentBid);
    }
    
    modifier validAddress() {
        require(msg.sender != address(0), "Not valid address");
        _;
    }
}