#!/bin/bash

# Source database connection details
SOURCE_HOST="pgbouncer00.s01a0001.entrata.io"
SOURCE_PORT="6400"
SOURCE_USER="psDeveloper"
SOURCE_PASS="developer"
SOURCE_DB="insurance_stage"

# Target database connection details
TARGET_HOST="pgbouncer00.d05d0001.entrata.io"
TARGET_PORT="6400"
TARGET_USER="psDba"
TARGET_PASS="dba"
TARGET_DB="insurance_dev"

echo "🔧 Generating constraints.sql from source..."

# docker run --rm -v "$(pwd)":/data postgres:16 bash -c "
# PGPASSWORD='${SOURCE_PASS}' \
# psql -qAt -h ${SOURCE_HOST} -p ${SOURCE_PORT} -U ${SOURCE_USER} -d ${SOURCE_DB} \
# -f /data/generate_constraints.sql > /data/constraints.sql
# "

echo "🚀 Applying constraints.sql to target..."

docker run --rm -v "$(pwd)":/data postgres:16 bash -c "
PGPASSWORD='${TARGET_PASS}' \
psql -v ON_ERROR_STOP=0 -h ${TARGET_HOST} -p ${TARGET_PORT} -U ${TARGET_USER} -d ${TARGET_DB} <<'EOSQL'
--BEGIN;
--SET session_replication_role = 'replica';
\i /data/constraints.sql
--SET session_replication_role = 'origin';
--COMMIT;
EOSQL
"

echo "✅ Migration completed."
