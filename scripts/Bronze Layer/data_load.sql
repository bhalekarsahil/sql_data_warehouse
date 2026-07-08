-- ============================================================================
-- Create Stored Procedure: bronze.load_bronze_tables
-- Description: Truncates and reloads the Bronze layer tables using BULK INSERT.
--              Includes comprehensive error handling and performance tracking.
-- ============================================================================

CREATE OR ALTER PROCEDURE bronze.load_bronze_tables
AS
BEGIN
    -- Protects performance by stopping row-count notifications
    SET NOCOUNT ON; 

    -- Declare variables for performance auditing
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @load_start DATETIME, @load_end DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

        PRINT '==================================================';
        PRINT '   STARTING BRONZE LAYER LOADING PROCESS          ';
        PRINT '==================================================';
        PRINT 'Timestamp: ' + CAST(GETDATE() AS NVARCHAR);
        PRINT '--------------------------------------------------';

        -- ====================================================================
        -- 1. Loading Table: bronze.crm_cust_info
        -- ====================================================================
        PRINT '>> Loading: bronze.crm_cust_info...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE bronze.crm_cust_info;
        BULK INSERT bronze.crm_cust_info
        FROM 'S:\SQL Project\sqlProjects\sql_data_warehouse\datasets\source_crm\cust_info.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        
        SET @load_end = GETDATE();
        PRINT '   - Status: Success';
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------';


        -- ====================================================================
        -- 2. Loading Table: bronze.crm_prd_info (UPDATED)
        -- ====================================================================
        PRINT '>> Loading: bronze.crm_prd_info...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM 'S:\SQL Project\sqlProjects\sql_data_warehouse\datasets\source_crm\prd_info.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        
        SET @load_end = GETDATE();
        PRINT '   - Status: Success';
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------';


        -- ====================================================================
        -- 3. Loading Table: bronze.crm_sales_details (UPDATED)
        -- ====================================================================
        PRINT '>> Loading: bronze.crm_sales_details...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'S:\SQL Project\sqlProjects\sql_data_warehouse\datasets\source_crm\sales_details.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        
        SET @load_end = GETDATE();
        PRINT '   - Status: Success';
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------';


        -- ====================================================================
        -- 4. Loading Table: bronze.erp_cust_az12
        -- ====================================================================
        PRINT '>> Loading: bronze.erp_cust_az12...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM 'S:\SQL Project\sqlProjects\sql_data_warehouse\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FORMAT = 'CSV', 
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n', 
            TABLOCK
        );
        
        SET @load_end = GETDATE();
        PRINT '   - Status: Success';
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------';


        -- ====================================================================
        -- 5. Loading Table: bronze.erp_loc_a101
        -- ====================================================================
        PRINT '>> Loading: bronze.erp_loc_a101...';
        SET @load_start = GETDATE();
        
        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'S:\SQL Project\sqlProjects\sql_data_warehouse\datasets\source_erp\LOC_A101.csv'
        WITH (
            FORMAT = 'CSV', 
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n', 
            TABLOCK
        );
        
        SET @load_end = GETDATE();
        PRINT '   - Status: Success';
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------';


        -- ====================================================================
        -- 6. Loading Table: bronze.erp_px_cat_g1v2
        -- ====================================================================
        PRINT '>> Loading: bronze.erp_px_cat_g1v2...';
        SET @load_start = GETDATE(); 
        
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'S:\SQL Project\sqlProjects\sql_data_warehouse\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FORMAT = 'CSV', 
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n', 
            TABLOCK
        );
        
        SET @load_end = GETDATE(); 
        PRINT '   - Status: Success';
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------';


        -- ====================================================================
        -- Pipeline Summary Execution Details
        -- ====================================================================
        SET @end_time = GETDATE();
        PRINT '==================================================';
        PRINT ' SUCCESS: All Bronze tables loaded successfully!';
        PRINT '==================================================';
        PRINT 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
        PRINT '==================================================';

    END TRY
    BEGIN CATCH
        -- Safety catch zone triggered automatically on failure
        PRINT '==================================================';
        PRINT ' ❌ ERROR DETECTED! Loading process aborted.';
        PRINT '==================================================';
        
        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
            
        PRINT '==================================================';
    END CATCH
END;
GO

-- To run the finalized execution process:
EXEC bronze.load_bronze_tables;

SELECT * FROM bronze.crm_cust_info