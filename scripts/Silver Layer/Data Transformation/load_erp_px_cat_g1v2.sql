TRUNCATE TABLE silver.erp_px_cat_g1v2
INSERT INTO silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2

--check integrity
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info)

--check low cardinality values
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2

--check for id duplicates
SELECT 
    id,
    COUNT(*)
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1

--check for unwanted space
SELECT
    *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR TRIM(subcat)!=subcat or maintenance != TRIM(maintenance)

--Validate
SELECT * FROM silver.erp_px_cat_g1v2