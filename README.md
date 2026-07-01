# sql_data_warehouse
A complete data warehousing project featuring data modeling, ETL pipelines, and business analytics using SQL Server

<img width="962" height="572" alt="architecture" src="https://github.com/user-attachments/assets/41fba6d9-d8c9-43b9-8614-99f58bbcf5b0" />

### 🏗️ High-Level Data Architecture

This repository implements a Medallion Architecture data pipeline using **SQL Server** to ingest, process, and serve data.

#### 1. Data Sources
* **CRM & ERP Systems:** Extracted as raw CSV files.
* **Interface:** Automated file ingestion from dedicated folders.

#### 2. Data Warehouse (Medallion Layers)
* **Bronze Layer (Raw Data):** Direct batch load of raw tables via truncate and insert with zero modifications.
* **Silver Layer (Cleaned Data):** Normalized, deduplicated, cleansed, and enriched data sets optimized for staging.
* **Gold Layer (Business Ready):** Aggregated data models organized into Star Schemas and flat tables ready for analytics.

#### 3. Data Consumption
* **BI & Reporting:** Executive dashboards and business intelligence reporting tools.
* **Ad-Hoc Queries:** Direct SQL analysis for quick data exploration.
* **Machine Learning:** Structured pipelines feeding downstream ML models.

