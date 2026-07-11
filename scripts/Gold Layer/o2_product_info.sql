CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER(ORDER BY pd.prd_start_dt, pd.prd_key) product_unique_key ,
    pd.prd_id AS product_id,
    pd.prd_key as product_key,
    pd.prd_nm as product_name, 
    pc.cat AS category,
    pc.subcat AS subcategory,
    pd.prd_cost AS cost,
    pd.prd_line AS product_line,
    pc.maintenance,
    pd.cat_id AS category_id,
    pd.prd_start_dt AS start_date,
    pd.prd_end_dt AS end_date
FROM silver.crm_prd_info pd
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pd.cat_id = pc.id
WHERE pd.prd_end_dt IS NULL