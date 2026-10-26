-- ============================================================================
-- DỮ LIỆU MẪU & TRUY VẤN PHÂN TÍCH BÁO CÁO (DATA ANALYTICS & REPORTING QUERIES)
-- Phục vụ mảng: Phân tích & Tối ưu dữ liệu hệ thống
-- ============================================================================

USE order_management_db;

-- 1. Thêm dữ liệu danh mục và sản phẩm mẫu
INSERT INTO categories (category_name, description) VALUES
('Thiết bị mạng & Server', 'Router, Switch, Firewall, Linh kiện máy chủ'),
('Phụ kiện công nghệ', 'Cáp mạng, ổ cứng SSD, thiết bị lưu trữ');

INSERT INTO products (category_id, sku, product_name, unit_price, stock_quantity) VALUES
(1, 'SRV-DELL-01', 'Máy chủ Dell PowerEdge Entry', 28500000.00, 15),
(1, 'SW-CISCO-24', 'Switch Cisco 24 Ports Gigabit', 4200000.00, 40),
(2, 'SSD-ENT-1TB', 'Ổ cứng SSD Enterprise 1TB NVMe', 3100000.00, 85);

-- 2. Truy vấn phân tích: Doanh thu và số lượng đơn hàng theo tháng
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS report_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS monthly_revenue,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM orders o
WHERE o.order_status = 'COMPLETED'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY report_month DESC;

-- 3. Truy vấn phân tích: Top sản phẩm bán chạy kèm tỷ lệ tồn kho hiện tại
SELECT
    p.sku,
    p.product_name,
    c.category_name,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    p.stock_quantity AS current_stock,
    CASE
        WHEN p.stock_quantity < 10 THEN 'CẢNH BÁO SẮP HẾT HÀNG'
        WHEN p.stock_quantity < 30 THEN 'CẦN NHẬP THÊM'
        ELSE 'ĐỦ TỒN KHO'
    END AS inventory_alert
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status = 'COMPLETED'
GROUP BY p.product_id, p.sku, p.product_name, c.category_name, p.stock_quantity
ORDER BY total_sold DESC;

