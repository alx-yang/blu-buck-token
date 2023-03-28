// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {

    address private owner; // University of Michigan

    mapping(address => Student) private addressToStudent; //mapping that takes in address and gives the uniqname
    mapping(Student.uniqname => address) private uniqnameToAddress; //mapping that takes in the uniquename and gives all student info

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
