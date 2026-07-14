SELECT 
    order_date, 
    total_sales, 
    SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
    -- Calculate the total sales per month
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_date, 
        SUM(sales_amount) AS total_sales,
        AVG(price) avg_price
    FROM gold.fact_sales 
    WHERE order_date IS NOT NULL 
    GROUP BY DATETRUNC(MONTH, order_date)
) t;
 