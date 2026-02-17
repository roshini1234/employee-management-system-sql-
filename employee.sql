USE EMSDB;
-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
SELECT * FROM JobDepartment;
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * FROM salarybonus;
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
	REFERENCES JobDepartment(Job_ID)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);
select * from Employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from Qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from Leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
 select * from Payroll;
 
  -- 1. EMPLOYEE INSIGHTS
  -- How many unique employees are currently in the system?
  SELECT COUNT(*) AS total_employees
  FROM Employee;
  
  -- Which departments have the highest number of employees?
  SELECT jd.jobdept AS Department,
       COUNT(e.emp_ID) AS Total_Employees
  FROM JobDepartment jd
  LEFT JOIN Employee e ON jd.Job_ID = e.Job_ID
  GROUP BY jd.jobdept
  ORDER BY Total_Employees DESC;
  
  --- What is the average salary per department?
SELECT 
    jd.jobdept AS Department,
    AVG(sb.amount) AS Avg_Salary
FROM JobDepartment jd
LEFT JOIN SalaryBonus sb 
    ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY Avg_Salary DESC;  

-- Who are the top 5 highest-paid employees?
SELECT e.firstname, e.lastname, sb.amount AS Salary
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(total_amount) AS Total_Salary_Expenditure
FROM Payroll;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT jobdept AS Department,
       COUNT(Job_ID) AS Total_Job_Roles
FROM JobDepartment
GROUP BY jobdept;

-- what is the average salary range per department?
SELECT 
    jobdept AS Department,
    AVG(
        (REPLACE(SUBSTRING_INDEX(salaryrange, ' - ', 1), '$', '') 
        + REPLACE(SUBSTRING_INDEX(salaryrange, ' - ', -1), '$', '')) / 2
    ) AS Avg_Salary_Range
FROM JobDepartment
GROUP BY jobdept
ORDER BY Avg_Salary_Range DESC;

-- Which job roles offer the highest salary?
SELECT jd.name AS Job_Role, sb.amount AS Salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
ORDER BY sb.amount DESC;

-- Which departments have the highest total salary allocation?
SELECT jobdept, SUM(amount) AS Total_Salary
FROM JobDepartment
JOIN SalaryBonus USING (Job_ID)
GROUP BY jobdept
ORDER BY Total_Salary DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS Employees_With_Qualifications
FROM Qualification;

-- Which positions require the most qualifications?
SELECT Position, COUNT(*) AS Total_Qualifications
FROM Qualification
GROUP BY Position
ORDER BY Total_Qualifications DESC;

-- Which employees have the highest number of qualifications?
SELECT 
    e.emp_ID,
    e.firstname,
    e.lastname,
    COUNT(q.QualID) AS total_qualifications
FROM Employee e
LEFT JOIN Qualification q 
    ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY total_qualifications DESC;

-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
SELECT 
    YEAR(date) AS Year,
    COUNT(*) AS Total_Leaves
FROM Leaves
GROUP BY YEAR(date)
ORDER BY Total_Leaves DESC;

-- What is the average number of leave days taken by its employees per department?
SELECT 
    jd.jobdept AS Department,
    COUNT(l.leave_ID) / COUNT(DISTINCT e.emp_ID) AS Avg_Leave_Days
FROM JobDepartment jd
JOIN Employee e ON jd.Job_ID = e.Job_ID
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY jd.jobdept
ORDER BY Avg_Leave_Days DESC;

-- Which employees have taken the most leaves?
SELECT 
    e.emp_ID,
    CONCAT(e.firstname, ' ', e.lastname) AS Employee_Name,
    COUNT(l.leave_ID) AS Total_Leaves
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID
ORDER BY Total_Leaves DESC;

-- What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS Total_Leave_Days
FROM Leaves;

-- How do leave days correlate with payroll amounts?
SELECT 
    e.emp_ID,
    CONCAT(e.firstname, ' ', e.lastname) AS Employee_Name,
    COUNT(l.leave_ID) AS Total_Leaves,
    SUM(p.total_amount) AS Total_Payroll
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, Employee_Name
ORDER BY Total_Leaves DESC;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
SELECT SUM(total_amount) AS Total_Monthly_Payroll
FROM Payroll;

-- What is the average bonus given per department?
SELECT 
    jd.jobdept AS Department,
    AVG(sb.bonus) AS Avg_Bonus
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY Avg_Bonus DESC;

-- Which department receives the highest total bonuses?
SELECT jd.jobdept AS Department,
       SUM(sb.bonus) AS Total_Bonus
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY Total_Bonus DESC
LIMIT 1;

-- What is the average value of total_amount after considering leave deductions?
SELECT AVG(total_amount) AS Avg_Total_Amount
FROM Payroll;