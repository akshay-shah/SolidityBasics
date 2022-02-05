//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

contract BytesAndStrings {
    bytes public b1 = 'abc';
    string public s1 = 'abc';

    function getElement(uint index) public view returns(bytes1){
        // return s1[index]; -> not possible
        return b1[index];
    }

    function addElement() public {
         // return s1.push('x'); -> not possible
        b1.push('x');
    }

    function getLength() public view returns(uint) {
         // return s1.length; -> not possible
        return b1.length;
    }
}