-- ============================================================
--  NovaPay FinTech Analytics — Intermediate Queries
--  Level: Intermediate
--  Concepts: INNER JOIN, LEFT JOIN, GROUP BY + HAVING,
--            CASE WHEN, subqueries, date filtering
-- ============================================================


-- ============================================================
-- Q1: Show each transaction with the customer's full name
-- ============================================================
-- Business context: Ops team needs a readable transaction log.
-- Concepts: INNER JOIN across 3 tables (transactions → accounts → customers)

SELECT
    t.transaction_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    a.account_type,
    t.amount,
    t.transaction_type,
    t.description,
    t.transaction_date
FROM transactions t
    INNER JOIN accounts a    ON t.account_id  = a.account_id
    INNER JOIN customers c   ON a.customer_id = c.customer_id
ORDER BY t.transaction_date, customer_name;



-- ============================================================
-- Q2: What is each customer's total spending? (withdrawals only)
-- ============================================================
-- Business context: Identify your highest-spending customers.
-- Concepts: JOIN + GROUP BY + aggregate, ABS() to flip negatives

SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    c.segment,
    SUM(ABS(t.amount))                  AS total_spent,
    COUNT(t.transaction_id)             AS number_of_transactions
FROM transactions t
    INNER JOIN accounts a  ON t.account_id  = a.account_id
    INNER JOIN customers c ON a.customer_id = c.customer_id
WHERE t.amount < 0  -- only withdrawals/spending
GROUP BY c.customer_id, c.first_name, c.last_name, c.segment
ORDER BY total_spent DESC;


-- ============================================================
-- Q3: Which customers have NEVER made a transaction?
-- ============================================================
-- Business context: Find dormant customers for re-engagement.
-- Concepts: LEFT JOIN — keeps rows from left table even without a match

SELECT
    c.first_name,
    c.last_name,
    c.email,
    c.signup_date
FROM customers c
    LEFT JOIN accounts a      ON c.customer_id = a.customer_id
    LEFT JOIN transactions t  ON a.account_id  = t.account_id
WHERE t.transaction_id IS NULL  -- NULL means no matching transaction was found
ORDER BY c.signup_date;



-- ============================================================
-- Q4: Which merchant categories are customers spending the most on?
-- ============================================================
-- Business context: Product team wants to know where NovaPay users shop.
-- Concepts: JOIN + GROUP BY + ORDER BY

SELECT
    m.category,
    COUNT(t.transaction_id)   AS number_of_purchases,
    SUM(ABS(t.amount))        AS total_spent,
    ROUND(AVG(ABS(t.amount)), 2) AS avg_transaction_size
FROM transactions t
    INNER JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.amount < 0
GROUP BY m.category
ORDER BY total_spent DESC;


-- ============================================================
-- Q5: Which customers have more than 5 transactions?
-- ============================================================
-- Business context: Find your most active users.
-- Concepts: HAVING — like WHERE but for groups

SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(t.transaction_id)             AS transaction_count
FROM transactions t
    INNER JOIN accounts a  ON t.account_id  = a.account_id
    INNER JOIN customers c ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(t.transaction_id) > 5
ORDER BY transaction_count DESC;



-- ============================================================
-- Q6: Label each account as "High", "Medium", or "Low" value
-- ============================================================
-- Business context: Segment accounts for tiered customer service.
-- Concepts: CASE WHEN — SQL's if/else

SELECT
    account_id,
    customer_id,
    account_type,
    balance,
    CASE
        WHEN balance >= 50000  THEN 'High Value'
        WHEN balance >= 10000  THEN 'Medium Value'
        ELSE                        'Low Value'
    END AS value_tier
FROM accounts
WHERE status = 'active'
ORDER BY balance DESC;


-- ============================================================
-- Q7: What is the net cash flow (deposits minus withdrawals)
--     per customer?
-- ============================================================
-- Business context: Treasury team wants to see money in vs money out.
-- Concepts: Conditional aggregation with CASE WHEN inside SUM

SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(CASE WHEN t.amount > 0 THEN  t.amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN t.amount < 0 THEN  t.amount ELSE 0 END) AS total_withdrawals,
    SUM(t.amount)                                          AS net_cash_flow
FROM transactions t
    INNER JOIN accounts a  ON t.account_id  = a.account_id
    INNER JOIN customers c ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY net_cash_flow DESC;


-- ============================================================
-- Q8: Which accounts have a balance below their total deposits?
--     (i.e., they've spent more than they've saved)
-- ============================================================
-- Business context: Risk team flags customers burning through cash.
-- Concepts: Subquery in WHERE clause

SELECT
    a.account_id,
    a.customer_id,
    a.balance,
    (
        SELECT SUM(t.amount)
        FROM transactions t
        WHERE t.account_id = a.account_id
          AND t.amount > 0
    ) AS total_ever_deposited
FROM accounts a
WHERE status = 'active'
  AND balance < (
        SELECT COALESCE(SUM(t.amount), 0)
        FROM transactions t
        WHERE t.account_id = a.account_id
          AND t.amount > 0
      );



-- ============================================================
-- Q9: Show each customer's account count and total balance
-- ============================================================
-- Business context: Wealth management wants a customer overview.
-- Concepts: JOIN + GROUP BY + multiple aggregates

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.segment,
    COUNT(a.account_id)  AS number_of_accounts,
    SUM(a.balance)       AS total_balance_across_accounts,
    MAX(a.balance)       AS largest_single_account
FROM customers c
    LEFT JOIN accounts a ON c.customer_id = a.customer_id
                         AND a.status = 'active'
GROUP BY c.customer_id, c.first_name, c.last_name, c.segment
ORDER BY total_balance_across_accounts DESC NULLS LAST;


-- ============================================================
-- Q10: What is the most popular merchant for each category?
-- ============================================================
-- Business context: Partnership team wants the #1 merchant per category.
-- Concepts: Subquery to find the top merchant per group

SELECT
    m.category,
    m.merchant_name,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(ABS(t.amount))      AS total_volume
FROM transactions t
    INNER JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.amount < 0
GROUP BY m.category, m.merchant_id, m.merchant_name
HAVING COUNT(t.transaction_id) = (
    -- Subquery: find the max transaction count for that category
    SELECT MAX(sub.cnt)
    FROM (
        SELECT m2.category, m2.merchant_id, COUNT(*) AS cnt
        FROM transactions t2
            INNER JOIN merchants m2 ON t2.merchant_id = m2.merchant_id
        WHERE t2.amount < 0
        GROUP BY m2.category, m2.merchant_id
    ) sub
    WHERE sub.category = m.category
)
ORDER BY m.category;


-- ============================================================
-- FURTHER ANALYSIS IDEAS
-- ============================================================
-- A. Which country has the highest total account balance?
-- B. Show all transactions from business customers only
-- C. Find customers who have both a checking AND savings account
-- D. Which account had the most transactions in January 2024?
