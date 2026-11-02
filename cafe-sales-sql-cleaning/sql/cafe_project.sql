-- ============================================================
-- Cafe Sales Project (SQLite)  |  Dirty data -> Clean data -> Insights
-- ============================================================

-- ------------------------------------------------------------
-- PART 1: CLEANING
-- ------------------------------------------------------------

-- 1.1 raw_sales = the CSV imported as-is (all TEXT). Never modify it.

-- 1.2 Standardize: '' / 'ERROR' / 'UNKNOWN' -> NULL, and cast types
DROP TABLE IF EXISTS stg_sales;
CREATE TABLE stg_sales AS
SELECT
    "Transaction ID"                                         AS txn_id,
    NULLIF(NULLIF(NULLIF("Item",''),'ERROR'),'UNKNOWN')      AS item,
    CAST(NULLIF(NULLIF(NULLIF("Quantity",''),'ERROR'),'UNKNOWN') AS INTEGER) AS quantity,
    CAST(NULLIF(NULLIF(NULLIF("Price Per Unit",''),'ERROR'),'UNKNOWN') AS REAL) AS price_per_unit,
    CAST(NULLIF(NULLIF(NULLIF("Total Spent",''),'ERROR'),'UNKNOWN') AS REAL)    AS total_spent,
    NULLIF(NULLIF(NULLIF("Payment Method",''),'ERROR'),'UNKNOWN') AS payment_method,
    NULLIF(NULLIF(NULLIF("Location",''),'ERROR'),'UNKNOWN')       AS location,
    NULLIF(NULLIF(NULLIF("Transaction Date",''),'ERROR'),'UNKNOWN') AS txn_date
FROM raw_sales;

-- 1.3 Recover numbers using the rule: total_spent = quantity * price_per_unit
DROP TABLE IF EXISTS clean_sales;
CREATE TABLE clean_sales AS
WITH recovered AS (
    SELECT
        txn_id, item, payment_method, location, txn_date,
        COALESCE(quantity,       CAST(total_spent / price_per_unit AS INTEGER)) AS quantity,
        COALESCE(price_per_unit, total_spent / quantity)                        AS price_per_unit,
        COALESCE(total_spent,    quantity * price_per_unit)                     AS total_spent
    FROM stg_sales
)
SELECT
    txn_id,
    -- 1.4 Recover item from price when the price identifies it uniquely
    --     (3.0 = Cake/Juice and 4.0 = Smoothie/Sandwich are ambiguous -> stay NULL)
    COALESCE(item, CASE price_per_unit
                       WHEN 1.0 THEN 'Cookie'
                       WHEN 1.5 THEN 'Tea'
                       WHEN 2.0 THEN 'Coffee'
                       WHEN 5.0 THEN 'Salad'
                   END)                               AS item,
    quantity,
    price_per_unit,
    total_spent,
    COALESCE(payment_method, 'Unknown')               AS payment_method,
    COALESCE(location, 'Unknown')                     AS location,
    txn_date,
    CAST(strftime('%m', txn_date) AS INTEGER)         AS month_num,
    strftime('%Y-%m', txn_date)                       AS year_month
FROM recovered;

-- 1.5 Final analysis table: only rows with a trustworthy total
DROP VIEW IF EXISTS v_sales;
CREATE VIEW v_sales AS
SELECT * FROM clean_sales WHERE total_spent IS NOT NULL;

-- 1.6 Data-quality report (before vs after)  -> put this table in the README
SELECT 'total_spent' AS col,
       (SELECT COUNT(*) FROM stg_sales   WHERE total_spent IS NULL) AS nulls_before,
       (SELECT COUNT(*) FROM clean_sales WHERE total_spent IS NULL) AS nulls_after
UNION ALL SELECT 'quantity',
       (SELECT COUNT(*) FROM stg_sales   WHERE quantity IS NULL),
       (SELECT COUNT(*) FROM clean_sales WHERE quantity IS NULL)
