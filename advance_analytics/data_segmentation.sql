/*
what is data segmentation
->Group the data based on a specific range.
Helps understand the correlation between two measure

[measure] by [measure]
Total product by sales range
total customers by age

*/

-- segments products into cost ranges and count how many products fall into each segment.
WITH customer_spending AS ( 
    SELECT 
        c.customer_key, 
        SUM(f.sales_amount) AS total_spending, 
        MIN(f.order_date) AS first_order, 
        MAX(f.order_date) AS last_order, 
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan 
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_customers c 
      ON f.customer_key = c.customer_key 
    GROUP BY c.customer_key 
) 
SELECT 
    customer_segment, 
    COUNT(customer_key) AS total_customers
FROM ( 
    SELECT 
        customer_key, 
        CASE 
            WHEN lifespan > 12 AND total_spending > 5000 THEN 'VIP' 
            WHEN lifespan > 12 AND total_spending <= 5000 THEN 'Regular' 
            ELSE 'NEW' 
        END AS customer_segment
    FROM customer_spending 
) t 
GROUP BY customer_segment;
