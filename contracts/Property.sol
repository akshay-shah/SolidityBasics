// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

contract Property {

    uint public price;
    string public location;
    //immutable can only be initialised inline or in constructor
    address immutable public owner;
    //constant are initialised inline when deployinng contract
    uint constant area = 100;

    //contructor is called only once when new instance of contract is deployed
    constructor(uint _price, string memory _location){
        price = _price;
        location = _location;
        owner = msg.sender;
    }


    //memory keyword is used for non reference types
    function setLocation(string memory _location) public {
        location = _location;
    }

    //memory keyword is not used for reference types
    function setValue(uint _price) public {
        price = _price;
    }

    //pure/view is used when contract state is not changed
    function getArea() public pure returns(uint) {
        return area;
    }

}