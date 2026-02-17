CREATE DATABASE ER;
USE ER;


-- 1. Employee Table
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    fname VARCHAR(50),
    lname VARCHAR(50),
    gender VARCHAR(10),
    contact_add VARCHAR(255),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(100)
);

-- 2. Job Department Table
CREATE TABLE JobDepartment (
    job_ID INT PRIMARY KEY,
    job_dept VARCHAR(100),
    title VARCHAR(100),
    description TEXT,
    salary_range VARCHAR(50)
);

-- 3. Salary/Bonus Table
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    job_ID INT,
    amount DECIMAL(10, 2),
    annual DECIMAL(10, 2),
    bonus DECIMAL(10, 2),
    FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
);

-- 4. Qualification Table
CREATE TABLE Qualification (
    qual_ID INT PRIMARY KEY,
    emp_ID INT,
    post VARCHAR(100),
    requirements TEXT,
    date_r DATE,
    FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
);

-- 5. Leave Table
CREATE TABLE LeaveTable (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
);

-- 6. Payroll Table
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID),
    FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID),
    FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID),
    FOREIGN KEY (leave_ID) REFERENCES LeaveTable(leave_ID)
);
