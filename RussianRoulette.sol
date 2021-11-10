// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;


contract RussianRoulette {
    address creator;
    address [] players;
    address [] losers;

    uint256 odds;
    address playersTurn;
    
    constructor (uint256 initialOdds)  payable{
        creator = msg.sender;
        odds = initialOdds;
    }
    
    function addThisAddress () public{
        addPlayer (msg.sender);
    }
    
    function setOdds (uint256 oneInThisMany) public{
        require(
            msg.sender == creator,
            "Only creator can change odds."
        );
        odds = oneInThisMany;
    }
    
    function play () public returns (bool) {
        require(
            isAPlayer(msg.sender) == true,
            "You are not a player."
        );
        uint256 randomNumber = random() % odds;
        if (randomNumber == 0){
            lose (msg.sender);
            return false;
        }
        return true;
    }
    
    function addPlayer (address player) public {
        require(
            isAPlayer(player) != true, 
            "Player is already a player."
        );
        require(
            isALoser(player) != true, 
            "Player has already lost."
        );
        players.push(player);

    }
    
    function lose (address player) private {
        require(
            isAPlayer(player) == true,
            "Not a player."
        );
        turnToLoser(player);
            
    }
    
    
    function turnToLoser (address player) private{
        for (uint256 i = 0; i < players.length; i++){
            if (players [i] == player){
                delete players[i];
            }
        }
        losers.push(player);
    }
    
    
    function isAPlayer (address possiblePlayer) public view returns (bool) {
        for (uint i = 0; i < players.length; i++){
            if (players [i]==possiblePlayer){
                return true;
            }
        }
        return false;
    }
    
    function random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }
    
    function isALoser (address possibleLoser) public view returns (bool)  {
        for (uint i = 0; i < losers.length; i++){
            if (losers [i]==possibleLoser){
                return true;
            }
        }
        return false;
    }
    
}