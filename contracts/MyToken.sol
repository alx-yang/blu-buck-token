// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    // University of Michigan deploys contract
    address private owner;

    uint256 private reserve;

    mapping(address => Student) private addressToStudent; // address to uniqname (internal student identifier)
    mapping(string => address) private uniqnameToAddress; // uniqname to address (external)
    mapping(string => int) private diningPlan; // returns the number of bluBucks for a specified dining plan

    enum Grade {
        Freshman,
        Sophomore,
        Junior,
        Senior,
        Graduate
    }


    struct Student {
        string uniqname;
        string name;
        uint32 UMID;
        Grade grade;
    }

    constructor() ERC20("BlueBuckToken", "BBT") {
        diningPlan("NONE") = 0;
        diningPlan("55 BLOCK") = 50;
        diningPlan("80 BLOCK") = 300;
        diningPlan("125 BLOCK") = 250;
        diningPlan("UNLIMITED") = 25;
    }
    

    function mint(address to, uint256 amount) public onlyOwner {
        //Student s = addressToStudent[to];
        _mint(to, amount);
    }

    function buyFood(address from, uint256 amount) public {
        require(balanceOf(from) - amount >= 0);
        _transfer(from, owner, amount);
    }

    function transfer(string memory uniq1, string memory uniq2, uint256 amount) public {
        address address1 = uniqnameToAddress[uniq1];
        address address2 = uniqnameToAddress[uniq2];
        _transfer(address1, address2, amount);
    }

    function getBluBuck(string uniqname, string name) public {

    }

    function buyBluBuck() public {

    }

    function giveBluBuck() public onlyOwner {

    }
    
}
