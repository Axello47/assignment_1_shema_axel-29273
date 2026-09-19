# Sunrise Supermarket - PLSQL Assignment One

Name: Shema Axel

Student ID: 29273

DBMS: Oracle 21c XE (SQL*Plus, PDB XEPDB1)

## what i did

basically built out the sunrise supermarket schema they gave us (customers, products, orders, order_items) and filled it with made up data - 6 customers, 8 products in 3 categories, 15 orders, 25 order items spread over june-july 2026. then wrote the join/cte/window queries they asked for and actually ran them to see what comes out.

## how to run

connect to oracle and switch into the pdb first:
sqlplus / as sysdba
ALTER SESSION SET CONTAINER = XEPDB1;

then just run the files in order, they depend on each other:
@01_create_tables.sql
@02_insert_data.sql
@03_join_queries.sql
@04_cte_query.sql
@05_window_queries.sql

should work on postgres/mysql too if you swap out the VARCHAR2/NUMBER types and the DATE '2026-06-02' syntax, that part is oracle specific.

## the scenario

sunrise supermarket sells groceries/dairy/household stuff and management wants to know who's actually buying, what they buy, and if sales are going anywhere over time. thats basically what every query below is trying to answer.

customers table has who they are, products has what they sell, orders is when someone placed an order, order_items is the actual line items in that order.

---

## join queries (03_join_queries.sql)

### 1 - orders with customer name/city/date, inner join
SELECT o.order_id, c.customer_name, c.city, o.order_date FROM orders o INNER JOIN customers c ON o.customer_id = c.customer_id ORDER BY o.order_date;

pretty standard inner join, every order has a customer so nothing gets lost. just wanted it sorted by date so you can see the order of things.

first few rows look like:
order_id 1 -> Nathan Drake, Denver, 2026-06-02
order_id 2 -> Ellie Williams, Toronto, 2026-06-03
order_id 3 -> Nathan Drake, Denver, 2026-06-10
order_id 4 -> Geralt Rivia, Denver, 2026-06-12

(15 rows total, didn't paste all of them here)

what it tells us: Nathan orders a lot (4 times in 2 months) so hes basically a repeat customer, and the orders are spread pretty evenly across the two months not bunched up.

### 2 - order items with product info + line total
SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity, (p.price * oi.quantity) AS line_total FROM order_items oi JOIN products p ON oi.product_id = p.product_id ORDER BY oi.order_id;

this one joins the line items to products so you can see what was actually bought and how much that line cost, did the multiplication right in the query instead of after.

what it tells us: rice and cooking oil show up a lot and have some of the highest line totals (order 8 has 3x rice = 37.50) so grocery stuff is bringing in more per line even tho dairy items get ordered more often individually.

### 3 - all customers incl ones with no orders, left join
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id ORDER BY c.customer_id;

left join so nobody gets dropped, this is the one that actually shows you who hasn't ordered anything.

result: customer 6, Aloy Sobeck, shows up with NULL for order_id and order_date - meaning she's in the system but never bought anything. everyone else (1-5) has orders attached.

what it tells us: Aloy could be someone to target with like a first order discount or something since she's registered but never checked out.

---

## cte query (04_cte_query.sql)

### customers spending above the average
WITH customer_totals AS (SELECT c.customer_id, c.customer_name, SUM(oi.quantity * p.price) AS total_spend FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id GROUP BY c.customer_id, c.customer_name) SELECT customer_id, customer_name, total_spend FROM customer_totals WHERE total_spend > (SELECT AVG(total_spend) FROM customer_totals) ORDER BY total_spend DESC;

used a CTE here because i needed the customer totals twice, once to get the average and once to actually filter against it. easier than writing that whole join+groupby again as a nested subquery.

result:
Nathan Drake - 86.40
Geralt Rivia - 70.60
Ellie Williams - 56.00

average across the 5 customers who've actually ordered something comes out to 53.28, so these 3 are above it (Lara at 30.60 and Kratos at 22.80 are below).

what it tells us: these three are basically the top spenders, might be worth giving them some kind of loyalty perk since together they're already most of the revenue.

---

## window function queries (05_window_queries.sql)

### 1 - rank customers by total spend
... RANK() OVER (ORDER BY total_spend DESC) AS spend_rank ...

gives you a leaderboard basically:
1. Nathan Drake - 86.40
2. Geralt Rivia - 70.60
3. Ellie Williams - 56.00
4. Lara Croft - 30.60
5. Kratos Olympus - 22.80

### 2 - number each customers orders in order placed
... ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_sequence ...

so like this tells you Nathan's 4th order ever was on 2026-07-08, useful if you wanna know "which visit is this" without doing date math in your head.

### 3 - running total of revenue over time
... SUM(order_total) OVER (ORDER BY order_date, order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total ...

by the end of the dataset (2026-07-18) running total hits 266.40 which is the full revenue for the period. order 15 doesn't show up in this one since it has no items attached yet so theres nothing to add.

what it tells us: revenue is climbing pretty steadily, not like one huge order carrying everything, which is a decent sign.

### 4 - days since each customers previous order
... order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_since_previous_order ...

this is probably the most useful one honestly - Ellie went 28 days between her first and second order which is the longest gap out of anyone, so she'd probably be the first person i'd send a "hey come back" reminder to.

---

## challenges

Setup Note: while installing Oracle 21c XE, the listener was pointing at a database home (OraDB21Home1) that turned out to be missing its bin folder, so sqlplus couldn't connect over the network - kept throwing ORA-12543 host unreachable at me. wasted a good while messing with firewall rules and trying different hostnames/IPs before realizing none of that was the actual issue, the install itself was just incomplete.

fixed it by connecting locally through the other home that actually worked (dbhomeXE) using the bequeath connection, so just sqlplus / as sysdba with no host or port, then switched into XEPDB1 with ALTER SESSION SET CONTAINER before running anything. took me embarrassingly long to figure out the error had nothing to do with the network.

other than that the annoying part was making sure the CTE average was actually calculated right - since customer_totals only includes people who've ordered something (all inner joins), the average is over 5 people not 6, which is what you actually want for this to mean anything.
