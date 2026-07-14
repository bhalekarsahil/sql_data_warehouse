/*
peformance analyze
->comparing the current value to a target value
  helps measure success and compare performance
  ex
  currentSales -  avg_sales
  current year - previous year sales
  current sales - lowest sales

*/

/*
    analyze the yearly peformance of products by comparing each product's sales to both its average sales perforamnce and the previous year's sales
*/
WITH yearly_product_sales AS (
SELECT 
    DATETRUNC(YEAR ,f.order_date) order_year,
    p.product_name,
    SUM(f.sales_amount) as current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY  DATETRUNC(YEAR ,f.order_date), p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
    current_sales - AVG(current_sales) OVER(PARTITION BY product_name) diff_avg,
    CASE
        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0  THEN 'Above avg'
        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below avg'
        ELSE 'avg'
    END avg_change,
        CASE
        WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)  > 0  THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)  < 0 THEN 'Decrease'
        ELSE 'avg'
    END avg_change,
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_sales
FROM yearly_product_sales
ORDER BY product_name, order_year