--identify the earliest and latest dates (boundaries)
SELECT * FROM gold.fact_sales
--Find the date of the first and last order

SELECT
    *,
    DATEDIFF(YEAR, first_order_date, last_order_date) order_range_month 
FROM (
    SELECT 
        MIN(order_date) first_order_date,
        MAX(order_date) last_order_date
    FROM gold.fact_sales
)t

-- find youngest and oldes customer
SELECT 
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) as oldest_age,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) as youngest_age
FROM gold.dim_customers

