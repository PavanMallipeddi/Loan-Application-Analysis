
use Fintech


select * from Customer_Table
select * from Loan_Table

 
-----------"Altering Age from DOB"------------

ALTER TABLE Customer_Table
ADD Age AS (
    DATEDIFF(YEAR, DOB, GETDATE()) 
      - CASE 
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, DOB, GETDATE()), DOB) > GETDATE() 
            THEN 1 
            ELSE 0 
        END
);


-----------Age, Income, and Credit Score Profile-----------
SELECT 
    c.Customer_ID,
    c.Name,
    c.Age,
    c.Occupation_type,
    c.Monthly_income,
    c.Credit_score,
    c.City,
    c.State
FROM Customer_Table c;


SELECT Application_ID, Loan_Amount, EMI_Amount, Tenure_Months,
       (EMI_Amount * Tenure_Months) AS Total_Payment
FROM Loan_Table;

------------------Loan with their Processing fee-------------
select
   c.Name,
   l.Loan_Amount,
   l.Interest_Rate,
   l.Processing_Fee,
   l.EMI_amount
From Customer_Table c
left join Loan_Table l on c.Customer_ID=l.Customer_ID
where Processing_Fee is Not null;



--------Finding Duplicates Rows--------

select Name, COUNT(*) as TotalCustomer
from Customer_Table
group by Name
having COUNT(*) > 1;

select Monthly_income, COUNT(*) as Income
from Customer_Table
group by Monthly_income
having COUNT(*) >1;



-------Top 10 Customer with their Loan_Amount > 500000-------

select top 10 c.Name, l.Loan_Amount
from Customer_Table c
left Join Loan_Table l on c.Customer_ID=l.Customer_ID
where l.Loan_Amount > 500000;

--------Checking the 2nd Highest Salary--------

SELECT MAX(Monthly_income) AS Second_Highest_Salary
FROM Customer_Table
WHERE Monthly_income < (
    SELECT MAX(Monthly_income) FROM Customer_Table
);


 SELECT MAX(Monthly_income) AS Highest_Salary
FROM Customer_Table;

---------Age & Income Segmentation----------
 

SELECT 
    CASE 
        WHEN Age < 20 THEN '18-20'
        WHEN Age BETWEEN 21 AND 25 THEN '21-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END AS Age_Group,
    AVG(c.Monthly_Income) AS Avg_Income,
    AVG(c.Credit_Score) As Avg_Credit_Score,
    COUNT(*) AS Customer_Count,
    Count(l.Default_flag) AS Defaulters
FROM Customer_Table c
join Loan_Table l on c.Customer_ID=l.Customer_ID
GROUP BY 
    CASE 
        WHEN Age < 20 THEN '18-20'
        WHEN Age BETWEEN 21 AND 25 THEN '21-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END;


---------------Gender-wise Loan Approval Patterns-------------

 
SELECT 
    c.Gender,
    COUNT(*) AS Total_Applications,
    SUM(CASE WHEN Loan_Status = 'Approved' THEN 1 END) AS Approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Approved' THEN 1 END) / COUNT(*), 2) AS Approval_Rate
FROM Customer_Table c
join Loan_Table l on c.Customer_ID=l.Customer_ID
GROUP BY Gender;


-------------High-Risk Customers-------------

SELECT 
    CASE 
        WHEN Age < 20 THEN '18-20'
        WHEN Age BETWEEN 21 AND 25 THEN '21-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END AS Age_Group;

-------------High-Risk Customers-------------
SELECT Name,Age,Credit_Score FROM Customer_Table
WHERE Fraud_Risk_Flag = 'Low'AND Credit_Score <= 550;


------------Total Rejections-------------

SELECT 
    Loan_Status,
    COUNT(*) AS Total_Rejections
FROM Loan_Table
WHERE Loan_Status = 'Rejected'
GROUP BY Loan_Status;


--------Income Bracket Distribution--------------
SELECT 
    CASE 
        WHEN Monthly_income < 20000 THEN 'Below 20k'
        WHEN Monthly_income BETWEEN 20000 AND 50000 THEN '20k - 50k'
        WHEN Monthly_income BETWEEN 50000 AND 100000 THEN '50k - 1L'
        ELSE '1L+'
    END AS Income_Bucket,
    COUNT(*) AS Total_Customers
FROM Customer_Table
GROUP BY 
    CASE 
        WHEN Monthly_income < 20000 THEN 'Below 20k'
        WHEN Monthly_income BETWEEN 20000 AND 50000 THEN '20k - 50k'
        WHEN Monthly_income BETWEEN 50000 AND 100000 THEN '50k - 1L'
        ELSE '1L+'
    END;



--------------Loan Status Summary------------
--1)

SELECT
    Loan_Status,
    COUNT(*) AS Total_Applications,
    SUM(CAST(Loan_Amount AS BIGINT)) AS Total_Loan_Value
FROM Loan_Table
GROUP BY Loan_Status;

--2)
SELECT 
    c.Customer_ID,
    c.Monthly_income,
    l.Loan_Amount,
    CASE 
        WHEN l.Loan_Status = 'Approved' THEN 'Eligible'
        ELSE 'Not Eligible'
    END AS Eligibility
