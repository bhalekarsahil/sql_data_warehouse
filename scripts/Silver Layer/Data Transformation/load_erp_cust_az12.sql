SELECT *
FROM bronze.erp_cust_az12

INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
)
SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END
FROM bronze.erp_cust_az12

--check for correct transformation
SELECT
    cid,
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
        cid,
    CASE
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate
FROM bronze.erp_cust_az12
WHERE CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END NOT IN (SELECT DISTINCT cst_key
FROM silver.crm_cust_info)

--check for boundary in birthdate
SELECT DISTINCT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1925-01-01' OR bdate > GETDATE()

--check for category
SELECT DISTINCT gen FROM bronze.erp_cust_az12


--validate silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)