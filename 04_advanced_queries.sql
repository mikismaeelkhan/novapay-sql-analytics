-- ============================================================
--  NovaPay FinTech Analytics — Advanced Queries
--  Level: Advanced
--  Concepts: CTEs (WITH), window functions (ROW_NUMBER, RANK,
--            LAG, SUM OVER), running totals, cohort logic
-- ============================================================


-- ============================================================
-- Q1: Rank customers by total spending using window functions
-- ============================================================
-- Business context: Create a customer leaderboard for the product team.
-- Concepts: RANK() OVER (ORDER BY ...) — window function

WITH customer_spending AS (
    -- Step 1: Calculate total spend per customer
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.segment,
        SUM(ABS(t.amount)) AS total_spent
    FROM transactions t
        INNER JOIN accounts a  ON t.account_id  = a.account_id
        INNER JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.amount < 0
    GROUP BY c.customer_id, c.first_name, c.last_name, c.segment
)
-- Step 2: Rank them
SELECT
    customer_name,
    segment,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC)                    AS overall_rank,
    RANK() OVER (PARTITION BY segment ORDER BY total_spent DESC) AS rank_within_segment
FROM customer_spending
ORDER BY overall_rank;



-- ============================================================
-- Q2: Running total of deposits per account over time
-- ============================================================
-- Business context: Show how each account grew month by month.
-- Concepts: SUM() OVER (PARTITION BY ... ORDER BY ...) — running total

SELECT
    t.account_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    t.transaction_date,
    t.amount,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END)
        OVER (
            PARTITION BY t.account_id
            ORDER BY t.transaction_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_deposit_total
FROM transactions t
    INNER JOIN accounts a  ON t.account_id  = a.account_id
    INNER JOIN customers c ON a.customer_id = c.customer_id
ORDER BY t.account_id, t.transaction_date;



-- ============================================================
-- Q3: Month-over-month transaction volume growth
-- ============================================================
-- Business context: Leadership wants to see if the platform is growing.
-- Concepts: CTE + LAG() to compare current vs previous period

WITH monthly_volume AS (
    SELECT
        SUBSTR(transaction_date, 1, 7)  AS month,
        COUNT(*)                         AS total_transactions,
        SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS total_deposits,
        SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) AS total_withdrawals
    FROM transactions
    GROUP BY SUBSTR(transaction_date, 1, 7)
)
SELECT
    month,
    total_transactions,
    LAG(total_transactions) OVER (ORDER BY month) AS prev_month_transactions,
    total_transactions - LAG(total_transactions) OVER (ORDER BY month) AS txn_change,
    ROUND(
        100.0 * (total_transactions - LAG(total_transactions) OVER (ORDER BY month))
             / LAG(total_transactions) OVER (ORDER BY month),
        1
    ) AS pct_change,
    total_deposits,
    total_withdrawals
FROM monthly_volume
ORDER BY month;



-- ============================================================
-- Q4: Customer cohort analysis — spending by signup month
-- ============================================================
-- Business context: Do customers who signed up later spend more?
-- Concepts: CTE chaining, date truncation, cohort grouping

WITH customer_cohorts AS (
    SELECT
        customer_id,
        first_name || ' ' || last_name AS customer_name,
        SUBSTR(signup_date, 1, 7) AS cohort_month  -- 'YYYY-MM'
    FROM customers
),
customer_spend AS (
    SELECT
        a.customer_id,
        SUM(ABS(t.amount)) AS total_spent
    FROM transactions t
        INNER JOIN accounts a ON t.account_id = a.account_id
    WHERE t.amount < 0
    GROUP BY a.customer_id
)
SELECT
    cc.cohort_month,
    COUNT(DISTINCT cc.customer_id)       AS customers_in_cohort,
    ROUND(SUM(cs.total_spent), 2)        AS cohort_total_spend,
    ROUND(AVG(cs.total_spent), 2)        AS avg_spend_per_customer
FROM customer_cohorts cc
    LEFT JOIN customer_spend cs ON cc.customer_id = cs.customer_id
GROUP BY cc.cohort_month
ORDER BY cc.cohort_month;



-- ============================================================
-- Q5: Flag suspicious transactions (potential fraud detection)
-- ============================================================
-- Business context: Risk team wants to flag unusual spending.
--   Rule: A transaction is suspicious if it's more than 3x
--         the customer's average transaction size.
-- Concepts: CTE + window function for per-customer averages

WITH customer_avg_spend AS (
    SELECT
        a.customer_id,
        AVG(ABS(t.amount)) AS avg_transaction_size
    FROM transactions t
        INNER JOIN accounts a ON t.account_id = a.account_id
    WHERE t.amount < 0
    GROUP BY a.customer_id
)
SELECT
    t.transaction_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    t.amount,
    ROUND(cas.avg_transaction_size, 2)  AS customer_avg_spend,
    ROUND(ABS(t.amount) / cas.avg_transaction_size, 1) AS times_above_avg,
    t.description,
    t.transaction_date,
    'SUSPICIOUS' AS flag
