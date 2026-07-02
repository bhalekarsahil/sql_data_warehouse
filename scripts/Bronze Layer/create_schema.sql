/* ============================================================================
Bronze Layer Specification:
    Data type: Raw, unprocessed data
    Objective: Traceability & debugging (Never crash on load)
    Obj Type : Table
    Load Method: Full Load
    Naming Convention: snake_case | bronze.<sourcesystem>_
============================================================================ */

-- ============================================================================
-- 1. SOURCE SYSTEM: CRM | ENTITY: CUSTOMER INFO
-- ============================================================================
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info
(
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_data    DATE           -- DEV NOTE: Kept as DATE assuming source extraction guarantees YYYY-MM-DD format.
);
GO

-- ============================================================================
-- 2. SOURCE SYSTEM: CRM | ENTITY: PRODUCT INFO
-- ============================================================================
IF OBJECT_ID('bronze.prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.prd_info;
GO

CREATE TABLE bronze.prd_info
(
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(100),    
    prd_cost     DECIMAL(18, 4),      
    prd_line     VARCHAR(5),         
    prd_start_dt DATE,
    prd_end_dt   DATE
);
GO

-- ============================================================================
-- 3. SOURCE SYSTEM: CRM | ENTITY: SALES DETAILS
-- ============================================================================
IF OBJECT_ID('bronze.sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.sales_details;
GO

CREATE TABLE bronze.sales_details
(
    sls_ord_num  NVARCHAR(20),        
    sls_prd_key  NVARCHAR(50),       
    sls_cust_id  INT,
    sls_order_dt INT,                 -- DEV NOTE: Kept as INT to safely load raw numeric dates (e.g., YYYYMMDD) without failing.
    sls_ship_dt  INT,                 -- DEV NOTE: Kept as INT to safely load raw numeric dates without failing.
    sls_due_dt   INT,                 -- DEV NOTE: Kept as INT to safely load raw numeric dates without failing.
    sls_sales    DECIMAL(18, 2),    
    sls_quantity INT,
    sls_price    DECIMAL(18, 2)    
);
GO

-- ============================================================================
-- 4. SOURCE SYSTEM: ERP (AZ12) | ENTITY: CUSTOMER MASTER
-- ============================================================================
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12
(
    cid   NVARCHAR(50),               
    bdate DATE,
    gen   VARCHAR(15) 
);
GO

-- ============================================================================
-- 5. SOURCE SYSTEM: ERP (A101) | ENTITY: LOCATION MASTER
-- ============================================================================
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101
(
    cid   NVARCHAR(50),               
    cntry NVARCHAR(50)    
);
GO

-- ============================================================================
-- 6. SOURCE SYSTEM: ERP (G1V2) | ENTITY: PRODUCT CATEGORY
-- ============================================================================
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2
(
    id          NVARCHAR(20),         
    cat         NVARCHAR(50),         
    subcat      NVARCHAR(50),        
    maintenance VARCHAR(10)           
);
GO
