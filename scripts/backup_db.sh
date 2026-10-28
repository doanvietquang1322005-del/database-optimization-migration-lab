#!/usr/bin/env bash
DB_NAME="order_management_db"
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"
mysqldump -u root --single-transaction "$DB_NAME" > "$BACKUP_DIR/backup.sql"
