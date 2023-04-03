// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    // University of Michigan deploys contract
    address private owner;
    uint256 private reserve;
    uint16 private constant CONVERSION_RATE = 1800;

    uint256 students;

    mapping(uint256 => address) private indexToAddress;
    mapping(address => Student) private addressToStudent; // address to uniqname (internal student identifier)
    mapping(string => address) private uniqnameToAddress; // uniqname to address (external)
    mapping(string => int) private diningPlan; // returns the number of bluBucks for a specified dining plan

    event Account_Created(address indexed creator);

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
        string grade;
        string diningPlan;
    }

    constructor() ERC20("BlueBuckToken", "BBT") {
        diningPlan["NONE"] = 0;
        diningPlan["55 BLOCK"] = 50;
        diningPlan["80 BLOCK"] = 300;
        diningPlan["125 BLOCK"] = 250;
        diningPlan["UNLIMITED"] = 25;
    }
    

    function mint(address to, uint256 amount) external onlyOwner {
        //Student s = addressToStudent[to];
        _mint(to, amount);
        reserve += amount;
    }

    function buyFood(address from, uint256 amount) external {
        require(balanceOf(from) - amount >= 0);
        _transfer(from, owner, amount);
        reserve += amount;
    }

    function transfer(string memory uniq2, uint256 amount) public {
        address address1 = _msgSender();
        address address2 = uniqnameToAddress[uniq2];
        _transfer(address1, address2, amount);
    }

    function createAccount(string memory _uniqname, string memory _name, uint8 _id, string memory _grade, string memory _diningPlan) external {
        addressToStudent[msg.sender].uniqname = _uniqname;
        addressToStudent[msg.sender].name = _name;
        addressToStudent[msg.sender].UMID = _id;
        addressToStudent[msg.sender].grade = _grade;
        addressToStudent[msg.sender].diningPlan = _diningPlan;

        students++;
        indexToAddress[students] = msg.sender;

        Account_Created(msg.sender);
    }

    function buyBluBuck(string memory uniqname) external payable { // FIX THIS
        uint256 bbtamount = msg.value * CONVERSION_RATE;
        address user = uniqnameToAddress[uniqname];
        //_transfer(owner, user, bbtamount);
        reserve -= bbtamount;
    }

    function giveBluBuck() public onlyOwner {
        // MIHIR
    }
    
}
