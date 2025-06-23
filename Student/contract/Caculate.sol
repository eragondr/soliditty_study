// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "./StudentInfo.sol";

contract Caculte{

    StudentInfo[] private students;
    function CreateNewStudent(int256 id, uint32[3] calldata grades,address wallet, StudentType studentType) public 
    {
        StudentInfo student = new StudentInfo();
        student.SetStudentId(id);
        student.SetStudentGrade(id, grades);
        student.SetStudentWallet(id,wallet);
        student.SetStudentType(studentType);
        students.push(student);
    }

    function CaculateGrade(StudentInfo student) private view returns (uint32 ) {
        uint32 average = 0;  // initialize average to zero
        Grade memory grade = student.GetStudentGrade(student.GetStudentId());
        average += grade.mark1;
        average += grade.mark2;
        average += grade.mark3;
        average = average/3;  
        return average;
     
    }
    
    function ViewStudent( uint index)public view returns (StudentInfo ) {  // This is the
        StudentInfo student = StudentInfo(address (students[index]));
        return student;
    }
    function ViewStudents()public view returns (StudentInfo[]memory) {  // This is the
        return students;
    }
    function ViewStudentWallet(uint16 index)public view returns (address ) {  // This is the
         StudentInfo student = StudentInfo(address (students[index]));
        return student.GetStudentWallet(student.GetStudentId());
    }
    function ViewStudentWallet2(uint16 index)public view returns (address ) {  // This is the
         StudentInfo student = students[index];
        return student.GetStudentWallet(student.GetStudentId());
    }

//213,[10,9,8],0x1Ae4C2EcD3061D966dF87d800C59250196d6cabd,POOR
}
