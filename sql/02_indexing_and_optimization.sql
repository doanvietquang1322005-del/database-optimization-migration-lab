USE order_management_db;

CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date DESC);
CREATE INDEX idx_orders_status_date ON orders (order_status, order_date);
CREATE INDEX idx_products_category_active ON products (category_id, is_active);

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
