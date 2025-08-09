#!/bin/bash
set -euo pipefail

# Secure deployment script that masks secrets
echo "Starting secure database deployment..."

# Validate required secrets are present
if [[ -z "${AZURE_SQL_SERVER:-}" ]] || [[ -z "${AZURE_SQL_DATABASE:-}" ]] || \
   [[ -z "${AZURE_SQL_USERNAME:-}" ]] || [[ -z "${AZURE_SQL_PASSWORD:-}" ]]; then
    echo "ERROR: Required secrets not provided"
    exit 1
fi

# Create temporary secure connection file
TEMP_CONN=$(mktemp)
trap "rm -f $TEMP_CONN" EXIT

cat > "$TEMP_CONN" << EOF
SERVER="$AZURE_SQL_SERVER"
DATABASE="$AZURE_SQL_DATABASE"
USERNAME="$AZURE_SQL_USERNAME"
PASSWORD="$AZURE_SQL_PASSWORD"
EOF

chmod 600 "$TEMP_CONN"

# Source connection variables
source "$TEMP_CONN"

echo "Deploying to server: ${SERVER:0:10}***"
echo "Database: $DATABASE"

# Deploy database schema
echo "Deploying database schema..."
if ! sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" \
    -i scripts/00_init_database.sql -b -m 1; then
    echo "ERROR: Schema deployment failed"
    exit 1
fi

# Deploy analytics scripts
echo "Deploying analytics scripts..."
for script in scripts/0[1-9]*.sql scripts/1[0-3]*.sql; do
    if [[ -f "$script" ]]; then
        echo "Deploying: $(basename "$script")"
        if ! sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" \
            -i "$script" -b -m 1; then
            echo "ERROR: Failed to deploy $script"
            exit 1
        fi
    fi
done

# Run data quality tests
echo "Running data quality tests..."
if ! sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" \
    -i tests/data-quality-tests.sql -b -m 1; then
    echo "ERROR: Data quality tests failed"
    exit 1
fi

echo "Deployment completed successfully"