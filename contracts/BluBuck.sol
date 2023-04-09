// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract BluBuck is Ownable {
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Account_Created(address indexed creator);
    event High_Demand();

    string public constant name = "BluBuck";
    string public constant symbol = "UMBB";
    uint8 private constant decimals = 18;
    uint16 private constant CONVERSION_RATE = 2;

    uint16 private totalStudents = 0;

    mapping(address => uint256) private balances;
    mapping(address => uint256) private buyable_balances;
    mapping(string => address) private uniqnames;
    mapping(address => bool) private account_created;
    mapping(uint256 => address) private indexToAddress; // index 1 is the first student
    mapping(address => Student) private addressToStudent; // address to uniqname (internal student identifier)
    mapping(string => uint256) private diningPlan; // returns the number of bluBucks for a specified dining plan
    mapping(string => uint256) private bluBucksSpent; // where bluBucks are spent by students

    struct Student {
        string uniqname;
        string name;
        uint32 UMID;
        string grade;
        string diningPlan;
    }

    constructor(uint256 total) {
        _mint(total);

        diningPlan["NONE"] = 0;
        diningPlan["55 BLOCK"] = 50;
        diningPlan["80 BLOCK"] = 300;
        diningPlan["125 BLOCK"] = 250;
        diningPlan["UNLIMITED"] = 25;
    }

    //need to make sure this student does not already exist
    modifier creatable() {
        require(
            account_created[msg.sender] == false && msg.sender != owner(),
            "Account has already been created (Note: owners cannot create accounts)"
        );
        _;
    }

    // make sure account is in the system
    modifier inSystem() {
        require(
            account_created[msg.sender] == true,
            "You must call addStudent before using this function (Only students can call this function)"
        );
        _;
    }

    function addStudent(
        string memory _uniqname,
        string memory _name,
        uint32 _id,
        string memory _grade,
        string memory _diningPlan
    ) external creatable {
        addressToStudent[msg.sender].uniqname = _uniqname;
        addressToStudent[msg.sender].name = _name;
        addressToStudent[msg.sender].UMID = _id;
        addressToStudent[msg.sender].grade = _grade;
        addressToStudent[msg.sender].diningPlan = _diningPlan;

        _giveBluBuck(msg.sender);
        account_created[msg.sender] = true;

        uniqnames[_uniqname] = msg.sender;

        totalStudents++;
        indexToAddress[totalStudents] = msg.sender;

        emit Account_Created(msg.sender);
    }

    /**
     * students can buy blubucks from the school with this function in exchange for some ether
     */
    function buyBluBuck() external inSystem payable {
        uint256 bbtamount = msg.value * CONVERSION_RATE;
        if (balances[owner()] < bbtamount) {
            _mint(bbtamount);
            emit High_Demand();
        }
        require(balances[owner()] >= bbtamount, "There is a bug here");
        _transfer(msg.sender, owner(), bbtamount);
    }

    /**
     * students can buy "buyable" bluBucks from other students with wei, given that the seller has enough bluBucks
     */
    function buyBluBuckFrom(string memory uniqname) external payable inSystem {
        require(uniqnames[uniqname] != address(0), "You have not entered a valid uniqname");
        require(
            _buyableBalanceOf(uniqnames[uniqname]) >=
                msg.value * CONVERSION_RATE,
            "Seller does not have enough BluBucks."
        );
        payable(uniqnames[uniqname]).transfer(msg.value);
        buyable_balances[uniqnames[uniqname]] -= msg.value * CONVERSION_RATE;
        balances[uniqnames[uniqname]] -= msg.value * CONVERSION_RATE;
        balances[msg.sender] += msg.value * CONVERSION_RATE;
    }

    /**
     * students can put bluBucks on the market for other students to buy
     */
    function makeSellable(uint256 amount) external inSystem {
        require(_balanceOf(msg.sender) >= amount, "Not enough funds.");
        buyable_balances[msg.sender] = amount;
    }

    /**
     * students can buy food from the school with this function. the main purpose of blubucks
     * @param amount blubucks' worth of food students wants to buy
     */
    function buyFood(string memory location, uint256 amount) external inSystem {
        require(_balanceOf(msg.sender) >= amount, "Not enough funds.");
        _transfer(owner(), msg.sender, amount);
        bluBucksSpent[location] += amount;
        emit Transfer(msg.sender, owner(), amount);
    }

    /**
     * allows students to check their balance
     */
    function myBalance() external view returns (uint) {
        require(
            account_created[msg.sender] == true || msg.sender == owner(),
            "You must call addStudent before using this function"
        );
        return _balanceOf(msg.sender);
    }

    function buyableBalanceOf(string memory uniqname) external view inSystem returns (uint) {
        require(uniqnames[uniqname] != address(0), "You have not entered a valid uniqname");
        return _buyableBalanceOf(uniqnames[uniqname]);
    }

    /**
     * caller of this function sends a specified amount to intended recipient. this function will be primarily
     * called by top level function that exchanges ether for blubucks
     * @param uniqname uniqname of recipient
     * @param numTokens amount to send
     */
    function transfer(
        string memory uniqname,
        uint numTokens
    ) public inSystem returns (bool) {
        require(uniqnames[uniqname] != address(0), "You have not entered a valid uniqname");
        _transfer(uniqnames[uniqname], msg.sender, numTokens);
        return false;
    }

    function mint(uint256 amount) external onlyOwner {
        _mint(amount);
    }

    function newSemester() external onlyOwner {
        for (uint i = 0; i < totalStudents; i++) {
            _giveBluBuck(indexToAddress[i + 1]);
        }
    }

    function getBluBucksSpent(
        string memory location
    ) external view returns (uint) {
        // returns the total number of bluBucks spent at a single location
        return bluBucksSpent[location];
    }

    /*HELPER FUNCTIONS BELOW*/

    /**
     * general transfer function, to be used by other functions in the class
     * @param to recipient
     * @param from sender
     * @param numTokens amount to send
     */
    function _transfer(
        address to,
        address from,
        uint numTokens
    ) private returns (bool) {
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

    function _buyableBalanceOf(address tokenOwner) private view returns (uint) {
        return buyable_balances[tokenOwner];
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
        buyable_balances[student] = 0;
    }

    function _mint(uint256 amount) private {
        balances[owner()] += amount; // balance of owner is reserve
    }
}