FROM transactions t
    INNER JOIN accounts a          ON t.account_id  = a.account_id
    INNER JOIN customers c         ON a.customer_id = c.customer_id
    INNER JOIN customer_avg_spend cas ON a.customer_id = cas.customer_id
WHERE t.amount < 0
  AND ABS(t.amount) > (3 * cas.avg_transaction_size)
ORDER BY times_above_avg DESC;


-- ============================================================
-- Q6: Top 3 spending categories per customer
-- ============================================================
-- Business context: Personalise product recommendations per customer.
-- Concepts: ROW_NUMBER() with PARTITION BY, filtering window rank

WITH category_spend AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        m.category,
        SUM(ABS(t.amount))  AS amount_spent,
        COUNT(*)             AS num_transactions
    FROM transactions t
        INNER JOIN accounts a  ON t.account_id  = a.account_id
        INNER JOIN customers c ON a.customer_id = c.customer_id
        INNER JOIN merchants m ON t.merchant_id = m.merchant_id
    WHERE t.amount < 0
    GROUP BY c.customer_id, c.first_name, c.last_name, m.category
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY amount_spent DESC
        ) AS category_rank
    FROM category_spend
)
SELECT customer_name, category, amount_spent, num_transactions, category_rank
FROM ranked
WHERE category_rank <= 3
ORDER BY customer_name, category_rank;


-- ============================================================
-- Q7: Customer churn risk — who hasn't transacted in 30+ days?
-- ============================================================
-- Business context: Retention team flags customers at churn risk.
-- Concepts: CTE + MAX date per customer + date arithmetic + NULL handling
-- Note: customers with no transactions at all are the biggest risk, so
--       the NULL case is checked first.

WITH last_activity AS (
    SELECT
        a.customer_id,
        MAX(t.transaction_date) AS last_transaction_date
    FROM transactions t
        INNER JOIN accounts a ON t.account_id = a.account_id
    GROUP BY a.customer_id
)
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    la.last_transaction_date,
    -- SQLite: julianday() computes days between dates
    CAST(julianday('2024-03-01') - julianday(la.last_transaction_date) AS INTEGER)
        AS days_since_last_transaction,
    CASE
        WHEN la.last_transaction_date IS NULL
            THEN 'HIGH RISK - NO ACTIVITY'
        WHEN julianday('2024-03-01') - julianday(la.last_transaction_date) > 60
            THEN 'HIGH RISK'
        WHEN julianday('2024-03-01') - julianday(la.last_transaction_date) > 30
            THEN 'MEDIUM RISK'
        ELSE 'ACTIVE'
    END AS churn_risk
FROM customers c
    LEFT JOIN last_activity la ON c.customer_id = la.customer_id
WHERE c.is_active = 1
ORDER BY days_since_last_transaction DESC NULLS FIRST;


-- ============================================================
-- Q8: Executive Summary — one-query business dashboard
-- ============================================================
-- Business context: Weekly leadership meeting needs a snapshot.
-- Concepts: Multiple CTEs producing a single summary row

WITH totals AS (
    SELECT
        COUNT(DISTINCT customer_id)       AS total_customers,
        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_customers,
        SUM(CASE WHEN segment = 'business' THEN 1 ELSE 0 END) AS business_customers
    FROM customers
),
account_totals AS (
    SELECT
        COUNT(*)           AS total_accounts,
        SUM(balance)       AS total_assets_usd
    FROM accounts
    WHERE status = 'active'
),
txn_totals AS (
    SELECT
        COUNT(*)                                                    AS total_transactions,
        SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END)           AS total_deposited,
        SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END)      AS total_withdrawn
    FROM transactions
)
SELECT
    t.total_customers,
    t.active_customers,
    t.business_customers,
    at.total_accounts,
    ROUND(at.total_assets_usd, 2)  AS total_assets_usd,
    tt.total_transactions,
    ROUND(tt.total_deposited, 2)   AS total_deposited,
    ROUND(tt.total_withdrawn, 2)   AS total_withdrawn,
    ROUND(tt.total_deposited - tt.total_withdrawn, 2) AS net_flow
FROM totals t, account_totals at, txn_totals tt;


-- ============================================================
-- FURTHER ANALYSIS IDEAS
-- ============================================================
-- A. Calculate the 7-day rolling average of daily transactions
-- B. Find customers whose spending increased month-over-month
-- C. What % of total company deposits come from business customers?
-- D. Which customer had the single highest transaction relative
--    to their account balance? (hint: JOIN transactions to accounts)
