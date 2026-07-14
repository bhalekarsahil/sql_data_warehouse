/*
What is change over time
-> analyze how a measure evolve over time
*/
SELECT
    DATETRUNC(MONTH, order_date) order_date,
    SUM(sales_amount) as TotalSales,
    COUNT(DISTINCT customer_key) as total_customer,
    SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY  DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date) ASC