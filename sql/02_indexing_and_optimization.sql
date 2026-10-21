-- ============================================================================
-- TỐI ƯU HÓA TRUY VẤN (INDEXING & QUERY OPTIMIZATION) VÀ STORED PROCEDURE
-- ============================================================================

USE order_management_db;

-- 1. Tạo Composite Index phục vụ truy vấn lọc đơn hàng theo khách hàng & ngày đặt
-- Giúp tránh Full Table Scan khi bảng orders tăng lên hàng trăm nghìn bản ghi
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date DESC);

-- 2. Tạo Index phục vụ báo cáo thống kê theo trạng thái và thời gian
CREATE INDEX idx_orders_status_date ON orders (order_status, order_date);

-- 3. Tạo Index trên khóa ngoại và danh mục sản phẩm
CREATE INDEX idx_products_category_active ON products (category_id, is_active);
CREATE INDEX idx_order_items_order_product ON order_items (order_id, product_id);

-- 4. Sử dụng EXPLAIN để kiểm tra kế hoạch thực thi (Execution Plan)
EXPLAIN
SELECT
    o.order_id,
    c.full_name,
    o.order_date,
    o.total_amount,
    o.order_status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'COMPLETED'
  AND o.order_date >= '2026-01-01 00:00:00'
ORDER BY o.order_date DESC
LIMIT 50;

-- 5. Stored Procedure xử lý đặt hàng đảm bảo ACID Transaction (tránh âm kho)
DELIMITER $$

CREATE PROCEDURE sp_create_order_item(
    IN p_order_id BIGINT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(12, 2);

    -- Bắt đầu Transaction và khóa dòng sản phẩm (FOR UPDATE) để tránh Race Condition
    START TRANSACTION;

    SELECT stock_quantity, unit_price
    INTO v_stock, v_price
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF v_stock IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sản phẩm không tồn tại';
    ELSEIF v_stock < p_quantity THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số lượng tồn kho không đủ';
    ELSE
        -- Thêm chi tiết đơn hàng
        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (p_order_id, p_product_id, p_quantity, v_price);

        -- Trừ tồn kho
        UPDATE products
        SET stock_quantity = stock_quantity - p_quantity
        WHERE product_id = p_product_id;

        -- Cập nhật tổng tiền đơn hàng
        UPDATE orders
        SET total_amount = total_amount + (v_price * p_quantity)
        WHERE order_id = p_order_id;

        -- Ghi log biến động kho
        INSERT INTO inventory_audit_logs (product_id, change_quantity, reason)
        VALUES (p_product_id, -p_quantity, CONCAT('ORDER_', p_order_id));

        COMMIT;
    END IF;
END$$

DELIMITER ;

