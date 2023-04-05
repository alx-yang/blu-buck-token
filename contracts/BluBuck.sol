// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract BluBuck is Ownable {

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Account_Created(address indexed creator);

    string public constant name = "BluBuck";
    string public constant symbol = "UMBB";
    uint8 public constant decimals = 18;
    uint16 private constant CONVERSION_RATE = 1800;

    mapping(address => uint256) balances;
    mapping(string => address) uniqnames;

    //mapping(uint256 => address) private indexToAddress;
    mapping(address => Student) private addressToStudent; // address to uniqname (internal student identifier)

    struct Student {
        string uniqname;
        string name;
        uint32 UMID;
        uint256 grade;
        string diningPlan;
    }

    mapping(string => uint256) private diningPlan; // returns the number of bluBucks for a specified dining plan

    uint256 reserve; //this shouldn't be called total supply, should be caled school's supply??

    constructor(uint256 total) {
        reserve = total;
        balances[owner()] = reserve; //address of the owner gets the totalsupply correct?

        diningPlan["NONE"] = 0;
        diningPlan["55 BLOCK"] = 50;
        diningPlan["80 BLOCK"] = 300;
        diningPlan["125 BLOCK"] = 250;
        diningPlan["UNLIMITED"] = 25;
    }

//======================================
    //final transfer function: a payable function where a user can send ethereum to a person in exchange for blubucks in return
    //how would we do this?
//======================================

    /**
     * students can buy food from the school with this function. the main purpose of blubucks
     * @param amount blubucks' worth of food students wants to buy
     */
    function buyFood(uint256 amount) external {
        require(_balanceOf(msg.sender) >= amount, "Not enough funds.");
        _transfer(owner(), msg.sender, amount);
        emit Transfer(msg.sender, owner(), amount);
    }

    function addStudent(string memory _uniqname, string memory _name, 
      uint8 _id, uint256 _grade, string memory _diningPlan) external {

        //need to make sure this student does not already exist, otherwise 
        //a person can just keep making new accounts and get free blue bucks

        addressToStudent[msg.sender].uniqname = _uniqname;
        addressToStudent[msg.sender].name = _name;
        addressToStudent[msg.sender].UMID = _id;
        addressToStudent[msg.sender].grade = _grade;
        addressToStudent[msg.sender].diningPlan = _diningPlan;

        _giveBluBuck(msg.sender);

        emit Account_Created(msg.sender);
    }

    /**
     * allows students to check their balance
     * @param uniqname student wishing to check their balance
     */
    function balanceOf(string memory uniqname) external view returns (uint) {
        return _balanceOf(uniqnames[uniqname]);
    }

    /**
     * caller of this function sends a specified amount to intended recipient. this function will be primarily
     * called by top level function that exchanges ether for blubucks
     * @param uniq uniqname of recipient
     * @param numTokens amount to send
     */
    function transfer(string memory uniq, uint numTokens) public returns (bool) {
        _transfer(uniqnames[uniq], msg.sender, numTokens);
        return false;
    }

    /**
     * students can buy blubucks from the school with this function in exchange for some ether
     * @param uniq uniqname of student buying blubucks
     */
    function buyBluBuck(string memory uniq) external payable {
        uint256 bbtamount = msg.value * CONVERSION_RATE;
        require(reserve > bbtamount); //need to change this with an if else statement, where we mint if our totalsupply is less
        address user = uniqnames[uniq];

        _transfer(user, owner(), bbtamount);
        reserve -= bbtamount;
    }


    /*HELPER FUNCTIONS BELOW*/

    /**
     * general transfer function, to be used by other functions in the class
     * @param to recipient
     * @param from sender
     * @param numTokens amount to send
     */
    function _transfer(address to, address from, uint numTokens) private returns (bool) {
        require(numTokens <= balances[from], "Not enough funds.");
        balances[from] -= numTokens;
        balances[to] += numTokens;
        emit Transfer(from, to, numTokens);
        return true;
    }

    /**
     * create a top-level function that takes in a uniqname, and calls this function with the corresponding address
     * @param tokenOwner address to get balance from
     */
    function _balanceOf(address tokenOwner) private view returns (uint) {
        return balances[tokenOwner];
    }

    /**
     * general giveblubuck function. called by createaccount, and if we choose to simulate a new semester, then this function will be called
     * in repopulating the students' accounts according to their dining plan.
     * @param student address of student
     */
    function _giveBluBuck(address student) private {
        //address => student => diningplan => amount -> put this into balance
        uint256 amount = diningPlan[addressToStudent[student].diningPlan];
        balances[student] = amount;
    }
}