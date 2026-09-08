-- ============================================================
--  NovaPay FinTech Analytics — Schema & Sample Data
--  Project: SQL Portfolio Project (Beginner → Advanced)
--  Dialect: Standard SQL (works in PostgreSQL, SQLite, MySQL)
-- ============================================================
-- BUSINESS CONTEXT:
--   NovaPay is a fictional neobank. As their data analyst,
--   you'll answer real business questions using this data.
--
-- TABLES:
--   customers     → who uses NovaPay
--   accounts      → what type of account they have
--   transactions  → money moving in/out of accounts
--   merchants     → where customers spend money
-- ============================================================


-- ============================================================
-- DROP TABLES (run this if you want to reset everything)
-- ============================================================
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS customers;


-- ============================================================
-- TABLE 1: customers
-- ============================================================
CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    first_name    TEXT NOT NULL,
    last_name     TEXT NOT NULL,
    email         TEXT UNIQUE NOT NULL,
    country       TEXT NOT NULL,
    segment       TEXT NOT NULL,   -- 'retail' or 'business'
    signup_date   DATE NOT NULL,
    is_active     INTEGER NOT NULL DEFAULT 1  -- 1=active, 0=churned
);

INSERT INTO customers VALUES
(1,  'Aisha',   'Patel',     'aisha.patel@email.com',     'USA',  'retail',   '2023-01-15', 1),
(2,  'James',   'Wright',    'james.wright@email.com',    'USA',  'business', '2023-02-03', 1),
(3,  'Sofia',   'Reyes',     'sofia.reyes@email.com',     'UK',   'retail',   '2023-02-20', 1),
(4,  'Marcus',  'Chen',      'marcus.chen@email.com',     'USA',  'retail',   '2023-03-10', 1),
(5,  'Priya',   'Nair',      'priya.nair@email.com',      'India','retail',   '2023-03-25', 1),
(6,  'Oliver',  'Banks',     'oliver.banks@email.com',    'UK',   'business', '2023-04-08', 1),
(7,  'Fatima',  'Hassan',    'fatima.hassan@email.com',   'UAE',  'retail',   '2023-04-15', 1),
(8,  'Daniel',  'Kim',       'daniel.kim@email.com',      'USA',  'business', '2023-05-01', 1),
(9,  'Mei',     'Lin',       'mei.lin@email.com',         'China','retail',   '2023-05-18', 0),
(10, 'Carlos',  'Mendez',    'carlos.mendez@email.com',   'Mexico','retail',  '2023-06-02', 1),
(11, 'Yasmin',  'Al-Rashid', 'yasmin.alrashid@email.com', 'UAE',  'business', '2023-06-20', 1),
(12, 'Tom',     'Fischer',   'tom.fischer@email.com',     'Germany','retail', '2023-07-05', 1),
(13, 'Nia',     'Okafor',    'nia.okafor@email.com',      'Nigeria','retail', '2023-07-22', 0),
(14, 'Sam',     'Torres',    'sam.torres@email.com',      'USA',  'retail',   '2023-08-10', 1),
(15, 'Lin',     'Zhao',      'lin.zhao@email.com',        'China','business', '2023-09-01', 1);


