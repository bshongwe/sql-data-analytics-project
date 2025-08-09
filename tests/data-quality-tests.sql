/*
===============================================================================
Data Quality Tests
===============================================================================
Purpose: Validate data integrity across Bronze-Silver-Gold layers
===============================================================================
*/

-- Test 1: Check if all tables exist
SELECT 
    'Table Existence Check' AS test_name,
    CASE 
        WHEN COUNT(*) = 9 THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('bronze', 'silver', 'gold');

-- Test 2: Check for null values in key columns
SELECT 
    'Null Check - Gold Layer' AS test_name,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM (
    SELECT customer_key FROM gold.dim_customers WHERE customer_key IS NULL
    UNION ALL
    SELECT product_key FROM gold.dim_products WHERE product_key IS NULL
    UNION ALL
    SELECT customer_key FROM gold.fact_sales WHERE customer_key IS NULL
) null_checks;

-- Test 3: Data consistency between layers
SELECT 
    'Data Consistency Check' AS test_name,
    CASE 
        WHEN bronze_count = silver_count AND silver_count = gold_count THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM (
    SELECT 
        (SELECT COUNT(*) FROM bronze.raw_customers) AS bronze_count,
        (SELECT COUNT(*) FROM silver.customers) AS silver_count,
        (SELECT COUNT(*) FROM gold.dim_customers) AS gold_count
) counts;

-- Test 4: Revenue calculation validation
SELECT 
    'Revenue Calculation Check' AS test_name,
    CASE 
        WHEN ABS(calculated_revenue - sum_revenue) < 0.01 THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM (
    SELECT 
        SUM(quantity * price) AS calculated_revenue,
        SUM(sales_amount) AS sum_revenue
    FROM gold.fact_sales
) revenue_check;