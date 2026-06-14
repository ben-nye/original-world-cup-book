#!/bin/bash
set -euo pipefail

# Load environment variables from .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Step 1: Create the app user and database, lock down public access
echo "Creating user and database..."
PGPASSWORD=${POSTGRES_PASSWORD} psql -h ${DB_HOST} -p ${DB_PORT} -U postgres << SQL
-- Create app user with password
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';

-- Create database owned by app user
CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};

-- Revoke default public access to the database
REVOKE ALL ON DATABASE ${DB_NAME} FROM PUBLIC;

-- Allow app user to connect
GRANT CONNECT ON DATABASE ${DB_NAME} TO ${DB_USER};
SQL

# Step 2: Lock down the public schema
echo "Revoking public schema access..."
PGPASSWORD=${POSTGRES_PASSWORD} psql -h ${DB_HOST} -p ${DB_PORT} -U postgres -d ${DB_NAME} << SQL
-- Remove default public schema access (open by default in Postgres)
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- Grant schema visibility to app user
GRANT USAGE ON SCHEMA public TO ${DB_USER};
SQL

# Step 3: Set default privileges so future tables/sequences are covered
echo "Setting default privileges..."
PGPASSWORD=${POSTGRES_PASSWORD} psql -h ${DB_HOST} -p ${DB_PORT} -U postgres -d ${DB_NAME} << SQL
-- Any tables created in future (e.g. by migrations) grant these permissions automatically
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${DB_USER};

-- Same for sequences (used by serial/auto-increment columns)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO ${DB_USER};
SQL

echo "Done. Database '${DB_NAME}' is ready."