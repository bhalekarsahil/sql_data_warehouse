WITH 
cleaned_price AS (
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        -- Date transformations: invalid data
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL 
             ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL 
             ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL 
             ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
        
        sls_quantity,
        sls_sales AS original_sales,
        
        -- Step 1: Fix price first. If it's missing/invalid, derive it from sales.
        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0 
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price 
        END AS sls_price
    FROM bronze.crm_sales_details
),
final_calculation AS (
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    -- Step 2: Now we can safely use the cleaned sls_price to recalculate sales
    CASE 
        WHEN original_sales IS NULL OR original_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE original_sales
    END AS sls_sales,
    sls_quantity,
    sls_price
FROM cleaned_price
)

INSERT INTO silver.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM final_calculation

--check integrity of column 
SELECT
    sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

--check invalid length yyyyddmm - 8 numbers
SELECT 
    NULLIF(sls_order_dt, 0)
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) != 8

--CHECK FOR OUTLIERS BY VALIDATING BOUNDARIES
SELECT 
    NULLIF(sls_order_dt, 0)
FROM bronze.crm_sales_details
WHERE sls_order_dt < 20000101
OR sls_order_dt < 20500101

--check is invalid date order
SELECT * FROM (
SELECT
    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
        CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt
FROM bronze.crm_sales_details
)t WHERE sls_order_dt >= sls_ship_dt OR sls_ship_dt >=  sls_due_dt

--check for -ve crm_sales_details
SELECT 
    CASE 
        WHEN sls_sales < 0 THEN 0
        ELSE sls_sales
    END
FROM bronze.crm_sales_details
WHERE sls_sales < 0

--=============================================================================================================
--sls_sales = sls_quantity * sls_price ❌ totally wrong, not working contain null, negatives, wrong math
--solution
--1. Data issue will be fixed direct source system
--2. Data issue will be fixed in data warehouse: 
--rules(by expert):
-- i. if sales is negative, zero or null, derive it using Quantity and price  
--ii. if price is zero or null, calculate it using sales and Quantity 
--iii.if price is negative, convert it to a positive value
SELECT
    CASE WHEN sls_price IS NULL OR sls_price <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price<=0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_price <= 0
OR sls_quantity <=0
ORDER BY sls_sales
--========================================================================================
