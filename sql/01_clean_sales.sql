-- Clean raw data: cast types, remove bad rows and duplicates
CREATE OR REPLACE TABLE clean.sales AS
SELECT DISTINCT
  invoice,
  stock_code,
  description,
  SAFE_CAST(quantity AS INT64) AS quantity,
  SAFE_CAST(invoice_date AS TIMESTAMP) AS invoice_ts,
  SAFE_CAST(price AS FLOAT64) AS price,
  CAST(SAFE_CAST(customer_id AS FLOAT64) AS INT64) AS customer_id,
  country,
  SAFE_CAST(quantity AS INT64) * SAFE_CAST(price AS FLOAT64) AS line_total
FROM raw.online_retail
WHERE customer_id IS NOT NULL
  AND customer_id != ''
  AND NOT STARTS_WITH(invoice, 'C')
  AND SAFE_CAST(quantity AS INT64) > 0
  AND SAFE_CAST(price AS FLOAT64) > 0;
