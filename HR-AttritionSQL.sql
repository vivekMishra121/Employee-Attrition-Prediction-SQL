CREATE TABLE Employees (
    EmployeeID SERIAL PRIMARY KEY, JobRole VARCHAR(50), Attrition Varchar (10),
    Department VARCHAR(255), Age INT, BusinessTravel VARCHAR(255),
    DistanceFromHome INT,Education INT, EducationField VARCHAR(255),
    EnvironmentSatisfaction INT, Gender VARCHAR(50), HourlyRate INT,
    JobInvolvement INT,JobLevel INT, JobSatisfaction INT,
    MaritalStatus VARCHAR(255), MonthlyIncome INT, DailyRate INT,
    MonthlyRate INT, NumCompaniesWorked INT, Over18 VARCHAR(5),
    OverTime VARCHAR(5), PercentSalaryHike INT, PerformanceRating INT,
    RelationshipSatisfaction INT, StandardHours INT, StockOptionLevel INT,
    TotalWorkingYears INT, TrainingTimesLastYear INT, WorkLifeBalance INT,
    YearsAtCompany INT,YearsInCurrentRole INT,
    YearsSinceLastPromotion INT, YearsWithCurrManager INT
);
--FIRST VIEW OF DATA

select * from employees;

-- 1. Departments with the Highest Attrition:

SELECT Department, count(attrition) AS attrition_count
FROM Employees
where attrition = 'Yes'
GROUP BY Department
ORDER BY attrition_count desc,Department

--2. Gender Distribution across Different Departments:

SELECT Department, Gender, COUNT(*) AS Number_Of_Employees
FROM Employees
GROUP BY Department, Gender
ORDER BY Department, Gender;

--3. Job Satisfaction :

Select case when jobsatisfaction = 1 then 'Not Satisfied'
when jobsatisfaction  =2 then 'Moderately Satisfied'
when jobsatisfaction = 3 then 'Satisfied'
else 'Very Satisfied' end as satisfaction_level , count(*) as Employee_count
from employees
group by satisfaction_level
order by employee_count desc

--4. EMPLOYEE ATTRITION RATE BASED ON DIFFERENT FACTORS

--4.a Attrition based on Age-group

SELECT
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 30 THEN '26-30'
        WHEN Age BETWEEN 31 AND 35 THEN '31-35'
        WHEN Age BETWEEN 36 AND 40 THEN '36-40'
        WHEN Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN Age BETWEEN 51 AND 60 THEN '51-60'
    END AS Age_Range,
    ROUND(
        (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)* 100.0) / COUNT(*),2) AS Attrition_Rate
FROM
    employees 
GROUP BY
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 30 THEN '26-30'
        WHEN Age BETWEEN 31 AND 35 THEN '31-35'
        WHEN Age BETWEEN 36 AND 40 THEN '36-40'
        WHEN Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN Age BETWEEN 51 AND 60 THEN '51-60' END
ORDER BY
    Age_Range;
	
--4.b Attrition based on Job Role

