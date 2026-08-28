/* ============================================================
   RETAIL SALES DATA MODEL — PostgreSQL
   Author: Ibirogba Abiodun Isaac
   Description: A 4-table relational model (Sales as the fact
   table, with Stores, Products, and Customers as dimension
   tables) plus a set of analytical queries built on top of it.
   ============================================================ */


/* ============================================================
   1. SCHEMA — TABLE CREATION
   ============================================================ */

-- STORES TABLE
CREATE TABLE stores (
    store_id INTEGER PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    opened_on DATE
);

-- PRODUCTS TABLE
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);

-- CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    gender VARCHAR(10),
    age_band VARCHAR(20),
    city VARCHAR(100),
    loyalty_tier VARCHAR(50),
    registered_on DATE
);

-- SALES TABLE (fact table — references all three dimension tables)
CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    invoice_no VARCHAR(50) NOT NULL,
    sale_date DATE NOT NULL,
    store_id INTEGER NOT NULL REFERENCES stores(store_id),
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    cost_price NUMERIC(10, 2) NOT NULL CHECK (cost_price >= 0),
    discount_pct NUMERIC(5, 4) DEFAULT 0.00 CHECK (discount_pct >= 0 AND discount_pct <= 1),
    total_amount NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0)
);


/* ============================================================
   2. SALES TABLE — EXPLORATION & REVENUE QUERIES
   ============================================================ */

-- Check the whole sales table
SELECT *
FROM sales;

-- Count total transactions (by unique invoice)
SELECT COUNT(DISTINCT invoice_no) AS total_invoices
FROM sales;

-- Count total transactions (by unique sale record)
SELECT COUNT(DISTINCT sale_id) AS total_sales
FROM sales;

-- Total revenue generated
SELECT SUM(total_amount) AS revenue
FROM sales;

-- Total revenue by each product, highest to lowest
SELECT
    product_id,
    SUM(total_amount) AS revenue
FROM sales
GROUP BY product_id
ORDER BY revenue DESC;

-- Total revenue and quantity for products priced above 1000
SELECT
    product_id,
    COUNT(quantity) AS total_line_items,
    SUM(total_amount) AS revenue
FROM sales
WHERE unit_price > 1000
GROUP BY product_id
ORDER BY revenue DESC;

-- Average sale amount per product
SELECT
    product_id,
    AVG(total_amount) AS avg_sale_amount
FROM sales
GROUP BY product_id;

-- Total revenue generated per year
SELECT
    EXTRACT(YEAR FROM sale_date) AS sales_year,
    SUM(total_amount) AS revenue
FROM sales
GROUP BY sales_year
ORDER BY sales_year;


/* ============================================================
   3. MONTHLY REVENUE BREAKDOWN (2023 – 2025)
   Cleaner version using TO_CHAR for readable month names
   ============================================================ */

-- 2023
SELECT
    TO_CHAR(sale_date, 'Month') AS sales_month,
    SUM(total_amount) AS revenue
FROM sales
WHERE sale_date >= '2023-01-01'
  AND sale_date < '2024-01-01'
GROUP BY EXTRACT(MONTH FROM sale_date), sales_month
ORDER BY EXTRACT(MONTH FROM sale_date) ASC;

-- 2024
SELECT
    TO_CHAR(sale_date, 'Month') AS sales_month,
    SUM(total_amount) AS revenue
FROM sales
WHERE sale_date >= '2024-01-01'
  AND sale_date < '2025-01-01'
GROUP BY EXTRACT(MONTH FROM sale_date), sales_month
ORDER BY EXTRACT(MONTH FROM sale_date) ASC;

-- 2025
SELECT
    TO_CHAR(sale_date, 'Month') AS sales_month,
    SUM(total_amount) AS revenue
FROM sales
WHERE sale_date >= '2025-01-01'
  AND sale_date < '2026-01-01'
GROUP BY EXTRACT(MONTH FROM sale_date), sales_month
ORDER BY EXTRACT(MONTH FROM sale_date) ASC;


/* ============================================================
   4. CUSTOMERS TABLE — SEGMENTED REVENUE
   ============================================================ */

SELECT *
FROM customers;

-- Revenue by loyalty tier
SELECT
    c.loyalty_tier,
    SUM(s.total_amount) AS total_revenue
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.loyalty_tier
ORDER BY total_revenue DESC;

-- Revenue by age band
SELECT
    c.age_band,
    SUM(s.total_amount) AS total_revenue
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.age_band
ORDER BY total_revenue DESC;

-- Revenue by gender
SELECT
    c.gender,
    SUM(s.total_amount) AS total_revenue
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.gender
ORDER BY total_revenue DESC;


/* ============================================================
   5. PRODUCTS TABLE — REVENUE BY PRODUCT & CATEGORY
   ============================================================ */

SELECT *
FROM products;

-- Revenue by product name
SELECT
    p.product_name,
    SUM(s.total_amount) AS total_revenue
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Revenue by category
SELECT
    p.category,
    SUM(s.total_amount) AS total_revenue
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


/* ============================================================
   6. STORES TABLE — REVENUE BY LOCATION
   ============================================================ */

SELECT *
FROM stores;

-- Revenue by store
SELECT
    st.store_name,
    SUM(s.total_amount) AS total_revenue
FROM stores st
JOIN sales s ON st.store_id = s.store_id
GROUP BY st.store_name
ORDER BY total_revenue DESC;


/* ============================================================
   7. FULL MODEL — MULTI-TABLE JOIN
   Combines all four tables into one analytical view
   ============================================================ */

SELECT
    st.city,
    st.store_name,
    p.product_name,
    p.category,
    c.age_band,
    c.loyalty_tier,
    SUM(s.total_amount) AS revenue
FROM sales s
JOIN products p  ON s.product_id  = p.product_id
JOIN customers c ON s.customer_id = c.customer_id
JOIN stores st   ON s.store_id    = st.store_id
GROUP BY
    st.city,
    st.store_name,
    p.product_name,
    p.category,
    c.age_band,
    c.loyalty_tier
ORDER BY revenue DESC;
