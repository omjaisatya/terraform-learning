#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script rendered by Terraform templatefile function
APP_NAME="${app_name}"
ENVIRONMENT="${environment}"
LISTEN_PORT="${listen_port}"
DB_HOST="${database_host}"

echo "Starting deployment for $APP_NAME ($ENVIRONMENT)..."
echo "Listening on port: $LISTEN_PORT"
echo "Connecting to DB at: $DB_HOST"

# Initialize system configuration
mkdir -p /etc/app
cat <<EOF > /etc/app/config.env
APP_NAME=$APP_NAME
APP_ENV=$ENVIRONMENT
PORT=$LISTEN_PORT
DATABASE_URL=postgres://$DB_HOST:5432/production
EOF

echo "Initialization complete."