SELECT JobRole,ROUND((SUM(CASE WHEN Attrition = 'Yes'
						  THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2) AS Attrition_Rate
FROM employees
GROUP BY JobRole
ORDER BY Attrition_Rate DESC;
	
--4.c Attrition rate based on Performance

SELECT
    performancerating as Performance_Rating,
	ROUND( (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2)
	AS Attrition_Rate
FROM employees
GROUP BY performancerating
ORDER BY Attrition_Rate DESC;
	
--4.d Attrition Rate on Basis of Stock Level

Select stockoptionlevel as Stock_level , count(attrition) as employee_count from employees 
where attrition  = 'Yes'
group by Stock_level
	
--5. Correlation between Percent Salary Hike and Performance Rating:

SELECT PerformanceRating, ROUND(AVG(PercentSalaryHike),2) AS Avg_Percent_Salary_Hike
FROM Employees
GROUP BY PerformanceRating
ORDER BY PerformanceRating;

--6. Career Progression Analysis: What is the average years at the company and
----total working years for different job roles?

SELECT
    JobRole,
    round(AVG(YearsAtCompany),2) AS Avg_Years_At_Company,
    round(AVG(TotalWorkingYears),2) AS Avg_Total_Working_Years
FROM employees
GROUP By JobRole
ORDER BY Avg_Total_Working_Years DESC;

--7. Gender Pay Gap Analysis: What is the average monthly income of male and female employees?

SELECT
    Gender,round(AVG(MonthlyIncome),0) AS Avg_Monthly_Income
FROM employees
GROUP BY Gender;

--8. Distribution of performance ratings across different job roles and departments

SELECT
    JobRole,PerformanceRating,COUNT(*) AS Count
FROM employees
GROUP BY JobRole, PerformanceRating
ORDER BY  JobRole, PerformanceRating;

--9. Find the highest earners in each job role

SELECT JobRole,EmployeeID, MonthlyIncome
FROM (
    SELECT
        EmployeeID,JobRole, MonthlyIncome,
  RANK() OVER (PARTITION BY JobRole ORDER BY MonthlyIncome DESC) AS IncomeRank
  FROM employees
) subquery
WHERE  IncomeRank =1 ;

--10. What is the Employee Retention Rate by Job Role

SELECT
    JobRole,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) AS Retained_Employees,
   round( SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS Retention_Rate
FROM
    employees
GROUP BY
    JobRole
ORDER BY Retention_Rate DESC;

--11. UPDATE Monthly income for Sales Department by 20% 

--Start a transaction
BEGIN;

UPDATE Employees
SET MonthlyIncome = MonthlyIncome * 1.20
WHERE Department = 'Sales';

-- Commit the transaction
COMMIT;

select department, round(avg(monthlyincome),0) as Avg_monthly_income from employees
where department  = 'Sales'
group by department

-- 12. Insert a New Employee Record in existing employees table

INSERT INTO Employees (EmployeeID, JobRole, Attrition, Department, Age, BusinessTravel, DistanceFromHome,
					   Education, EducationField, EnvironmentSatisfaction, Gender, HourlyRate, JobInvolvement, 
					   JobLevel, JobSatisfaction, MaritalStatus, MonthlyIncome, DailyRate, MonthlyRate, NumCompaniesWorked,
					   Over18,OverTime, PercentSalaryHike, PerformanceRating, RelationshipSatisfaction, StandardHours,
					   StockOptionLevel, TotalWorkingYears, TrainingTimesLastYear, WorkLifeBalance, YearsAtCompany)
VALUES (130, 'Data Scientist', 'No', 'Research & Development', 28, 'Travel_Rarely', 5, 4, 'Life Sciences',
		3, 'Female', 50, 3, 2, 4, 'Single', 6000, 1200, 25000, 2, 'Y', 'No', 12, 3, 2, 80, 0, 6, 3, 2, 4);
		
Select * from Employees where employeeid = 130


--13. Delete Records of Employees Who Left the Company

DELETE FROM Employees
WHERE Attrition = 'Yes';

Select * from Employees 
where Attrition = 'Yes'

--14. Create a VIEW to summarize Attrition rates by department and job role


CREATE VIEW AttritionSummary AS
SELECT 
    Department,
    JobRole,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount,
    (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS AttritionRate
FROM 

    Employees_
GROUP BY 
    Department, JobRole;


select * from attritionsummary

--15.  Suggest improvements in the database schema to reduce data redundancy and improve data integrity.

/*Here are suggestions for improving the database schema:


Normalization: Ensure the database follows normalization principles to
minimize data redundancy and dependencies.

Foreign Keys: Use foreign keys to establish relationships, ensuring
referential integrity and preventing orphaned records.

Indexes: Create indexes on frequently used columns to improve query
performance, but avoid excessive indexing.

Default Values and Constraints: Employ default values and constraints
to enforce data integrity rules, reducing the risk of invalid data.

Audit Trails: Implement audit trails to track changes, providing a
historical record and enhancing accountability.

--16. Explain how you can optimize the performance of SQL queries on this dataset.

/*Here are few points for optimizing SQL queries on this dataset: 

Indexing: Create indexes on columns frequently used in WHERE clauses or JOIN
conditions to enhance query performance. 

Limit SELECT Columns: Select only the necessary columns in your queries to
reduce data transfer and improve efficiency. 

Optimize WHERE Clauses: Ensure efficient WHERE clauses by avoiding functions
on indexed columns and optimizing conditions. 

Use JOINs Efficiently: Optimize JOIN operations by selecting the appropriate
type and ensuring efficient join conditions. 

Update Statistics Regularly: Keep table statistics up-to-date to assist the
query planner in making informed execution plans.*/

