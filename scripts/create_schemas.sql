USE DataWarehouse;
GO

-- ==========================================
-- 1. DROP AND RECREATE BRONZE SCHEMA
-- ==========================================
-- Note: This will fail if the schema already contains tables. 
-- It is designed for fresh script reruns.
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
BEGIN
    DROP SCHEMA bronze;
END;
GO
CREATE SCHEMA bronze;
GO

-- ==========================================
-- 2. DROP AND RECREATE SILVER SCHEMA
-- ==========================================
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    DROP SCHEMA silver;
END;
GO
CREATE SCHEMA silver;
GO

-- ==========================================
-- 3. DROP AND RECREATE GOLD SCHEMA
-- ==========================================
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    DROP SCHEMA gold;
END;
GO
CREATE SCHEMA gold;
GO