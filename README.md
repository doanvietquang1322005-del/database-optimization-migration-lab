# Database Design, Optimization & Migration Lab

Dự án tổng hợp các kỹ thuật **Thiết kế Cơ sở dữ liệu quan hệ (chuẩn 3NF)**, **Tối ưu hóa truy vấn với Indexing & Execution Plan**, **Xử lý giao dịch an toàn (ACID Transaction)**, và **Chuẩn hóa / Migrate dữ liệu (Data Migration & Backup)** phục vụ phát triển và vận hành Hệ thống Thông tin.

---

## 1. Cấu trúc dự án

```text
database-optimization-migration-lab/
├── sql/
│   ├── 01_schema_design.sql             # Thiết kế bảng chuẩn 3NF, Foreign Keys, Check Constraints
│   ├── 02_indexing_and_optimization.sql # Tạo Composite Index, phân tích EXPLAIN, Stored Procedure ACID
│   └── 03_data_migration_and_cleanup.sql# Kịch bản làm sạch và Migrate dữ liệu từ Staging sang Production
├── scripts/
│   └── backup_db.sh                     # Bash script tự động mysqldump nén .sql.gz và xoay vòng bản lưu
└── README.md                            # Tài liệu mô tả kiến trúc và hướng dẫn sử dụng
```

## 2. Điểm nhấn kỹ thuật (Key Highlights)

1. **Thiết kế CSDL chặt chẽ (`01_schema_design.sql`):**
   - Áp dụng chuẩn 3NF cho bài toán Quản lý Đơn hàng & Tồn kho (`customers`, `categories`, `products`, `orders`, `order_items`, `inventory_audit_logs`).
   - Sử dụng `CHECK` constraint ngăn chặn giá âm hoặc tồn kho âm, kết hợp bảng `inventory_audit_logs` để truy vết biến động dữ liệu.
2. **Tối ưu hóa hiệu năng & Xử lý đồng thời (`02_indexing_and_optimization.sql`):**
   - Thiết lập **Composite Index** (`idx_orders_customer_date`, `idx_orders_status_date`) giúp tối ưu các truy vấn lọc theo trạng thái và sắp xếp theo thời gian, tránh `Full Table Scan`.
   - Kiểm tra kế hoạch thực thi truy vấn bằng lệnh `EXPLAIN`.
   - Xây dựng Stored Procedure `sp_create_order_item` sử dụng `START TRANSACTION` và `SELECT ... FOR UPDATE` (Row-level locking) để chống lỗi Race Condition khi nhiều người đặt mua cùng lúc.
3. **Làm sạch & Migrate dữ liệu (`03_data_migration_and_cleanup.sql`):**
   - Quy trình đưa dữ liệu thô vào bảng `staging_raw_customers`, lọc bản ghi lỗi định dạng, chuẩn hóa chuỗi (`TRIM`, `LOWER`) và đồng bộ sang bảng chính bằng `INSERT ... ON DUPLICATE KEY UPDATE`.
4. **Tự động hóa vận hành Sao lưu (`scripts/backup_db.sh`):**
   - Sử dụng `mysqldump --single-transaction` để sao lưu nóng (hot backup) bảng InnoDB mà không làm gián đoạn hệ thống, nén trực tiếp ra `.sql.gz` và tự động xóa bản sao lưu cũ quá hạn.

