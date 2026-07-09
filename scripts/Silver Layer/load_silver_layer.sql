CREATE OR ALTER PROCEDURE silver.load_silver_layer AS
BEGIN
    SET NOCOUNT ON;

    -- Time Tracking Variables
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @load_start DATETIME, @load_end DATETIME;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET @start_time = GETDATE();

        PRINT '==================================================';
        PRINT 'Starting Silver Layer Ingestion Pipeline...';
        PRINT 'Start Time: ' + CAST(@start_time AS NVARCHAR);
        PRINT '==================================================';

        -- =========================================================================
        -- 1. LOAD TABLE: silver.crm_cust_info
        -- =========================================================================
        PRINT '>> Loading silver.crm_cust_info...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE silver.crm_cust_info;
        
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            NULLIF(TRIM(cst_firstname), '') AS cst_firstname,
            NULLIF(TRIM(cst_lastname), '') AS cst_lastname,
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a' 
            END AS cst_marital_status,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t 
        WHERE flag_last = 1;

        SET @load_end = GETDATE();
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '-----------------------------------------------------------------------------------------';

        -- =========================================================================
        -- 2. LOAD TABLE: silver.crm_prd_info
        -- =========================================================================
        PRINT '>> Loading silver.crm_prd_info...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE silver.crm_prd_info;
        
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
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, 
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            NULLIF(TRIM(prd_nm), '') AS prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line)) 
                WHEN 'M' THEN 'Mountain'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                WHEN 'R' THEN 'Road'
                ELSE 'n/a'
            END AS prd_line,
            prd_start_dt,
            DATEADD(DAY ,-1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt )) AS prd_end_dt
        FROM bronze.crm_prd_info;

        SET @load_end = GETDATE();
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '-----------------------------------------------------------------------------------------';

        -- =========================================================================
        -- 3. LOAD TABLE: silver.crm_sales_details
        -- =========================================================================
        PRINT '>> Loading silver.crm_sales_details...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE silver.crm_sales_details;

        WITH cleaned_price AS (
            SELECT 
                sls_ord_num,
                sls_prd_key,
                sls_cust_id,
                CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL 
                     ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
                CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL 
                     ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
                CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL 
                     ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
                
                sls_quantity,
                sls_sales AS original_sales,
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
                CASE 
                    WHEN original_sales IS NULL OR original_sales != sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                    ELSE original_sales
                END AS sls_sales,
                sls_quantity,
                sls_price
            FROM cleaned_price
        )
        INSERT INTO silver.crm_sales_details (
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
        FROM final_calculation;

        SET @load_end = GETDATE();
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '-----------------------------------------------------------------------------------------';

        -- =========================================================================
        -- 4. LOAD TABLE: silver.erp_cust_az12
        -- =========================================================================
        PRINT '>> Loading silver.erp_cust_az12...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE silver.erp_cust_az12;
        
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
                WHEN bdate > GETDATE() OR bdate < '1925-01-01' THEN NULL
                ELSE bdate
            END AS bdate,
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS gen
        FROM bronze.erp_cust_az12;

        SET @load_end = GETDATE();
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '-----------------------------------------------------------------------------------------';

        -- =========================================================================
        -- 5. LOAD TABLE: silver.erp_loc_a101
        -- =========================================================================
        PRINT '>> Loading silver.erp_loc_a101...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE silver.erp_loc_a101;
        
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid, 
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = 'FR' THEN 'France'
                WHEN TRIM(cntry) = 'UK' THEN 'United Kingdom'
                WHEN TRIM(cntry) = 'CA' THEN 'Canada'
                WHEN NULLIF(TRIM(cntry), '') IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry 
        FROM bronze.erp_loc_a101;

        SET @load_end = GETDATE();
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '-----------------------------------------------------------------------------------------';

        -- =========================================================================
        -- 6. LOAD TABLE: silver.erp_px_cat_g1v2
        -- =========================================================================
        PRINT '>> Loading silver.erp_px_cat_g1v2...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        
        INSERT INTO silver.erp_px_cat_g1v2(
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            NULLIF(TRIM(cat), '') AS cat,         
            NULLIF(TRIM(subcat), '') AS subcat,
            NULLIF(TRIM(maintenance), '') AS maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @load_end = GETDATE();
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '-----------------------------------------------------------------------------------------';

        -- If everything finishes cleanly, finalize the changes in the database
        COMMIT TRANSACTION;

        SET @end_time = GETDATE();
        PRINT '==================================================';
        PRINT 'TRANSACTION SUCCESSFUL!';
        PRINT 'TOTAL PIPELINE DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '==================================================';

    END TRY
    BEGIN CATCH
        -- If any step fails, undo all changes to prevent partial loads
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
        PRINT 'CRITICAL ERROR ENCOUNTERED! Rolling back pipeline updates...';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
    END CATCH
END;
GO

EXEC silver.load_silver_layer
