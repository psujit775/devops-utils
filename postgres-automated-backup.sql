#!/bin/bash

set -e

# PostgreSQL database details
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="$1"
DB_USERNAME="username"
DB_PASSWORD="passdword"

# Backup directory and filename
BACKUP_DIR="./dump"
DATE=$(date +"%Y-%m-%d-%H-%M-%S%z")
BACKUP_FILENAME="${DB_NAME}_backup_${DATE}.sql"
BACKUPS_TO_KEEP=5

# AWS S3 details
S3_BUCKET="<bucket-name>"
S3_PREFIX="<bucket-prefix>"

# Check if the database name is provided
if [ -z "$DB_NAME" ]; then
  echo "Database name argument is missing."
  echo "Example: bash db_backup.sh postgres"
  exit 1
fi

# Start time
START_TIME=$(date +%s)
echo "Backup process started at: `date`"

# Create backup
export PGPASSWORD="${DB_PASSWORD}"
if [ "$DB_NAME" = "full" ]; then
  # Full dump using pg_dumpall
  echo "Starting full database dump using pg_dumpall..."
  START_DUMP_TIME=$(date +%s)
  pg_dumpall -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" -f "${BACKUP_DIR}/${BACKUP_FILENAME}"
  END_DUMP_TIME=$(date +%s)
  echo "Full database dump completed ($(($END_DUMP_TIME-$START_DUMP_TIME))s)."
else
  # Dump specific database using pg_dump
  echo "Starting backup of database: ${DB_NAME}..."
  START_DUMP_TIME=$(date +%s)
  pg_dump -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" -d "${DB_NAME}" -Fc -f "${BACKUP_DIR}/${BACKUP_FILENAME}"
  END_DUMP_TIME=$(date +%s)
  echo "Backup of database ${DB_NAME} completed ($(($END_DUMP_TIME-$START_DUMP_TIME))s)."
fi

# Optional: Compression (requires 'gzip' installed)
if [ "$2" = "compress" ]; then
  echo "Compressing backup file using gzip..."
  gzip "${BACKUP_DIR}/${BACKUP_FILENAME}"
  BACKUP_FILENAME="${BACKUP_FILENAME}.gz"
fi

# Upload to S3
echo "Uploading backup to S3..."
aws s3 cp --quiet "${BACKUP_DIR}/${BACKUP_FILENAME}" "s3://${S3_BUCKET}/${S3_PREFIX}/${BACKUP_FILENAME}"

# Optional: Rotate backups (keep the last N backups, delete older ones)
echo "Rotating backups for database: ${DB_NAME}"
backup_count=$(aws s3 ls "s3://${S3_BUCKET}/${S3_PREFIX}/" --recursive | grep "${DB_NAME}" | wc -l)
if [ "$backup_count" -gt "$BACKUPS_TO_KEEP" ]; then
  backups_to_delete=$(aws s3 ls "s3://${S3_BUCKET}/${S3_PREFIX}/" --recursive | grep "${DB_NAME}"| sort -r | awk 'NR>'"${BACKUPS_TO_KEEP}"'{print $4}')
  echo "Backups to delete:"
  echo "$backups_to_delete"
  echo "$backups_to_delete" | xargs -I {} aws s3 rm "s3://${S3_BUCKET}/{}"
  echo "Backup rotation completed."
  #aws s3 ls "s3://${S3_BUCKET}/${S3_PREFIX}/" --recursive | sort -r | awk 'NR>'"${BACKUPS_TO_KEEP}"'{print $4}' | xargs -I {} aws s3 rm "s3://${S3_BUCKET}/{}"
else
  echo "No backups to rotate."
fi

echo "Backup uploaded to S3: ${BACKUP_FILENAME}"

# Delete local copy
echo "Deleting local backup after uploading to S3..."
rm "${BACKUP_DIR}/${BACKUP_FILENAME}"
END_TIME=$(date +%s)

echo "Backup process completed ($(($END_TIME-$START_TIME))s)."
echo "Backup process Ended at: `date`"
echo ""
