// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract SimpleStorage {
    uint16 public  number;
    uint16[] public array;

    struct Person{
        uint16 sdt;
        string name;
    }

    Person[] public dynamic_array;


function CreatePerson(uint16 std, string calldata name)public pure  returns(Person memory) {
    
    Person memory person  = Person(std,name);
    return person;
}



    function store(uint16 _number) public {
        number = _number;
    }
    function addNumber(uint16 _number) public {
        store(_number);
        array.push(number );
    }
    function ViewArray () public view returns (uint16[] memory) {
        return array;
    }
    function getNumberFromArray(uint16 index) public view returns (uint16) {
        if (index > array.length-1)
        {
         return 0;   
        }
        else 
        {
            return array[index];
        }
        
    }
}