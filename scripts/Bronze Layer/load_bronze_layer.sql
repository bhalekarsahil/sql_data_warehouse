-- ============================================================================
-- Create Stored Procedure: bronze.load_bronze_tables
-- Description: Truncates and reloads the Bronze layer tables using BULK INSERT.
--              Includes per-table transactions and standardized runtime metadata tracking.
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
        PRINT 'Starting Bronze Layer Ingestion Pipeline...';
        PRINT 'Start Time: ' + CAST(@start_time AS NVARCHAR);
        PRINT '==================================================';

        -- =========================================================================
        -- 1. LOAD TABLE: bronze.crm_cust_info
        -- =========================================================================
        PRINT '>> Loading bronze.crm_cust_info...';
        BEGIN TRANSACTION;
        BEGIN TRY
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
            
            COMMIT TRANSACTION;
            SET @load_end = GETDATE();
            PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
            PRINT '-----------------------------------------------------------------------------------------';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW; -- Passes error up to the main catch block
        END CATCH


        -- =========================================================================
        -- 2. LOAD TABLE: bronze.crm_prd_info
        -- =========================================================================
        PRINT '>> Loading bronze.crm_prd_info...';
        BEGIN TRANSACTION;
        BEGIN TRY
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
            
            COMMIT TRANSACTION;
            SET @load_end = GETDATE();
            PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
            PRINT '-----------------------------------------------------------------------------------------';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH


        -- =========================================================================
        -- 3. LOAD TABLE: bronze.crm_sales_details
        -- =========================================================================
        PRINT '>> Loading bronze.crm_sales_details...';
        BEGIN TRANSACTION;
        BEGIN TRY
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
            
            COMMIT TRANSACTION;
            SET @load_end = GETDATE();
            PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
            PRINT '-----------------------------------------------------------------------------------------';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH


        -- =========================================================================
        -- 4. LOAD TABLE: bronze.erp_cust_az12
        -- =========================================================================
        PRINT '>> Loading bronze.erp_cust_az12...';
        BEGIN TRANSACTION;
        BEGIN TRY
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
            
            COMMIT TRANSACTION;
            SET @load_end = GETDATE();
            PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
            PRINT '-----------------------------------------------------------------------------------------';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH


        -- =========================================================================
        -- 5. LOAD TABLE: bronze.erp_loc_a101
        -- =========================================================================
        PRINT '>> Loading bronze.erp_loc_a101...';
        BEGIN TRANSACTION;
        BEGIN TRY
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
            
            COMMIT TRANSACTION;
            SET @load_end = GETDATE();
            PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
            PRINT '-----------------------------------------------------------------------------------------';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH


        -- =========================================================================
        -- 6. LOAD TABLE: bronze.erp_px_cat_g1v2
        -- =========================================================================
        PRINT '>> Loading bronze.erp_px_cat_g1v2...';
        BEGIN TRANSACTION;
        BEGIN TRY
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
            
            COMMIT TRANSACTION;
            SET @load_end = GETDATE(); 
            PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @load_start, @load_end) AS NVARCHAR) + ' seconds';
            PRINT '-----------------------------------------------------------------------------------------';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH


        -- Final Summary Execution Log
        SET @end_time = GETDATE();
        PRINT '==================================================';
        PRINT 'SUCCESS: All Bronze tables loaded successfully!';
        PRINT 'TOTAL PIPELINE DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
        PRINT '==================================================';

    END TRY
    BEGIN CATCH
        -- Global error capture section
        PRINT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
        PRINT 'CRITICAL ERROR ENCOUNTERED! Process Aborted.';
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line:    ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
    END CATCH
END;
GO

EXEC bronze.load_bronze_tables