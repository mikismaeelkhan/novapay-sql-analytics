# NovaPay FinTech Analytics — SQL Portfolio Project

**Role:** Data Analyst (simulated)
**Tools:** SQL, SQLite, DB Browser for SQLite
**Dataset:** 4 tables, 15 customers, 20 accounts, 53 transactions, 15 merchants

---

## Project Overview

NovaPay is a fictional neobank operating across 8 countries. As the data analyst, I designed the full relational database schema from scratch and wrote 28 SQL queries to answer real business questions across four domains: customer behaviour, account performance, transaction analysis, and fraud/risk detection.

The queries progress from basic filtering and aggregation through multi-table JOINs, CTEs, window functions, and cohort analysis. Every number in this README comes straight from running the queries in this repo against the sample data.

---

## Key Findings

### Customer Overview
- **15 customers** across 8 countries (USA, UK, UAE, India, China, Germany, Mexico, Nigeria)
- **13 active customers**, 2 churned and flagged for a win-back campaign
- Customer base is split **67% retail / 33% business**

### Assets Under Management
- **$1.16M in total assets** across 18 active accounts
- Largest single account: **$320,000** investment account (Lin Zhao)
- Account types: 12 checking, 4 savings, 4 investment

### Transaction Insights
- **53 total transactions** from September 2023 to February 2024
- **$549,900 in total deposits** processed
- **$77,897 in total withdrawals** across all accounts
- Net flow: **+$472,003**
- Largest single transaction: **$200,000** initial investment deposit

### Business vs Retail Performance
- Business customers (33% of users) drove **~93% of all deposits**
- Business customers averaged **$170,000 in deposits** vs ~$8,000 for retail customers
- Business accounts held the **top 4 highest balances** on the entire platform

### Spending by Category
| Category | Total Spent | Avg Transaction |
|---|---|---|
| Travel | $12,705 | $1,588 |
| Tech | $9,729 | $2,432 |
| Retail | $4,995 | $714 |
| Food | $314 | $52 |
| Healthcare | $100 | $50 |
| Entertainment | $54 | $13 |

- **Travel and Tech** combined accounted for **80%** of all customer spending
- Highest average transaction size: **Tech at $2,432** per purchase

### Risk & Fraud Detection
- **5 active customers have never made a transaction** — flagged as highest churn risk (they signed up but never used the product)
- All other active customers transacted within the last 30 days
- **Fraud detection rule:** any withdrawal more than 3x the customer's average spend
- 1 transaction flagged: Aisha Patel's **$999 Apple Store purchase — 4.4x her average** of $230

---

## Sample Query Output

**Customer spending leaderboard** — `04_advanced_queries.sql`, Q1 (RANK window function, partitioned by segment)

| customer_name | segment | total_spent | overall_rank | rank_within_segment |
|---|---|---|---|---|
| Lin Zhao | business | 50,000.00 | 1 | 1 |
| James Wright | business | 11,900.00 | 2 | 2 |
| Daniel Kim | business | 11,600.00 | 3 | 3 |
| Priya Nair | retail | 2,149.99 | 4 | 1 |
| Aisha Patel | retail | 1,377.24 | 5 | 2 |
| Marcus Chen | retail | 393.98 | 6 | 3 |
| Sam Torres | retail | 309.99 | 7 | 4 |
| Sofia Reyes | retail | 165.99 | 8 | 5 |

**Month-over-month volume** — `04_advanced_queries.sql`, Q3 (LAG window function)

| month | total_transactions | prev_month | txn_change | pct_change | total_deposits | total_withdrawals |
|---|---|---|---|---|---|---|
| 2023-09 | 1 | | | | 200,000 | 0 |
| 2024-01 | 32 | 1 | +31 | +3100.0% | 250,100 | 10,866 |
| 2024-02 | 20 | 32 | -12 | -37.5% | 99,800 | 67,031 |

**Suspicious transaction flag** — `04_advanced_queries.sql`, Q5 (CTE + per-customer average)

| transaction_id | customer_name | amount | customer_avg_spend | times_above_avg | description | flag |
|---|---|---|---|---|---|---|
| 1009 | Aisha Patel | -999.00 | 229.54 | 4.4 | Apple Store | SUSPICIOUS |

**Executive summary** — `04_advanced_queries.sql`, Q8 (three CTEs collapsed into one row)

| total_customers | active_customers | business_customers | total_accounts | total_assets_usd | total_transactions | total_deposited | total_withdrawn | net_flow |
|---|---|---|---|---|---|---|---|---|
| 15 | 13 | 5 | 18 | 1,160,450.00 | 53 | 549,900.00 | 77,897.19 | 472,002.81 |

---

## SQL Skills Demonstrated

| Concept | Where Used |
|---|---|
| SELECT, WHERE, ORDER BY, LIMIT | Beginner queries — filtering customers, accounts, transactions |
| Aggregate functions (COUNT, SUM, AVG, MIN, MAX) | Account totals, transaction summaries |
| GROUP BY + HAVING | Spending by category, active customer counts |
| INNER JOIN + LEFT JOIN | Connecting transactions → accounts → customers → merchants |
| CASE WHEN | Account value tiering (High/Medium/Low), churn risk buckets |
| Subqueries | Finding accounts below their total deposit amount |
| CTEs (WITH clauses) | Fraud detection, churn risk, executive summary |
| Window functions (RANK, ROW_NUMBER, LAG) | Customer spending leaderboard, MoM growth, top categories per customer |
| Running totals (SUM OVER) | Cumulative deposit growth per account |
| Cohort analysis | Spend behaviour grouped by customer signup month |
| NULL handling | Catching customers with zero activity in churn analysis |

---

## Database Schema

```
customers
├── customer_id (PK)
├── first_name, last_name, email
├── country, segment (retail/business)
└── signup_date, is_active

accounts
├── account_id (PK)
├── customer_id (FK → customers)
├── account_type (checking/savings/investment)
└── balance, currency, status

transactions
├── transaction_id (PK)
├── account_id (FK → accounts)
├── merchant_id (FK → merchants, nullable)
├── amount  [positive = deposit, negative = withdrawal]
└── transaction_type, description, transaction_date

merchants
├── merchant_id (PK)
├── merchant_name, category, country
```

---

## Files

| File | Description |
|---|---|
| `01_schema_and_data.sql` | Creates all 4 tables and loads the sample data |
| `02_beginner_queries.sql` | 10 queries — SELECT, WHERE, ORDER BY, aggregates |
| `03_intermediate_queries.sql` | 10 queries — JOINs, GROUP BY, HAVING, CASE WHEN, subqueries |
| `04_advanced_queries.sql` | 8 queries — CTEs, window functions, fraud detection, churn risk, executive dashboard |

---

## How to Run

1. Download [DB Browser for SQLite](https://sqlitebrowser.org/) — free
2. Create a new database → open the **Execute SQL** tab
3. Paste and run `01_schema_and_data.sql` to set up the database
4. Run any query from files `02`, `03`, `04` — all 28 have been tested end to end against SQLite

---

*Project by Ismaeel Khan*
