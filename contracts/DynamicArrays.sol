//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

contract DynamicArrays {

    uint[] private numbers;

    function addElement(uint item) public {
        numbers.push(item);
    }

    function getElement(uint index) public view returns(uint) {
        return numbers[index];
    }

    function getLength() public view returns(uint) {
        return numbers.length;
    }

    function getNumbers() public view returns(uint[] memory){
        return numbers;
    }

    function popElement() public {
        numbers.pop();
    }   

    function createNew() public {
        uint[] memory y = new uint[](3);
        y[0] = 10;
        y[2] = 30;
        numbers = y;
    }

}