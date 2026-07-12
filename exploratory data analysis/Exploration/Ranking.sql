-- which 5 product generate the highest revenue?
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_id = f.product_key
GROUP BY 
    p.category
ORDER BY 
    total_revenue DESC;


-- what are the most 5 worst-peformining product in terms of sales
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_id = f.product_key
GROUP BY 
    p.category
ORDER BY 
    total_revenue ASC;