# NovaPay FinTech Analytics — SQL Portfolio Project

A beginner-to-advanced SQL project built around a fictional neobank. You play the role of a **Data Analyst at NovaPay**, answering real business questions across customer, account, and transaction data.

Built for: Data Analyst roles in **tech and finance**

---

## What You'll Learn

| File | Level | Concepts |
|------|-------|----------|
| `01_schema_and_data.sql` | Setup | Table design, data types, foreign keys |
| `02_beginner_queries.sql` | Beginner | SELECT, WHERE, ORDER BY, COUNT, SUM, AVG |
| `03_intermediate_queries.sql` | Intermediate | JOINs, GROUP BY, HAVING, CASE WHEN, subqueries |
| `04_advanced_queries.sql` | Advanced | CTEs (WITH), window functions, LAG, RANK, running totals |

---

## The Business

**NovaPay** is a neobank serving retail and business customers across 9 countries. The database tracks:

- **customers** — 15 customers (retail + business), 9 countries
- **accounts** — checking, savings, and investment accounts
- **transactions** — deposits, withdrawals, and transfers
- **merchants** — 15 merchants across 6 spending categories

---

## Schema

```
customers
├── customer_id (PK)
├── first_name, last_name, email
├── country, segment (retail/business)
├── signup_date, is_active

accounts
├── account_id (PK)
├── customer_id (FK → customers)
├── account_type (checking/savings/investment)
├── balance, currency, status

transactions
├── transaction_id (PK)
├── account_id (FK → accounts)
├── merchant_id (FK → merchants, nullable)
├── amount (negative = spending, positive = deposit)
├── transaction_type, description, transaction_date

merchants
├── merchant_id (PK)
├── merchant_name, category, country
```

---

## How to Run This

### Option 1 — SQLite (recommended for beginners, free)
1. Download [DB Browser for SQLite](https://sqlitebrowser.org/) — free GUI tool
2. Create a new database: **File → New Database** → save as `novapay.db`
3. Open `01_schema_and_data.sql` → paste into the SQL Editor → **Execute**
4. Work through files `02`, `03`, `04` in order

### Option 2 — PostgreSQL
- Works as-is with minor adjustments:
  - Replace `SUBSTR(date, 1, 7)` with `TO_CHAR(date, 'YYYY-MM')`
  - Replace `julianday()` with `date - interval` syntax
  - `||` string concat works the same

### Option 3 — Online (no install)
- [SQLiteOnline.com](https://sqliteonline.com/) — paste and run directly in the browser

---

## Business Questions Answered

### Beginner
- How many customers does NovaPay have?
- Which customers are inactive (churned)?
- What are the top 5 accounts by balance?
- How many transactions happened each month?

### Intermediate
- What is each customer's total spending?
- Which customers have never made a transaction?
- Which merchant categories are most popular?
- What is each customer's net cash flow (in vs out)?

### Advanced
- Rank customers by spending (overall and within segment)
- Calculate month-over-month transaction volume growth
- Flag suspicious transactions (potential fraud)
- Identify customers at churn risk
- Build an executive summary dashboard in SQL

---

## Skills Demonstrated (for your resume/LinkedIn)

- Writing multi-table JOINs across a normalized schema
- Aggregation and grouping for business metrics
- CTEs for clean, readable query structure
- Window functions: `RANK()`, `ROW_NUMBER()`, `LAG()`, running totals
- Business thinking: translating analyst questions into SQL

---

## Extending This Project

Once you've completed all 4 files, here are ways to go further:

1. **Add more data** — extend the sample data with 6+ months and 100+ customers
2. **Build a dashboard** — connect to Tableau, Power BI, or Metabase
3. **Write a report** — document your findings as if presenting to leadership
4. **Optimize queries** — add indexes, rewrite for performance
5. **Try BigQuery or Snowflake** — port this to a cloud warehouse

---

*Project by Ismaeel Khan*
