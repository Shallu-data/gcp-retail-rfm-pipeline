-- Fact table: one row per product line on an invoice
CREATE OR REPLACE TABLE mart.fact_sales AS
SELECT
  invoice,
  stock_code,
  customer_id,
  invoice_ts,
  DATE(invoice_ts) AS invoice_date,
  quantity,
  price,
  line_total
FROM clean.sales;

-- Customer dimension: one row per customer
CREATE OR REPLACE TABLE mart.dim_customer AS
SELECT
  customer_id,
  ARRAY_AGG(country ORDER BY invoice_ts DESC LIMIT 1)[OFFSET(0)] AS country,
  MIN(DATE(invoice_ts)) AS first_purchase,
  MAX(DATE(invoice_ts)) AS last_purchase,
  COUNT(DISTINCT invoice) AS orders,
  ROUND(SUM(line_total), 2) AS revenue
FROM clean.sales
GROUP BY customer_id;

-- Product dimension: one row per stock code
CREATE OR REPLACE TABLE mart.dim_product AS
SELECT
  stock_code,
  ARRAY_AGG(description IGNORE NULLS ORDER BY invoice_ts DESC LIMIT 1)[OFFSET(0)] AS description,
  ROUND(AVG(price), 2) AS avg_price
FROM clean.sales
GROUP BY stock_code;

-- Product sales: joined table for the dashboard
CREATE OR REPLACE TABLE mart.product_sales AS
SELECT
  f.stock_code,
  p.description,
  SUM(f.quantity) AS units_sold,
  ROUND(SUM(f.line_total), 2) AS revenue
FROM mart.fact_sales f
JOIN mart.dim_product p USING (stock_code)
GROUP BY f.stock_code, p.description;
