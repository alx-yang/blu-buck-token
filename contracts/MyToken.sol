// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {

    // University of Michigan deploys contract
    address private owner; 

    mapping(address => Student) private addressToStudent; // address to uniqname (internal)
    mapping(string => address) private uniqnameToAddress; // uniqname to address (external)

    enum Grade {
        Freshman,
        Sophomore,
        Junior,
        Senior,
        Graduate
    }

    enum DiningPlan {
        None,
        fiftyfive,
        eightyfive,
        onetwentyfive,
        unlimited
    }

    struct Student {
        string uniqname;
        string name;
        uint32 UMID;
        Grade grade;
        DiningPlan diningPlan;
    }

    constructor() ERC20("BlueBuckToken", "BBT") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function buyFood(address from, uint256 amount) public {
        require (balanceOf(from) - amount >= 0);
        _transfer(from, owner, amount);
    }

}