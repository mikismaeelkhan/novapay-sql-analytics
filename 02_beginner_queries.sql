-- ============================================================
--  NovaPay FinTech Analytics — Beginner Queries
--  Level: Beginner
--  Concepts: SELECT, WHERE, ORDER BY, LIMIT, DISTINCT, LIKE,
--            aggregate functions (COUNT, SUM, AVG, MIN, MAX)
-- ============================================================
-- HOW TO USE THIS FILE:
--   1. Read the BUSINESS QUESTION for context
--   2. Read the CONCEPTS being introduced
--   3. Study the SQL, then try to understand each line
--   4. Run it and check the result matches the expected output
-- ============================================================


-- ============================================================
-- Q1: How many customers does NovaPay have?
-- ============================================================
-- Business context: Basic headcount — leadership asks this all the time.
-- Concepts: COUNT(*), aliasing with AS

SELECT COUNT(*) AS total_customers
FROM customers;

-- Expected: 15


-- ============================================================
-- Q2: List all customers from the USA.
-- ============================================================
-- Business context: Target US customers for a new feature rollout.
-- Concepts: WHERE, text filtering

SELECT first_name, last_name, email, signup_date
FROM customers
WHERE country = 'USA';

-- Expected: Aisha, James, Marcus, Daniel, Sam  (5 rows)


-- ============================================================
-- Q3: Which customers are currently inactive (churned)?
-- ============================================================
-- Business context: The growth team wants to run a win-back campaign.
-- Concepts: WHERE with integer boolean, ORDER BY

SELECT first_name, last_name, email, country
FROM customers
WHERE is_active = 0
ORDER BY last_name;

-- Expected: Mei Lin, Nia Okafor


-- ============================================================
-- Q4: What are the top 5 accounts by current balance?
-- ============================================================
-- Business context: Identify high-value accounts for premium support.
-- Concepts: ORDER BY DESC, LIMIT

SELECT account_id, customer_id, account_type, balance, currency
FROM accounts
ORDER BY balance DESC
LIMIT 5;

-- Expected: account 120 ($320k), 104 ($245k), 110 (£180k), etc.


-- ============================================================
-- Q5: How many accounts are there of each type?
-- ============================================================
-- Business context: Product team wants to know the account mix.
-- Concepts: GROUP BY, COUNT

SELECT account_type, COUNT(*) AS number_of_accounts
FROM accounts
GROUP BY account_type
ORDER BY number_of_accounts DESC;

-- Expected: checking(10), savings(4), investment(4)  ← roughly


-- ============================================================
-- Q6: What is the total value of all active accounts?
-- ============================================================
-- Business context: Finance needs total assets under management.
-- Concepts: SUM, WHERE

SELECT SUM(balance) AS total_assets
FROM accounts
WHERE status = 'active';


-- ============================================================
-- Q7: What is the average, minimum, and maximum account balance?
-- ============================================================
-- Business context: Understand the spread of customer wealth.
-- Concepts: AVG, MIN, MAX — multiple aggregates in one query

SELECT
    ROUND(AVG(balance), 2) AS avg_balance,
    MIN(balance)           AS min_balance,
    MAX(balance)           AS max_balance
FROM accounts
WHERE status = 'active';


-- ============================================================
-- Q8: How many distinct countries do our customers come from?
-- ============================================================
-- Business context: Marketing wants to know our geographic reach.
-- Concepts: DISTINCT, COUNT(DISTINCT ...)

SELECT COUNT(DISTINCT country) AS number_of_countries
FROM customers;

-- Bonus — list the countries:
SELECT DISTINCT country
FROM customers
ORDER BY country;


-- ============================================================
-- Q9: Find all transactions over $1,000.
-- ============================================================
-- Business context: Compliance wants to flag large transactions for review.
-- Concepts: WHERE with numeric comparison, ABS() for negatives

SELECT transaction_id, account_id, amount, transaction_type, description, transaction_date
FROM transactions
WHERE ABS(amount) > 1000
ORDER BY ABS(amount) DESC;


-- ============================================================
-- Q10: How many transactions happened in January 2024 vs February 2024?
-- ============================================================
-- Business context: Month-over-month activity comparison.
-- Concepts: WHERE with date range, BETWEEN, GROUP BY on string expression

-- Option A — using BETWEEN
SELECT transaction_date, COUNT(*) AS daily_transactions
FROM transactions
WHERE transaction_date BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY transaction_date
ORDER BY transaction_date;

-- Option B — count per month
SELECT
    SUBSTR(transaction_date, 1, 7) AS month,  -- extracts 'YYYY-MM'
    COUNT(*)                        AS total_transactions,
    SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS total_deposited,
    SUM(CASE WHEN amount < 0 THEN amount ELSE 0 END) AS total_spent
FROM transactions
GROUP BY SUBSTR(transaction_date, 1, 7)
ORDER BY month;

-- ============================================================
-- CHALLENGE: Try these on your own before looking up the answer
-- ============================================================
-- A. How many business vs retail customers do we have?
-- B. List all accounts that are NOT active (closed or frozen)
-- C. What was the largest single transaction ever made?
-- D. How many customers signed up in 2023?
