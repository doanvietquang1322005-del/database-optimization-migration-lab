-- ============================================================================
-- HỆ THỐNG CƠ SỞ DỮ LIỆU QUẢN LÝ ĐƠN HÀNG & TỒN KHO (E-COMMERCE ORDER SYSTEM)
-- Mục tiêu: Thiết kế chuẩn 3NF, ràng buộc toàn vẹn dữ liệu & đánh Index tối ưu
-- ============================================================================

CREATE DATABASE IF NOT EXISTS order_management_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE order_management_db;

-- 1. Bảng Khách hàng (Customers)
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Bảng Danh mục sản phẩm (Categories)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

-- 3. Bảng Sản phẩm & Tồn kho (Products)
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(200) NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Bảng Đơn hàng (Orders)
CREATE TABLE orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('PENDING', 'PAID', 'SHIPPED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    total_amount DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    shipping_address VARCHAR(255) NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 5. Bảng Chi tiết đơn hàng (Order Items)
CREATE TABLE order_items (
    order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. Bảng Lịch sử biến động kho / Audit Log phục vụ đối soát dữ liệu
CREATE TABLE inventory_audit_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    change_quantity INT NOT NULL,
    reason VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_logs_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

