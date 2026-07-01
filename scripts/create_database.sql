-- Drop the database if it already exists to start fresh
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DataWarehouse')
BEGIN
    -- Force close any open connections to prevent "database is in use" errors
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END

-- Create the new Database
CREATE DATABASE DataWarehouse;
GO

-- Switch to the new Database
USE DataWarehouse;
GO