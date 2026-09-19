WITH customer_totals AS (SELECT c.customer_id, c.customer_name, SUM(oi.quantity * p.price) AS total_spend FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id GROUP BY c.customer_id, c.customer_name) SELECT customer_id, customer_name, total_spend, RANK() OVER (ORDER BY total_spend DESC) AS spend_rank FROM customer_totals ORDER BY spend_rank;

SELECT o.customer_id, o.order_id, o.order_date, ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_sequence FROM orders o ORDER BY o.customer_id, order_sequence;

WITH order_revenue AS (SELECT o.order_id, o.order_date, SUM(oi.quantity * p.price) AS order_total FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id GROUP BY o.order_id, o.order_date) SELECT order_id, order_date, order_total, SUM(order_total) OVER (ORDER BY order_date, order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM order_revenue ORDER BY order_date, order_id;

SELECT customer_id, order_id, order_date, order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_since_previous_order FROM orders ORDER BY customer_id, order_date;
