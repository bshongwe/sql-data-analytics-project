#!/bin/bash

echo "Waiting for SQL Server to be ready..."

until /opt/mssql-tools18/bin/sqlcmd -S $SQL_SERVER -U $SQL_USER -P $SQL_PASSWORD -C -Q "SELECT 1" > /dev/null 2>&1; do
    echo "SQL Server is unavailable - sleeping"
    sleep 5
done

echo "SQL Server is ready - executing database setup"

# Execute database initialization
/opt/mssql-tools18/bin/sqlcmd -S $SQL_SERVER -U $SQL_USER -P $SQL_PASSWORD -C -i /app/scripts/00_init_database.sql

echo "Database setup completed"