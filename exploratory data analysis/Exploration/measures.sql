-- calculate the key metric of the business (big numbers)
-- highest level of aggregation | lowest level of details

--Tasks
    --find the total sales
        SELECT
            SUM(sales_amount) totalSales
        FROM gold.fact_sales

    --find how many items are sold
        SELECT 
            SUM(quantity) totalItemSold
        FROM gold.fact_sales
    --find the average selling price
    SELECT
         CAST(AVG(price) AS DECIMAL(10,2)) avg_selling_price
    FROM gold.fact_sales
    --find the total numbers of orders
    SELECT COUNT(DISTINCT order_number) total_orders FROM gold.fact_sales 
    --find the total number of custumers
    SELECT COUNT(customer_key) total_customers FROM gold.dim_customers



--Generate report that shows all key metric f\of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average selling price' AS measure_name,CAST(AVG(price) AS DECIMAL(10,2)) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total numbers of orders' AS measure_name, COUNT(DISTINCT order_number)  AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total numbers of customers' AS measure_name, COUNT(DISTINCT customer_key)  AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total numbers of customers that placed an orders' AS measure_name, COUNT(DISTINCT customer_key)  AS measure_value FROM gold.fact_sales