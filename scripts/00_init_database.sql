/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

-- Bronze Layer Tables (Raw Data)
CREATE TABLE bronze.raw_customers(
	id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate nvarchar(50),
	create_date nvarchar(50)
);
GO

CREATE TABLE bronze.raw_products(
	id int,
	product_number nvarchar(50),
	product_name nvarchar(50),
	category_id nvarchar(50),
	category nvarchar(50),
	subcategory nvarchar(50),
	maintenance nvarchar(50),
	cost nvarchar(50),
	product_line nvarchar(50),
	start_date nvarchar(50)
);
GO

CREATE TABLE bronze.raw_sales(
	order_number nvarchar(50),
	product_id nvarchar(50),
	customer_id nvarchar(50),
	order_date nvarchar(50),
	shipping_date nvarchar(50),
	due_date nvarchar(50),
	sales_amount nvarchar(50),
	quantity nvarchar(50),
	price nvarchar(50)
);
GO

-- Silver Layer Tables (Cleaned Data)
CREATE TABLE silver.customers(
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE silver.products(
	product_id int,
	product_number nvarchar(50),
	product_name nvarchar(50),
	category_id nvarchar(50),
	category nvarchar(50),
	subcategory nvarchar(50),
	maintenance nvarchar(50),
	cost int,
	product_line nvarchar(50),
	start_date date
);
GO

CREATE TABLE silver.sales(
	order_number nvarchar(50),
	product_id int,
	customer_id int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int
);
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

-- OPTION 1: Direct load to Gold Pipeline
BULK INSERT gold.dim_customers
FROM 'C:\sql\edl_project\gold.dim_customers.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

BULK INSERT gold.dim_products
FROM 'C:\sql\edl_project\gold.dim_products.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

BULK INSERT gold.fact_sales
FROM 'C:\sql\edl_project\gold.fact_sales.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

-- OPTION 2: Load Silver then transform to Gold Pipeline
BULK INSERT silver.customers
FROM 'C:\sql\edl_project\silver.customers.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

BULK INSERT silver.products
FROM 'C:\sql\edl_project\silver.products.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

BULK INSERT silver.sales
FROM 'C:\sql\edl_project\silver.sales.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

-- OPTION 3: Full Bronze-Silver-Gold Pipeline
BULK INSERT bronze.raw_customers
FROM 'C:\sql\edl_project\bronze.raw_customers.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

BULK INSERT bronze.raw_products
FROM 'C:\sql\edl_project\bronze.raw_products.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

BULK INSERT bronze.raw_sales
FROM 'C:\sql\edl_project\bronze.raw_sales.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

INSERT INTO silver.customers
SELECT id, customer_number, first_name, last_name, country, marital_status, gender,
       TRY_CAST(birthdate AS date), TRY_CAST(create_date AS date)
FROM bronze.raw_customers;
GO

INSERT INTO silver.products
SELECT id, product_number, product_name, category_id, category, subcategory, maintenance,
       TRY_CAST(cost AS int), product_line, TRY_CAST(start_date AS date)
FROM bronze.raw_products;
GO

INSERT INTO silver.sales
SELECT order_number, TRY_CAST(product_id AS int), TRY_CAST(customer_id AS int),
       TRY_CAST(order_date AS date), TRY_CAST(shipping_date AS date), TRY_CAST(due_date AS date),
       TRY_CAST(sales_amount AS int), TRY_CAST(quantity AS tinyint), TRY_CAST(price AS int)
FROM bronze.raw_sales;
GO