/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve all tables grouped by schema
SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('bronze', 'silver', 'gold')
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- Count tables by schema
SELECT 
    TABLE_SCHEMA,
    COUNT(*) as TABLE_COUNT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('bronze', 'silver', 'gold')
GROUP BY TABLE_SCHEMA;

-- Explore Bronze layer structure
SELECT 
    TABLE_NAME,
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- Explore Silver layer structure
SELECT 
    TABLE_NAME,
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- Explore Gold layer structure
SELECT 
    TABLE_NAME,
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
