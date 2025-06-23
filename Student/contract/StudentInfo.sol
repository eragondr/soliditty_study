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
    
    int256 private  id;
    StudentType private student_type;
    // Mapping to store studentId and  wallet addresses
    mapping(int256 => address)  private student_wallet;
    // Contract balance (e.g., for funding purposes)
    uint256 private balance;
    // Mapping to store grades for each student by ID
    mapping(int256 => Grade) private student_grades;
    // Event to log grade updates
    event GradeUpdated(int256 studentId, uint32 mark1, uint32 mark2, uint32 mark3);
    
    // Function to Set grades for a student
    function SetStudentGrade(int256  _studentId, uint32[3] calldata _grades) public {
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


    // Function to Get grades for a student
    function GetStudentGrade(int256  _studentId) public view returns (Grade memory) {
        return student_grades[_studentId];
    }

    // Function to Set student wallet address
    function SetStudentWallet(int256  _studentId, address _wallet) public {
        student_wallet[_studentId] = _wallet;
    }
    function GetStudentWallet(int256 _studentId) public view returns (address)  {
        return student_wallet[_studentId];
    }
    
    function GetStudentId() public view returns (int256) {
        return id;
        
    }
    function SetStudentId(int256  _id) public returns (int256) {
        id = _id;
        return id;
        
    }
    function SetStudentType(StudentType  _type) public  returns (StudentType) {
        
        student_type = _type ;
        return student_type   ;
    }
    

    // Function to add funds to contract balance
    function AddFunds() public payable {
        balance += msg.value;
    }

    
}