-- ============================================================
-- TABLE 2: accounts
-- ============================================================
CREATE TABLE accounts (
    account_id    INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL,
    account_type  TEXT NOT NULL,    -- 'checking', 'savings', 'investment'
    balance       DECIMAL(12, 2) NOT NULL,
    currency      TEXT NOT NULL DEFAULT 'USD',
    opened_date   DATE NOT NULL,
    status        TEXT NOT NULL DEFAULT 'active',  -- 'active', 'closed', 'frozen'
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO accounts VALUES
(101, 1,  'checking',   4850.00,   'USD', '2023-01-15', 'active'),
(102, 1,  'savings',    12300.00,  'USD', '2023-01-15', 'active'),
(103, 2,  'checking',   87450.00,  'USD', '2023-02-03', 'active'),
(104, 2,  'investment', 245000.00, 'USD', '2023-02-03', 'active'),
(105, 3,  'checking',   3200.00,   'GBP', '2023-02-20', 'active'),
(106, 3,  'savings',    9100.00,   'GBP', '2023-02-20', 'active'),
(107, 4,  'checking',   6750.00,   'USD', '2023-03-10', 'active'),
(108, 5,  'savings',    21000.00,  'USD', '2023-03-25', 'active'),
(109, 6,  'checking',   55000.00,  'GBP', '2023-04-08', 'active'),
(110, 6,  'investment', 180000.00, 'GBP', '2023-04-08', 'active'),
(111, 7,  'checking',   8900.00,   'AED', '2023-04-15', 'active'),
(112, 8,  'checking',   33000.00,  'USD', '2023-05-01', 'active'),
(113, 8,  'investment', 95000.00,  'USD', '2023-05-01', 'active'),
(114, 9,  'checking',   500.00,    'USD', '2023-05-18', 'closed'),
(115, 10, 'checking',   7200.00,   'USD', '2023-06-02', 'active'),
(116, 11, 'checking',   42000.00,  'AED', '2023-06-20', 'active'),
(117, 12, 'savings',    18500.00,  'EUR', '2023-07-05', 'active'),
(118, 13, 'checking',   0.00,      'USD', '2023-07-22', 'frozen'),
(119, 14, 'checking',   11200.00,  'USD', '2023-08-10', 'active'),
(120, 15, 'investment', 320000.00, 'USD', '2023-09-01', 'active');


-- ============================================================
-- TABLE 3: merchants
-- ============================================================
CREATE TABLE merchants (
    merchant_id   INTEGER PRIMARY KEY,
    merchant_name TEXT NOT NULL,
    category      TEXT NOT NULL,   -- 'food', 'tech', 'travel', 'retail', 'healthcare', 'entertainment'
    country       TEXT NOT NULL
);

INSERT INTO merchants VALUES
(201, 'Amazon',        'retail',        'USA'),
(202, 'Netflix',       'entertainment', 'USA'),
(203, 'Uber',          'travel',        'USA'),
(204, 'Whole Foods',   'food',          'USA'),
(205, 'Apple Store',   'tech',          'USA'),
(206, 'Spotify',       'entertainment', 'Sweden'),
(207, 'Airbnb',        'travel',        'USA'),
(208, 'Starbucks',     'food',          'USA'),
(209, 'Delta Airlines','travel',        'USA'),
(210, 'CVS Pharmacy',  'healthcare',    'USA'),
(211, 'Google Play',   'tech',          'USA'),
(212, 'ASOS',          'retail',        'UK'),
(213, 'Deliveroo',     'food',          'UK'),
(214, 'Emirates',      'travel',        'UAE'),
(215, 'Noon',          'retail',        'UAE');


-- ============================================================
-- TABLE 4: transactions
-- ============================================================
CREATE TABLE transactions (
    transaction_id   INTEGER PRIMARY KEY,
    account_id       INTEGER NOT NULL,
    merchant_id      INTEGER,           -- NULL for direct bank transfers
    amount           DECIMAL(10, 2) NOT NULL,
    transaction_type TEXT NOT NULL,     -- 'deposit', 'withdrawal', 'transfer_out', 'transfer_in'
    description      TEXT,
    transaction_date DATE NOT NULL,
    FOREIGN KEY (account_id)  REFERENCES accounts(account_id),
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
);

INSERT INTO transactions VALUES
-- Aisha (customer 1, accounts 101/102)
(1001, 101, NULL, 3000.00, 'deposit',      'Salary deposit',       '2024-01-01'),
(1002, 101, 204,   -85.50, 'withdrawal',   'Whole Foods',          '2024-01-03'),
(1003, 101, 208,   -12.75, 'withdrawal',   'Starbucks',            '2024-01-05'),
(1004, 101, 203,   -24.00, 'withdrawal',   'Uber ride',            '2024-01-07'),
(1005, 102, NULL, 500.00,  'deposit',      'Savings transfer in',  '2024-01-10'),
(1006, 101, 202,   -15.99, 'withdrawal',   'Netflix subscription', '2024-01-15'),
(1007, 101, NULL, 3000.00, 'deposit',      'Salary deposit',       '2024-02-01'),
(1008, 101, 201,  -240.00, 'withdrawal',   'Amazon order',         '2024-02-08'),
(1009, 101, 205,  -999.00, 'withdrawal',   'Apple Store',          '2024-02-14'),
(1010, 102, NULL, 500.00,  'deposit',      'Savings transfer in',  '2024-02-10'),

-- James (customer 2, accounts 103/104) — business customer
(1011, 103, NULL, 50000.00,'deposit',      'Business revenue',     '2024-01-02'),
(1012, 103, 201,  -1200.00,'withdrawal',   'Office supplies',      '2024-01-10'),
(1013, 103, 205,  -3500.00,'withdrawal',   'MacBook purchase',     '2024-01-18'),
(1014, 104, NULL, 20000.00,'deposit',      'Investment deposit',   '2024-01-20'),
(1015, 103, NULL, 50000.00,'deposit',      'Business revenue',     '2024-02-02'),
(1016, 103, 207,  -2400.00,'withdrawal',   'Airbnb team offsite',  '2024-02-12'),
(1017, 103, 209,  -4800.00,'withdrawal',   'Flight tickets',       '2024-02-20'),

-- Sofia (customer 3, accounts 105/106)
(1018, 105, 213,   -35.00, 'withdrawal',   'Deliveroo',            '2024-01-04'),
(1019, 105, NULL, 2800.00, 'deposit',      'Salary deposit',       '2024-01-01'),
(1020, 106, NULL, 300.00,  'deposit',      'Savings transfer in',  '2024-01-08'),
(1021, 105, 202,   -10.99, 'withdrawal',   'Netflix',              '2024-01-15'),
(1022, 105, 212,  -120.00, 'withdrawal',   'ASOS clothing',        '2024-01-22'),
(1023, 105, NULL, 2800.00, 'deposit',      'Salary deposit',       '2024-02-01'),

-- Marcus (customer 4, account 107)
(1024, 107, NULL, 4200.00, 'deposit',      'Salary deposit',       '2024-01-01'),
(1025, 107, 204,   -95.00, 'withdrawal',   'Grocery shopping',     '2024-01-06'),
(1026, 107, 203,   -31.00, 'withdrawal',   'Uber',                 '2024-01-09'),
(1027, 107, 206,   -10.99, 'withdrawal',   'Spotify',              '2024-01-15'),
(1028, 107, 210,   -45.00, 'withdrawal',   'Pharmacy',             '2024-01-20'),
(1029, 107, NULL, 4200.00, 'deposit',      'Salary deposit',       '2024-02-01'),
(1030, 107, 201,  -189.99, 'withdrawal',   'Amazon order',         '2024-02-05'),
(1031, 107, 203,   -22.00, 'withdrawal',   'Uber',                 '2024-02-11'),

-- Priya (customer 5, account 108)
(1032, 108, NULL, 5500.00, 'deposit',      'Salary deposit',       '2024-01-01'),
(1033, 108, 201,  -320.00, 'withdrawal',   'Amazon electronics',   '2024-01-12'),
(1034, 108, 211,   -29.99, 'withdrawal',   'Google Play',          '2024-01-18'),
(1035, 108, NULL, 5500.00, 'deposit',      'Salary deposit',       '2024-02-01'),
(1036, 108, 207, -1800.00, 'withdrawal',   'Airbnb vacation',      '2024-02-16'),

-- Daniel (customer 8, accounts 112/113) — business customer
(1037, 112, NULL, 30000.00,'deposit',      'Business revenue',     '2024-01-03'),
(1038, 112, 205,  -5200.00,'withdrawal',   'Apple equipment',      '2024-01-15'),
(1039, 113, NULL, 10000.00,'deposit',      'Investment deposit',   '2024-01-25'),
(1040, 112, NULL, 30000.00,'deposit',      'Business revenue',     '2024-02-03'),
(1041, 112, 201,  -2800.00,'withdrawal',   'Office supplies',      '2024-02-10'),
(1042, 112, 209,  -3600.00,'withdrawal',   'Flight tickets',       '2024-02-22'),

-- Sam (customer 14, account 119)
(1043, 119, NULL, 3800.00, 'deposit',      'Salary deposit',       '2024-01-01'),
(1044, 119, 204,   -67.50, 'withdrawal',   'Grocery run',          '2024-01-05'),
(1045, 119, 208,   -18.50, 'withdrawal',   'Starbucks',            '2024-01-08'),
(1046, 119, 202,   -15.99, 'withdrawal',   'Netflix',              '2024-01-15'),
(1047, 119, 203,   -28.00, 'withdrawal',   'Uber',                 '2024-01-19'),
(1048, 119, NULL, 3800.00, 'deposit',      'Salary deposit',       '2024-02-01'),
(1049, 119, 201,  -125.00, 'withdrawal',   'Amazon order',         '2024-02-09'),
(1050, 119, 210,   -55.00, 'withdrawal',   'CVS Pharmacy',         '2024-02-18'),

-- Lin (customer 15, account 120) — large investment account
(1051, 120, NULL,200000.00,'deposit',      'Initial investment',   '2023-09-01'),
(1052, 120, NULL,120000.00,'deposit',      'Additional deposit',   '2024-01-05'),
(1053, 120, NULL, -50000.00,'transfer_out','Portfolio rebalance',  '2024-02-01');
