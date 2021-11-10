// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;


contract AuctionListing{
    
    address public owner;
    constructor (){
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }
}