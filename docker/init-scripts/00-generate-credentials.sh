#!/bin/bash

# Generate random credentials for ClickHouse Data Warehouse
ADMIN_USER="admin"
ADMIN_PASS="root"

APP_USER="app_user"
APP_PASS=$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-12)

# Save credentials to file
cat > /tmp/credentials/clickhouse_credentials.txt << EOF
# ClickHouse Data Warehouse Credentials
ADMIN_USER=${ADMIN_USER}
ADMIN_PASS=${ADMIN_PASS}
APP_USER=${APP_USER}
APP_PASS=${APP_PASS}
DATABASE=sample_dw
HOST=localhost
HTTP_PORT=1025
TCP_PORT=1026
EOF

# Export as environment variables for SQL scripts
export ADMIN_USER ADMIN_PASS APP_USER APP_PASS

echo "ClickHouse credentials generated and saved to /tmp/credentials/clickhouse_credentials.txt"