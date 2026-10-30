#!/usr/bin/env bash
# ============================================================================
# SCRIPT TỰ ĐỘNG SAO LƯU CƠ SỞ DỮ LIỆU MYSQL (AUTOMATED DB BACKUP SCRIPT)
# Sử dụng kết hợp với Crontab trên máy chủ Linux
# ============================================================================

set -euo pipefail

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-order_management_db}"
DB_USER="${DB_USER:-root}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql.gz"

mkdir -p "${BACKUP_DIR}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Bắt đầu sao lưu CSDL: ${DB_NAME}..."

# Sử dụng --single-transaction để sao lưu InnoDB không gây khóa bảng (non-blocking)
mysqldump -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" \
  --single-transaction \
  --routines \
  --triggers \
  "${DB_NAME}" | gzip > "${BACKUP_FILE}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Sao lưu thành công: ${BACKUP_FILE}"

# Dọn dẹp các bản backup cũ hơn RETENTION_DAYS ngày
find "${BACKUP_DIR}" -name "${DB_NAME}_*.sql.gz" -type f -mtime +"${RETENTION_DAYS}" -delete
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Đã dọn dẹp các bản backup quá ${RETENTION_DAYS} ngày."

