NovaPay FinTech Analytics — SQL Portfolio Project

Role: Data Analyst (simulated) Tools: SQL, SQLite, DB Browser for SQLite Dataset: 4 tables, 15 customers, 20 accounts, 53 transactions, 15 merchants

Project Overview

NovaPay is a fictional neobank operating across 8 countries. As the data analyst, I designed the full relational database schema from scratch and wrote 28+ SQL queries to answer real business questions across four domains: customer behaviour, account performance, transaction analysis, and fraud/risk detection.

This project covers SQL from beginner to advanced — progressing from basic filtering and aggregation through to multi-table JOINs, CTEs, window functions, and cohort analysis.

Key Findings
Customer Overview
15 customers across 8 countries (USA, UK, UAE, India, China, Germany, Mexico, Nigeria)
13 active customers, 2 identified as churned and flagged for win-back campaign
Customer base is split 67% retail / 33% business
Assets Under Management
$1.17M+ in total assets across 18 active accounts
Largest single account: $320,000 investment account (Lin Zhao)
Account types: 10 checking, 4 savings, 4 investment
Transaction Insights
53 total transactions across January–February 2024
$556,900 in total deposits processed
$77,500+ in total withdrawals across all accounts
Largest single transaction: $200,000 initial investment deposit
Business vs Retail Performance
Business customers (33% of users) drove ~93% of all deposits
Business customers averaged $170,000+ in deposits vs ~$8,000 for retail customers
Business accounts held the top 3 highest balances across the entire platform
Spending by Category
Category	Total Spent	Avg Transaction
Travel	$12,705	$1,588
Tech	$9,729	$1,944
Retail	$3,475	$695
Food	$314	$52
Healthcare	$100	$50
Entertainment	$54	$13
Travel and Tech combined accounted for over 80% of all customer spending
Highest average transaction size: Tech at $1,944 per purchase
Risk & Fraud Detection
2 customers flagged at high churn risk — no transactions recorded in 60+ days
Fraud detection query identified transactions more than 3x a customer's average spend
James Wright (business) flagged for a $4,800 flight purchase — 1.5x above his average
SQL Skills Demonstrated
Concept	Where Used
SELECT, WHERE, ORDER BY, LIMIT	Beginner queries — filtering customers, accounts, transactions
Aggregate functions (COUNT, SUM, AVG, MIN, MAX)	Account totals, transaction summaries
GROUP BY + HAVING	Spending by category, active customer counts
INNER JOIN + LEFT JOIN	Connecting transactions → accounts → customers → merchants
CASE WHEN	Account value tiering (High/Medium/Low)
Subqueries	Finding accounts below their total deposit amount
CTEs (WITH clauses)	Fraud detection, churn risk, executive summary
Window functions (RANK, ROW_NUMBER, LAG)	Customer spending leaderboard, MoM growth
Running totals (SUM OVER)	Cumulative deposit growth per account
Cohort analysis	Spend behaviour grouped by customer signup month
Database Schema
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
Files
File	Description
01_schema_and_data.sql	Creates all 4 tables and loads 53 transactions of sample data
02_beginner_queries.sql	10 beginner queries — SELECT, WHERE, ORDER BY, aggregates
03_intermediate_queries.sql	10 intermediate queries — JOINs, GROUP BY, HAVING, CASE WHEN
04_advanced_queries.sql	8 advanced queries — CTEs, window functions, fraud detection, churn risk
How to Run
Download DB Browser for SQLite — free
Create a new database → open the Execute SQL tab
Paste and run 01_schema_and_data.sql to set up the database
Work through files 02, 03, 04 — paste queries one at a time and run

Project by Ismaeel Khan | linkedin.com/in/your-linkedin
