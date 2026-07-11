-- Ensure you are using the correct database context
-- USE YourWarehouseDatabaseName; 
-- GO

-- 1. Drop the view if it already exists to allow clean re-creation
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

-- 2. Create the Fact View
CREATE VIEW gold.fact_sales
AS
    SELECT
        -- Dimension Keys
        sd.sls_ord_num AS order_number,
        pr.product_unique_key AS product_key,
        cu.customer_key,

        -- Dates
        sd.sls_order_dt AS order_date,
        sd.sls_ship_dt AS shipping_date,
        sd.sls_due_dt AS due_date,

        -- Measures
        sd.sls_sales AS sales_amount,
        sd.sls_quantity AS quantity,
        sd.sls_price AS price
    FROM silver.crm_sales_details sd
        LEFT JOIN gold.dim_products pr
        ON sd.sls_prd_key = pr.product_key -- Joins natural key to natural key
        LEFT JOIN gold.dim_customers cu
        ON sd.sls_cust_id = cu.customer_id;   -- Joins natural key to natural key
GO

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_unique_key
 
SELECT * FROM gold.fact_sales