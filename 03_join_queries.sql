SELECT o.order_id, c.customer_name, c.city, o.order_date FROM orders o INNER JOIN customers c ON o.customer_id = c.customer_id ORDER BY o.order_date;

SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity, (p.price * oi.quantity) AS line_total FROM order_items oi JOIN products p ON oi.product_id = p.product_id ORDER BY oi.order_id;

SELECT c.customer_id, c.customer_name, o.order_id, o.order_date FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id ORDER BY c.customer_id;
