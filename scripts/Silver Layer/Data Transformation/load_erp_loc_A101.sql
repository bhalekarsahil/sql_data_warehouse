
INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') as cid, -- handle invalidate value
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE cntry
    END AS cntry -- Normalize and handle missing or blank country codes
FROM bronze.erp_loc_a101

SELECT cntry FROM bronze.erp_loc_a101
WHERE cntry IS NOT NULL

--validation
SELECT *
FROM silver.erp_loc_a101

