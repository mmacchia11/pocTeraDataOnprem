#!/bin/bash

# Generate random credentials for Teradata
ADMIN_USER="Admin"
ADMIN_PASS="root"

APP_USER="app_user"
APP_PASS=$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-12)

# Save credentials to file
cat > /tmp/teradata_credentials.txt << EOF
# Teradata Credentials
ADMIN_USER=${ADMIN_USER}
ADMIN_PASS=${ADMIN_PASS}
APP_USER=${APP_USER}
APP_PASS=${APP_PASS}
DATABASE=sample_db
HOST=localhost
PORT=1025
EOF

# Export as environment variables for SQL scripts
export ADMIN_USER ADMIN_PASS APP_USER APP_PASS

echo "Credentials generated and saved to /tmp/teradata_credentials.txt"