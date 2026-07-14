/*
what is part-to-whole
-> analyze how an indiviual part is performing compared to the overall allowing us to understand which category has the greatest impact on the business

([measure] / total[measure]) * 100 by [dimension]
*/

-- which cateogories contribute the most to overall sales?
WITH
    category_sales
    AS
    (
        SELECT
            p.category,
            SUM(f.sales_amount) totalSales
        FROM gold.fact_sales f
            LEFT JOIN gold.dim_products p
            ON p.product_key = f.product_key
        GROUP BY category
        )
        SELECT
        category,
        totalSales,
        SUM(totalSales) OVER() overall_sales,
        ROUND((CAST(totalSales AS float) / SUM(totalSales) OVER()) * 100, 2) perc
    FROM category_sales
    ORDER BY totalSales DESC