UNION ALL SELECT 'price_per_unit',
       (SELECT COUNT(*) FROM stg_sales   WHERE price_per_unit IS NULL),
       (SELECT COUNT(*) FROM clean_sales WHERE price_per_unit IS NULL)
UNION ALL SELECT 'item',
       (SELECT COUNT(*) FROM stg_sales   WHERE item IS NULL),
       (SELECT COUNT(*) FROM clean_sales WHERE item IS NULL)
UNION ALL SELECT 'txn_date',
       (SELECT COUNT(*) FROM stg_sales   WHERE txn_date IS NULL),
       (SELECT COUNT(*) FROM clean_sales WHERE txn_date IS NULL);

-- ------------------------------------------------------------
-- PART 2: ANALYSIS (each query = one insight for the CV)
-- ------------------------------------------------------------

-- Q1. Revenue, quantity and share of revenue per item
SELECT item,
       SUM(quantity)                                  AS units_sold,
       ROUND(SUM(total_spent),0)                      AS revenue,
       ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 1) AS revenue_pct
FROM v_sales
WHERE item IS NOT NULL
GROUP BY item
ORDER BY revenue DESC;

-- Q2. Volume vs value: high-volume/low-revenue vs low-volume/high-revenue items
WITH item_stats AS (
    SELECT item, SUM(quantity) AS units, SUM(total_spent) AS revenue
    FROM v_sales WHERE item IS NOT NULL GROUP BY item
)
SELECT item, units, ROUND(revenue,0) AS revenue,
       RANK() OVER (ORDER BY units   DESC) AS volume_rank,
       RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
       RANK() OVER (ORDER BY units DESC) - RANK() OVER (ORDER BY revenue DESC) AS rank_gap
FROM item_stats
ORDER BY rank_gap DESC;

-- Q3. Payment method and location: share of revenue and average basket
SELECT payment_method, COUNT(*) AS orders,
       ROUND(AVG(total_spent),2) AS avg_order_value,
       ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 1) AS revenue_pct
FROM v_sales GROUP BY payment_method ORDER BY revenue_pct DESC;

SELECT location, COUNT(*) AS orders,
       ROUND(AVG(total_spent),2) AS avg_order_value,
       ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 1) AS revenue_pct
FROM v_sales GROUP BY location ORDER BY revenue_pct DESC;

-- Q4. Monthly revenue + month-over-month growth (LAG)
WITH monthly AS (
    SELECT year_month, SUM(total_spent) AS revenue
    FROM v_sales WHERE year_month IS NOT NULL GROUP BY year_month
)
SELECT year_month, ROUND(revenue,0) AS revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year_month))
             / LAG(revenue) OVER (ORDER BY year_month), 1) AS mom_growth_pct
FROM monthly ORDER BY year_month;

-- Q5. Running total of revenue + 3-month moving average
WITH monthly AS (
    SELECT year_month, SUM(total_spent) AS revenue
    FROM v_sales WHERE year_month IS NOT NULL GROUP BY year_month
)
SELECT year_month, ROUND(revenue,0) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY year_month),0)                              AS running_total,
       ROUND(AVG(revenue) OVER (ORDER BY year_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),0) AS moving_avg_3m
FROM monthly ORDER BY year_month;

-- Q6. Best-selling item in every month (RANK inside each month)
WITH m AS (
    SELECT year_month, item, SUM(total_spent) AS revenue
    FROM v_sales WHERE item IS NOT NULL AND year_month IS NOT NULL
    GROUP BY year_month, item
), r AS (
    SELECT *, RANK() OVER (PARTITION BY year_month ORDER BY revenue DESC) AS rnk FROM m
)
SELECT year_month, item, ROUND(revenue,0) AS revenue FROM r WHERE rnk = 1 ORDER BY year_month;

-- Q7. Quantity effect: does buying more units change the item mix?
SELECT quantity, COUNT(*) AS orders, ROUND(SUM(total_spent),0) AS revenue,
       ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 1) AS revenue_pct
FROM v_sales WHERE quantity IS NOT NULL GROUP BY quantity ORDER BY quantity;