FROM Customer_Table c
JOIN Loan_Table l ON c.Customer_ID = l.Customer_ID;



----------Loan Demand by Loan Type------------
SELECT 
    Loan_type,
    COUNT(*) AS Total_Applications,
    SUM(Loan_Amount) AS Total_Amount
FROM Loan_Table
GROUP BY Loan_type;


--------Average EMI & Interest Rate by Loan Type---------
Select 
    Loan_type,
    Count(*) AS Total_Loans,
    AVG(EMI_amount) as AVG_EMI,
    AVG(Interest_Rate) as AVG_Interest
From Loan_Table
Group by Loan_type;


------------Compare Loan Approved vs Rejected Customers---------------

Select 
    l.Loan_Status,
    AVG(CAST(c.Credit_score AS BIGINT)) AS Avg_CreditScore,
    AVG(CAST(c.Monthly_income AS BIGINT)) AS Avg_Income,
    AVG(CAST(l.Loan_Amount AS BIGINT)) AS Avg_LoanAmount
From Loan_Table l
left join Customer_Table c on l.Customer_ID=c.Customer_ID
Group by l.Loan_Status;

  



-----------Default Probability by Credit Score Range-----------

SELECT 
    CASE 
        WHEN c.Credit_score < 600 THEN 'Very Poor (<600)'
        WHEN c.Credit_score BETWEEN 600 AND 700 THEN 'Fair (600-700)'
        WHEN c.Credit_score BETWEEN 700 AND 800 THEN 'Good (700-800)'
        ELSE 'Excellent (800+)'
    END AS Score_Range,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN l.Default_flag = 1 THEN 1 END) AS Defaults,
    ROUND(100.0 * SUM(CASE WHEN l.Default_flag = 1 THEN 1 END) 
          / COUNT(*), 2) AS Default_Rate
FROM Loan_Table l
JOIN Customer_Table c ON l.Customer_ID = c.Customer_ID
GROUP BY 
    CASE 
        WHEN c.Credit_score < 600 THEN 'Very Poor (<600)'
        WHEN c.Credit_score BETWEEN 600 AND 700 THEN 'Fair (600-700)'
        WHEN c.Credit_score BETWEEN 700 AND 800 THEN 'Good (700-800)'
        ELSE 'Excellent (800+)'
    END;


    ---------------Income to EMI Ratio---------------
    SELECT 
        c.Customer_ID,
        c.Monthly_income,
        l.EMI_amount,
        ROUND((l.EMI_amount / c.Monthly_income) * 100, 2) AS FOIR_Percentage
    FROM Loan_Table l
    JOIN Customer_Table c ON l.Customer_ID = c.Customer_ID;


------------Loans Approved Without Collateral-----------
SELECT 
    Application_ID,
    Loan_type,
    Loan_Amount,
    Collateral_flag
FROM Loan_Table
WHERE Loan_type IN ('Home', 'Auto', 'Business')
  AND Collateral_flag = '0';


----------------Finding rank of customers by total loan exposure.-------------------

WITH Exposure AS (
    SELECT 
        Customer_ID,
        SUM(Loan_Amount) AS Total_Exposure
    FROM Loan_Table
    GROUP BY Customer_ID
)
SELECT 
    Customer_ID,
    Total_Exposure,
    RANK() OVER (ORDER BY Total_Exposure DESC) AS Exposure_Rank
FROM Exposure;


----------------------average EMI by loan type---------------
SELECT 
    Loan_type,
    EMI_amount,
    AVG(EMI_amount) OVER (PARTITION BY Loan_type) AS Avg_EMI_by_Type
FROM Loan_Table
Where EMI_amount is not null;


---------------Find customers whose FOIR > 40%, EMI burden is too high.-------------------
SELECT 
    c.Customer_ID,
    c.Monthly_income,
    SUM(l.EMI_amount) AS Total_EMI,
    (SUM(l.EMI_amount) * 1.0 / c.Monthly_income) AS FOIR
FROM Loan_Table l
JOIN Customer_Table c ON c.Customer_ID = l.Customer_ID
GROUP BY 
    c.Customer_ID, 
    c.Monthly_income
HAVING (SUM(l.EMI_amount) * 1.0 / c.Monthly_income) > 0.40;


select * from Customer_Table
select * from Loan_Table


----------------Default Rate by Loan Type------------------
SELECT Loan_Type,
       COUNT(*) AS Total_Loans,
       SUM(CASE WHEN Default_Flag = 1 THEN 1 END) AS Defaults,
       SUM(CASE WHEN Default_Flag = 1 THEN 1 END)*100.0/COUNT(*) AS Default_Rate
FROM Loan_Table
GROUP BY Loan_Type;


select * from Customer_Table

------------Customer Risk Segmentation----------------
SELECT 
    Customer_ID,Credit_Score,
    CASE 
        WHEN Credit_Score < 580 THEN 'High Risk'
        WHEN Credit_Score BETWEEN 580 AND 700 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Segment,
    Loan_Amount,
    Loan_Status
FROM Loan_Table;
