CREATE VIEW gold.dim_customers -- 1. Fixed the schema/name separator
AS
SELECT
    ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key, -- 2. Fixed: Added alias 'ci.'
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS firstname,
    ci.cst_lastname AS lastname,
    la.cntry AS country,
    ca.bdate AS birthdate,
    CASE
        WHEN ci.cst_gndr != 'n.a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ci.cst_marital_status AS marital_status,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO

WITH
    cus_join
    -- ch eck after joining, does introduce duplcate ID
    AS
    (
        SELECT
            ci.cst_id,
            ci.cst_key,
            ci.cst_firstname,
            ci.cst_lastname,
            ci.cst_marital_status,
            ci.cst_gndr, ci.cst_create_date,
            ca.bdate,
            ca.gen,
            la.cntry
        FROM silver.crm_cust_info ci
            LEFT JOIN silver.erp_cust_az12 ca
            ON ci.cst_key = ca.cid
            LEFT JOIN silver.erp_loc_a101 la
            ON ci.cst_key = la.cid
    )

SELECT
    cst_id,
    COUNT(*)
FROM cus_join
GROUP BY cst_id
HAVING COUNT(*)>1

SELECT
    ci.cst_gndr,
    ca.gen,
    CASE
        WHEN ci.cst_gndr != 'n.a' THEN ci.cst_gndr --CRM IS MASTER HERE
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid
ORDER BY 1, 2