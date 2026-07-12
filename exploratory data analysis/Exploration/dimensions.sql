-- identify the unique values (or categories) in each dimension
-- Recognizing how data might be grouped or segmented which is useful for later analysis

SELECT * FROM gold.dim_products

SELECT DISTINCT -- Check customer from different country
    country
FROM gold.dim_customers

SELECT DISTINCT -- check major low carnality dimension
    product_name,
    category,
    subcategory
FROM gold.dim_products
ORDER BY 2,3,1