// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {

    address private owner; // University of Michigan

    mapping(address => string); //mapping that takes in address and gives the uniqname
    mapping(string => Student); //mapping that takes in the uniquename and gives all student info

    enum Grade {
        Freshman,
        Sophomore,
        Junior,
        Senior,
        Graduate
    }

    enum DiningPlan {
        55,
        85,
        125,
        unlimited
    }

    struct Student {
        string uniqname;
        string name;
        Grade grade;
        DiningPlan diningPlan;
        uint32 UMID;
    }


    constructor() ERC20("BlueBuckToken", "BBT") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function buyFood(address from, uint256 amount) public {
        require (balanceOf(from) - amount >= 0);
        _transfer(from, umich, amount);
    }

}
