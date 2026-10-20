-- RFM segmentation (reference date 2011-12-10 because the data is historical)
CREATE OR REPLACE TABLE mart.customer_rfm AS
WITH base AS (
  SELECT
    customer_id,
    DATE_DIFF(DATE '2011-12-10', MAX(DATE(invoice_ts)), DAY) AS recency,
    COUNT(DISTINCT invoice) AS frequency,
    ROUND(SUM(line_total), 2) AS monetary
  FROM clean.sales
  GROUP BY customer_id
),
scored AS (
  SELECT *,
    NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency)    AS f_score,
    NTILE(5) OVER (ORDER BY monetary)     AS m_score
  FROM base
)
SELECT *,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
    WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
    WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
    ELSE 'Potential'
  END AS segment
FROM scored;
