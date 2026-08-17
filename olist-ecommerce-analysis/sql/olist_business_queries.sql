USE Olist_database;


-- Top Revenue Categories
SELECT TOP 10
    T2.product_category_name,
    SUM(T1.price + T1.freight_value) AS Total_Revenue,
    COUNT(T1.order_id) AS Total_Orders
FROM
    order_items T1
INNER JOIN
    products T2 ON T1.product_id = T2.product_id
INNER JOIN
    category_name_eg T3 ON T2.product_category_name = T3.english_name
GROUP BY
    T2.product_category_name
ORDER BY
    Total_Revenue DESC;
-- Analysis of avg demand value
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS Total_Orders,
    CAST(AVG(payment_value) AS DECIMAL(10, 2)) AS Average_Order_Value_AOV,
    CAST(AVG(payment_installments) AS DECIMAL(10, 2)) AS Avg_Installments
FROM
    payments
GROUP BY
    payment_type
ORDER BY
    Average_Order_Value_AOV DESC;

    -- Delay Hotspots
SELECT TOP 10
    T2.customer_state,
    COUNT(T1.order_id) AS Total_Late_Orders,
    CAST(AVG(DATEDIFF(day, T1.order_estimated_delivery_date, T1.order_delivered_customer_date)) AS DECIMAL(10, 2)) AS Avg_Delivery_Delay_Days
FROM
    orders T1
INNER JOIN
    customers T2 ON T1.customer_id = T2.customer_id
WHERE
    T1.order_status = 'delivered'
    AND T1.order_delivered_customer_date > T1.order_estimated_delivery_date
GROUP BY
    T2.customer_state
HAVING
    COUNT(T1.order_id) > 100 -- نحسب فقط الولايات ذات حجم عينة كاف
ORDER BY
    Avg_Delivery_Delay_Days DESC;

-- Seller Performance Hubs
SELECT TOP 10
    T2.seller_state,
    COUNT(T1.order_id) AS Total_Orders_Shipped,
    CAST(AVG(DATEDIFF(day, T1.order_approved_at, T1.order_delivered_carrier_date)) AS DECIMAL(10, 2)) AS Avg_Seller_Prep_Time
FROM
    orders T1
INNER JOIN
    order_items T3 ON T1.order_id = T3.order_id
INNER JOIN
    sellers T2 ON T3.seller_id = T2.seller_id
WHERE
    T1.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    T2.seller_state
ORDER BY
    Avg_Seller_Prep_Time DESC;

-- Customer Satisfaction - NPS
SELECT TOP 10
    T3.english_name,
    COUNT(T1.order_id) AS Total_Reviews,
    CAST(SUM(CASE WHEN T2.review_score = 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(T2.review_score) AS DECIMAL(10, 2)) AS Promoter_Percentage
FROM
    order_items T1
INNER JOIN
    reviews T2 ON T1.order_id = T2.order_id
INNER JOIN
    products T4 ON T1.product_id = T4.product_id
INNER JOIN
    category_name_eg T3 ON T4.product_category_name = T3.english_name
GROUP BY
    T3.english_name
HAVING
    COUNT(T2.review_score) > 50 -- حجم عينة مناسب
ORDER BY
    Promoter_Percentage DESC;

-- Bad Review Response Time
SELECT
    T1.review_score,
    COUNT(T1.order_id) AS Total_Reviews,
    CAST(AVG(DATEDIFF(hour, T1.review_creation_date, T1.review_answer_timestamp)) AS DECIMAL(10, 2)) AS Avg_Response_Time_Hours
FROM
    reviews T1
WHERE
    T1.review_score IN (1, 2, 5) -- مقارنة الأداء بين النقاد والمروجين
    AND T1.review_answer_timestamp IS NOT NULL
GROUP BY
    T1.review_score
ORDER BY
    T1.review_score DESC;

-- Delay vs. Score
WITH OrderPerformance AS (
    SELECT
        T1.order_id,
        T2.review_score,
        CASE
            WHEN T1.order_delivered_customer_date > T1.order_estimated_delivery_date THEN 'Delayed'
            WHEN T1.order_delivered_customer_date <= T1.order_estimated_delivery_date THEN 'On Time/Early'
            ELSE 'Unknown'
        END AS Delivery_SLA_Status
    FROM
        orders T1
    INNER JOIN
        reviews T2 ON T1.order_id = T2.order_id
    WHERE
        T1.order_status = 'delivered'
)
SELECT
    Delivery_SLA_Status,
    COUNT(*) AS Total_Reviews,
    CAST(AVG(CAST(review_score AS FLOAT)) AS DECIMAL(10, 2)) AS Average_Review_Score
FROM
    OrderPerformance
GROUP BY
    Delivery_SLA_Status;

