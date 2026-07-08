SELECT * FROM silver.crm_prd_info;

--Load data in prd_info
TRUNCATE TABLE silver.crm_prd_info
INSERT INTO silver.crm_prd_info(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') cat_id, -- extract category key from product key and make as per cateogry table
    SUBSTRING(prd_key, 7, LEN(prd_key)) prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) prd_cost,
    CASE UPPER(TRIM(prd_line)) 
        WHEN 'M' THEN 'Mountain'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        WHEN 'R' THEN 'Road'
        ELSE 'n/a'
    END prd_line,
    prd_start_dt,
    DATEADD(DAY ,-1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt )) AS prd_end_dt
FROM bronze.crm_prd_info


--check for duplicate product key,id
SELECT 
    prd_key,
    count(*)
FROM bronze.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1 OR prd_key IS NULL;

--check unwanted spaced
SELECT
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--check for NULLS or Negative Numbers
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL

--check product prd_line
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

--===========================================================
--check for invalid date orders
SELECT prd_key,
prd_start_dt,
prd_end_dt,
prd_cost
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt
-- O/P
--prd_key	        prd_end_date	prd_start_date	price
--AC-HE-HL-U509-R	28-12-2007	    01-07-2011	      12
--AC-HE-HL-U509-R	27-12-2008	    01-07-2012	      14

/*
Rule1: start_date < end_date
Rule2: history should be younger than next record
        end date = start date of 'NEXT' Record - 1
Rule3: each start record has date must NULL is not allowed
*/
--soln:

SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    DATEADD(DAY ,-1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt )) AS prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')
--===========================================================
SELECT * FROM silver.crm_prd_info

--=================================================
--=================================================
----quality check of silver.prd_info
--check for duplicate product key,id
SELECT 
    prd_id,
    count(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--check unwanted spaced
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--check for NULLS or Negative Numbers
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL

--check product prd_line
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--===========================================================
--check for invalid date orders
SELECT prd_key,
prd_start_dt,
prd_end_dt,
prd_cost
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt