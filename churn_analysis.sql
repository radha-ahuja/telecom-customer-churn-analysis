/* This project analyzes customer churn in a telecom company to identify key factors driving 
customer attrition and revenue loss, and provides actionable business recommendations.*/
CREATE DATABASE churn_project;

USE churn_project;

CREATE TABLE churn_data (
    customer_id VARCHAR(50),
    gender VARCHAR(10),
    senior_citizen INT,
    partner VARCHAR(10),
    dependents VARCHAR(10),
    tenure INT,
    phone_service VARCHAR(10),
    multiple_lines VARCHAR(50),
    internet_service VARCHAR(50),
    online_security VARCHAR(50),
    online_backup VARCHAR(50),
    device_protection VARCHAR(50),
    tech_support VARCHAR(50),
    streaming_tv VARCHAR(50),
    streaming_movies VARCHAR(50),
    contract VARCHAR(50),
    paper_less_billing VARCHAR(10),
    payment_method VARCHAR(50),
    monthly_charges DECIMAL(10,2),
    total_charges VARCHAR(50),
    churn VARCHAR(10)
);

SHOW VARIABLES LIKE 'secure_file_priv';

SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/churn_csv.csv'
INTO TABLE churn_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM churn_data;

DESCRIBE churn_data;

ALTER TABLE churn_data
ADD PRIMARY KEY (customer_id);

SELECT 
    churn,
    LENGTH(churn) AS len
FROM churn_data
WHERE churn LIKE '%Yes%'
LIMIT 10;

#Before performing analysis, I validated and cleaned categorical fields to remove hidden characters.
UPDATE churn_data
SET churn = TRIM(REPLACE(churn, '\r', ''));

SELECT 
    CASE 
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '48+ Months'
    END AS tenure_group,    
    COUNT(*) AS total_customers,    
    SUM(CASE WHEN TRIM(churn) = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,    
    ROUND(
        SUM(CASE WHEN TRIM(churn) = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM churn_data
GROUP BY tenure_group
ORDER BY churn_rate DESC;

/* Insight:-
Customers within their first 12 months show the highest churn rate (~47%), 
indicating that early customer engagement and onboarding strategies need significant improvement. */

/* Recommendations :-
The company should introduce targeted retention programs for customers in their first year, 
such as onboarding support, promotional offers, or service assistance. */


# Contract Type vs Churn : To check which type of contractors churn fast?
SELECT 
    contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM churn_data
GROUP BY contract
ORDER BY churn_rate DESC;

/* Insight:
Customers on month-to-month contracts exhibit significantly higher churn (~43%), whereas customers on two-year contracts show extremely low churn (~3%). 
Encouraging long-term contracts could dramatically improve retention. */

/* Recommendations: 
👉 Offer discounts on yearly plans
👉 Provide upgrade incentives
👉 Lock-in pricing benefits
Goal → shift customers from flexible to committed plans. */

# Monthly Charges vs Churn
SELECT 
    CASE 
        WHEN monthly_charges < 35 THEN 'Low Charges'
        WHEN monthly_charges BETWEEN 35 AND 70 THEN 'Medium Charges'
        ELSE 'High Charges'
    END AS charge_category,
    
    COUNT(*) AS total_customers,
    
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    
    ROUND(
        SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate

FROM churn_data
GROUP BY charge_category
ORDER BY churn_rate DESC;

/* Insight :
Customers with higher monthly charges demonstrate significantly higher churn, suggesting perceived 
value gaps and pricing sensitivity among new or flexible-plan customers. 

Recommendation:-
👉 Bundle services
👉 Give first-year discounts
👉 Offer loyalty pricing
👉 Provide plan optimization

Goal?
👉 Make customers feel price = value

*/

# Internet Service vs Churn
SELECT 
    internet_service,
    COUNT(*) AS total_customers,
    
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    
    ROUND(
        SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate

FROM churn_data
GROUP BY internet_service
ORDER BY churn_rate DESC;

/* Insight :-
Fiber optic customers exhibit the highest churn (~42%), 
indicating potential service quality gaps, pricing concerns, or unmet performance expectations.

Recommendation:-
👉 Improve fiber service reliability
👉 Provide priority tech support
👉 Offer bundled pricing
👉 Give contract discounts
Goal:
👉 Protect high revenue customers. */

# Tenure + Contract Churn rate
SELECT 
    contract,

    CASE 
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '48+ Months'
    END AS tenure_group,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,

    ROUND(
        SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate

FROM churn_data
GROUP BY contract, tenure_group
ORDER BY churn_rate DESC;

/* Insights :-
Customers on month-to-month contracts within their first year exhibit the highest churn (~51%), 
highlighting the critical importance of early-stage retention strategies and contract conversion.
Recommendation :-
👉 Convert new customers to yearly plans ASAP
👉 Give onboarding support
👉 Offer first-year incentives
👉 Reduce early friction */

# Payment Method vs Churn
SELECT 
    payment_method,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,

    ROUND(
        SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate

FROM churn_data
GROUP BY payment_method
ORDER BY churn_rate DESC;

/* Customers using electronic check show significantly higher churn (~45%), whereas automatic payment 
users demonstrate much stronger retention. Promoting auto-pay adoption could reduce churn. */

#Overall Conclusion :-
/* Early-tenure customers on flexible contracts, 
particularly those paying higher charges and using fiber services, had the highest likelihood of churning. 
Payment behavior also played a major role, with manual payment users showing significantly lower retention. */