-- ============================================================================
-- KỊCH BẢN CHUẨN HÓA & MIGRATE DỮ LIỆU TỪ BẢNG TẠM (STAGING) SANG PRODUCTION
-- ============================================================================

USE order_management_db;

-- 1. Tạo bảng Staging tiếp nhận dữ liệu thô (ví dụ từ file CSV / hệ thống cũ)
CREATE TABLE IF NOT EXISTS staging_raw_customers (
    raw_id INT AUTO_INCREMENT PRIMARY KEY,
    raw_full_name VARCHAR(200),
    raw_email VARCHAR(200),
    raw_phone VARCHAR(50),
    migrated_status ENUM('PENDING', 'SUCCESS', 'INVALID') DEFAULT 'PENDING',
    error_note VARCHAR(255)
) ENGINE=InnoDB;

-- 2. Đánh dấu các bản ghi lỗi định dạng (thiếu email hoặc email không hợp lệ)
UPDATE staging_raw_customers
SET migrated_status = 'INVALID',
    error_note = 'Email trống hoặc sai định dạng'
WHERE migrated_status = 'PENDING'
  AND (raw_email IS NULL OR TRIM(raw_email) = '' OR raw_email NOT LIKE '%@%.%');

-- 3. Chuẩn hóa dữ liệu (TRIM khoảng trắng, viết thường email) và Migrate sang bảng chính
INSERT INTO customers (full_name, email, phone, status)
SELECT
    TRIM(s.raw_full_name) AS full_name,
    LOWER(TRIM(s.raw_email)) AS email,
    REPLACE(TRIM(s.raw_phone), ' ', '') AS phone,
    'ACTIVE'
FROM staging_raw_customers s
WHERE s.migrated_status = 'PENDING'
ON DUPLICATE KEY UPDATE
    full_name = VALUES(full_name),
    phone = VALUES(phone);

-- 4. Cập nhật trạng thái hoàn tất Migrate
UPDATE staging_raw_customers
SET migrated_status = 'SUCCESS'
WHERE migrated_status = 'PENDING';

