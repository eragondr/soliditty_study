// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 struct Grade
{
    uint32 mark1; // 70
    uint32 mark2; // 80
    uint32 mark3; // 90
}
enum StudentType
{
    POOR,
    RICH,
    GREAT
}


contract StudentInfo {
    
    int256 public  id;
    string public name;
    StudentType public student_type;
    // Mapping to store studentId and  wallet addresses
    mapping(int256 => address) public student_wallet;
    // Contract balance (e.g., for funding purposes)
    uint256 public balance;
    // Mapping to store grades for each student by ID
    mapping(int256 => Grade) public student_grades;
    // Event to log grade updates
    event GradeUpdated(int256 studentId, uint32 mark1, uint32 mark2, uint32 mark3);
    
    // Function to set grades for a student
    function setGrade(int256  _studentId, uint32[3] memory _grades) public {
        // Validate grades (e.g., ensure marks are within a valid range)
        require(_grades[0] <= 100 && _grades[1] <= 100 && _grades[2] <= 100, "Marks must be <= 100");
        
        // Store grades in the mapping
        student_grades[_studentId] = Grade({
            mark1: _grades[0],
            mark2: _grades[1],
            mark3: _grades[2]
        });

        // Emit event for grade update
        emit GradeUpdated(_studentId, _grades[0], _grades[1], _grades[2]);
    }

    // Function to get grades for a student
    function getGrade(int256  _studentId) public view returns (Grade memory) {
        return student_grades[_studentId];
    }

    // Function to set student wallet address
    function setStudentWallet(int256  _studentId, address _wallet) public {
        student_wallet[_studentId] = _wallet;
    }

    // Function to add funds to contract balance
    function addFunds() public payable {
        balance += msg.value;
    }
    function test( string calldata ta) public {
        name = ta;
      
    }
}



