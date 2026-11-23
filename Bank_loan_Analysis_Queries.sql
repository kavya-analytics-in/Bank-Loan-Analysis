-- BANK LOAN ANALYSIS PROJECT
-- SQL DATA CLEANING 

use bank_loan_project;

-- STEP 1: Create fresh working copies

CREATE TABLE finance_1_clean_v2 like finance_1;
INSERT INTO finance_1_clean_v2
SELECT *
FROM finance_1;

CREATE TABLE finance_2_clean_v2
LIKE finance_2;
INSERT INTO finance_2_clean_v2
SELECT *
FROM finance_2;

-- STEP 2: Temporarily disable Safe Update Mode
SET SQL_SAFE_UPDATES = 0;

-- STEP 3: Standardise issue date in Finance 1

UPDATE finance_2_clean_v2
SET last_pymnt_d = CONCAT(
    '20',
    RIGHT(last_pymnt_d, 2),
    '-',
    CASE LEFT(last_pymnt_d, 3)
        WHEN 'Jan' THEN '01'
        WHEN 'Feb' THEN '02'
        WHEN 'Mar' THEN '03'
        WHEN 'Apr' THEN '04'
        WHEN 'May' THEN '05'
        WHEN 'Jun' THEN '06'
        WHEN 'Jul' THEN '07'
        WHEN 'Aug' THEN '08'
        WHEN 'Sep' THEN '09'
        WHEN 'Oct' THEN '10'
        WHEN 'Nov' THEN '11'
        WHEN 'Dec' THEN '12'
    END,
    '-01'
)
WHERE last_pymnt_d IS NOT NULL;

SET SQL_SAFE_UPDATES = 0;

-- STEP 3: Standardise issue date in Finance 1

UPDATE finance_1_clean_v2
SET issue_d = CONCAT(
    '20',
    RIGHT(issue_d, 2),
    '-',
    CASE LEFT(issue_d, 3)
        WHEN 'Jan' THEN '01'
        WHEN 'Feb' THEN '02'
        WHEN 'Mar' THEN '03'
        WHEN 'Apr' THEN '04'
        WHEN 'May' THEN '05'
        WHEN 'Jun' THEN '06'
        WHEN 'Jul' THEN '07'
        WHEN 'Aug' THEN '08'
        WHEN 'Sep' THEN '09'
        WHEN 'Oct' THEN '10'
        WHEN 'Nov' THEN '11'
        WHEN 'Dec' THEN '12'
    END,
    '-01'
)
WHERE issue_d IS NOT NULL;


UPDATE finance_2_clean_v2
SET earliest_cr_line = CONCAT(
    CASE
        WHEN CAST(RIGHT(earliest_cr_line, 2) AS UNSIGNED) <= 8
        THEN '20'
        ELSE '19'
    END,
    RIGHT(earliest_cr_line, 2),
    '-',
    CASE LEFT(earliest_cr_line, 3)
        WHEN 'Jan' THEN '01'
        WHEN 'Feb' THEN '02'
        WHEN 'Mar' THEN '03'
        WHEN 'Apr' THEN '04'
        WHEN 'May' THEN '05'
        WHEN 'Jun' THEN '06'
        WHEN 'Jul' THEN '07'
        WHEN 'Aug' THEN '08'
        WHEN 'Sep' THEN '09'
        WHEN 'Oct' THEN '10'
        WHEN 'Nov' THEN '11'
        WHEN 'Dec' THEN '12'
    END,
    '-01'
)
WHERE id > 0
AND earliest_cr_line IS NOT NULL
AND TRIM(earliest_cr_line) <> '';

UPDATE finance_2_clean_v2
SET next_pymnt_d = CONCAT(
    '20',
    RIGHT(TRIM(next_pymnt_d), 2),
    '-',
    CASE LEFT(TRIM(next_pymnt_d), 3)
        WHEN 'Jan' THEN '01'
        WHEN 'Feb' THEN '02'
        WHEN 'Mar' THEN '03'
        WHEN 'Apr' THEN '04'
        WHEN 'May' THEN '05'
        WHEN 'Jun' THEN '06'
        WHEN 'Jul' THEN '07'
        WHEN 'Aug' THEN '08'
        WHEN 'Sep' THEN '09'
        WHEN 'Oct' THEN '10'
        WHEN 'Nov' THEN '11'
        WHEN 'Dec' THEN '12'
    END,
    '-01'
)
WHERE id > 0
AND next_pymnt_d IS NOT NULL
AND TRIM(next_pymnt_d) <> '';

SET SQL_SAFE_UPDATES = 1;



 -- year-wise Loan Amount Statistics
SELECT
    YEAR(issue_d) AS issue_year,
    SUM(loan_amnt) AS total_loan_amount,
    SUM(funded_amnt) AS total_funded_amount,
    AVG(loan_amnt) AS average_loan_amount,
    COUNT(id) AS total_loan_applications
FROM finance_1_clean_v2
GROUP BY YEAR(issue_d)
ORDER BY issue_year;



-- Grade-wise and Sub-grade-wise Revolving Balance
SELECT
    f1.grade,
    f1.sub_grade,
    SUM(f2.revol_bal) AS total_revolving_balance
FROM finance_1_clean_v2 f1
JOIN finance_2_clean_v2 f2
    ON f1.id = f2.id
GROUP BY
    f1.grade,
    f1.sub_grade
ORDER BY
    f1.grade,
    f1.sub_grade;
    
    
  
  -- Verified vs Non-Verified Total Payments
    SELECT
    f1.verification_status,
    SUM(f2.total_pymnt) AS total_payments,
    COUNT(f1.id) AS total_loans
FROM finance_1_clean_v2 f1
JOIN finance_2_clean_v2 f2
    ON f1.id = f2.id
GROUP BY f1.verification_status
ORDER BY total_payments DESC;



-- State-wise loan status
SELECT
    f1.addr_state,
    f1.loan_status,
    COUNT(f1.id) AS total_loan_applications
FROM finance_1_clean_v2 f1
GROUP BY
    f1.addr_state,
    f1.loan_status
ORDER BY
    f1.addr_state,
    total_loan_applications DESC;
    
    
    
 -- Month-wise loan status  
  SELECT
    MONTH(issue_d) AS issue_month_number,
    MONTHNAME(issue_d) AS issue_month,
    loan_status,
    COUNT(id) AS total_loan_applications
FROM finance_1_clean_v2
GROUP BY
    MONTH(issue_d),
    MONTHNAME(issue_d),
    loan_status
ORDER BY
    issue_month_number,
    loan_status; 
  


-- Home Ownership vs Last Payment Date
SELECT
    f1.home_ownership,
    f2.last_pymnt_d,
    COUNT(f1.id) AS total_loan_applications,
    SUM(f2.total_pymnt) AS total_payments
FROM finance_1_clean_v2 f1
JOIN finance_2_clean_v2 f2
    ON f1.id = f2.id
WHERE f2.last_pymnt_d IS NOT NULL
GROUP BY
    f1.home_ownership,
    f2.last_pymnt_d
ORDER BY
    f2.last_pymnt_d,
    f1.home_ownership;
    
   
    
    
    
    