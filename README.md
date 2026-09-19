# Sunrise Supermarket — PLSQL Assignment One

**Name:** Shema Axel
**Student ID:** 29273
**DBMS used:** Oracle 21c XE (via SQL*Plus, PDB: `XEPDB1`)

## What this is

This is my take on the Sunrise Supermarket assignment — a small relational schema (customers, products, orders, order_items) with enough sample data to actually see patterns when you run joins, a CTE, and some window functions on it. Honestly had fun putting this together once I got Oracle behaving (more on that below 👇). The business scenario: Sunrise Supermarket wants to know who their customers are, what they're buying, and how sales move over time — so every query here is built to answer one of those questions directly.

## How to run it

1. Get an Oracle instance up (I used 21c XE) and connect to your pluggable database, e.g.:
   ```
   sqlplus / as sysdba
   ALTER SESSION SET CONTAINER = XEPDB1;
   ```
2. Run the scripts in order — they build on each other:
   ```
   @01_create_tables.sql
   @02_insert_data.sql
   @03_join_queries.sql
   @04_cte_query.sql
   @05_window_queries.sql
   ```
3. Each query prints straight to console. If you want them logged to a file, wrap the session with `SPOOL output.txt` before running the query scripts.

This should work on PostgreSQL, MySQL, or SQL Server too with minor syntax tweaks (mainly the `VARCHAR2`/`NUMBER` types and the `DATE '2026-06-02'` literal syntax, which are Oracle-specific).

## Business scenario

Sunrise Supermarket sells groceries, dairy, and household products to a small set of customers who place multiple orders over time. Management's questions boil down to: **who's buying, what are they buying, and is revenue trending up?** The schema has 6 customers, 8 products across 3 categories (Grocery, Dairy, Household), 15 orders, and 25 order line items spread across June–July 2026.

## Schema

```
customers (customer_id PK, customer_name, email, city)
products  (product_id PK, product_name, category, price)
orders    (order_id PK, customer_id FK, order_date)
order_items (order_item_id PK, order_id FK, product_id FK, quantity)
```

---

## JOIN queries (`03_join_queries.sql`)

### 1. Orders with customer name, city, and order date (INNER JOIN)
```sql
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;
```
**Why:** basic INNER JOIN — every order definitely has a customer attached, so this just flattens the two tables into one readable view, sorted chronologically.

**Result (first few rows):**
| order_id | customer_name | city | order_date |
|---|---|---|---|
| 1 | Nathan Drake | Kigali | 2026-06-02 |
| 2 | Ellie Williams | Musanze | 2026-06-03 |
| 3 | Nathan Drake | Kigali | 2026-06-10 |
| 4 | Geralt Rivia | Kigali | 2026-06-12 |
| 5 | Lara Croft | Huye | 2026-06-15 |

*(full 15-row result in the actual run — truncated here for readability)*

**Business read:** Nathan Drake is clearly a repeat shopper (4 orders across the two months), and orders are fairly evenly spread through June and July rather than clustered — decent sign of steady foot traffic.

### 2. Order items with product name, category, price, quantity, and line total
```sql
SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity,
       (p.price * oi.quantity) AS line_total
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id;
```
**Why:** this is the "what exactly did they buy" view — joining line items to the product catalog and computing the line total inline instead of doing that math in the app layer.

**Business read:** Rice 5kg and Cooking Oil 2L show up a lot and drive some of the biggest line totals (e.g. 3× Rice on order 8 = 37.50), so Grocery items are pulling more revenue per line than the cheaper Dairy items even though Dairy has more individual transactions.

### 3. All customers with their orders, including customers with none (LEFT JOIN)
```sql
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;
```
**Why:** LEFT JOIN so nobody gets dropped — this is the query that actually surfaces customers who haven't ordered anything yet.

**Result:**
| customer_id | customer_name | order_id | order_date |
|---|---|---|---|
| 1 | Nathan Drake | 1, 3, 6, 11 | (4 rows) |
| 2 | Ellie Williams | 2, 9, 14 | (3 rows) |
| 3 | Geralt Rivia | 4, 8, 13 | (3 rows) |
| 4 | Lara Croft | 5, 10, 15 | (3 rows) |
| 5 | Kratos Olympus | 7, 12 | (2 rows) |
| 6 | Aloy Sobeck | NULL | NULL |

**Business read:** Aloy Sobeck is in the customer table but has never placed an order — a clean example of a lapsed/never-activated customer that Sunrise could target with a welcome promo.

---

## CTE query (`04_cte_query.sql`)

### Customers whose total spend is above average
```sql
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name, SUM(oi.quantity * p.price) AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spend
FROM customer_totals
WHERE total_spend > (SELECT AVG(total_spend) FROM customer_totals)
ORDER BY total_spend DESC;
```
**Why a CTE:** I needed the per-customer total twice — once to compare against, once to filter by — so computing it once in `customer_totals` and reusing it beats repeating the whole join-and-aggregate logic in a subquery.

**Result:**
| customer_id | customer_name | total_spend |
|---|---|---|
| 1 | Nathan Drake | 86.40 |
| 3 | Geralt Rivia | 70.60 |
| 2 | Ellie Williams | 56.00 |

Average spend across the 5 customers who've ordered anything comes out to **53.28**, so these three clear the bar (Lara Croft at 30.60 and Kratos Olympus at 22.80 fall below it).

**Business read:** Nathan, Geralt, and Ellie are the top-tier spenders — worth a loyalty program or personalized offers, since they're already almost 63% of total revenue between the three of them.

---

## Window-function queries (`05_window_queries.sql`)

### 1. Rank customers by total spend
```sql
... RANK() OVER (ORDER BY total_spend DESC) AS spend_rank ...
```
**Result:**
| rank | customer | total_spend |
|---|---|---|
| 1 | Nathan Drake | 86.40 |
| 2 | Geralt Rivia | 70.60 |
| 3 | Ellie Williams | 56.00 |
| 4 | Lara Croft | 30.60 |
| 5 | Kratos Olympus | 22.80 |

**Business read:** basically a leaderboard — useful for deciding who gets the first invite to a VIP program.

### 2. Number each customer's orders in the order placed
```sql
... ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_sequence ...
```
**Business read:** this tells you, e.g., that Nathan Drake's 4th-ever order was on 2026-07-08 — handy for spotting "which visit was this" without eyeballing dates, and useful groundwork for cohort/retention analysis later.

### 3. Running total of revenue over time
```sql
... SUM(order_total) OVER (ORDER BY order_date, order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total ...
```
**Result (tail end):**
| order_date | order_total | running_total |
|---|---|---|
| 2026-07-10 | 6.00 | 243.00 |
| 2026-07-15 | 6.60 | 249.60 |
| 2026-07-18 | 16.80 | 266.40 |

(Order 15 doesn't show up here since it has no line items yet — makes sense, no revenue to attribute.)

**Business read:** total revenue for the period lands at **266.40**, and the running total shows growth is fairly steady rather than one big order carrying the whole picture — good sign for consistency.

### 4. Days since each customer's previous order
```sql
... order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_since_previous_order ...
```
**Business read:** this is the one I'd actually use for re-engagement — e.g. Ellie Williams went 28 days between her first and second order, which is a bigger gap than most others and could flag her as someone who needs a reminder nudge before she drifts off.

---

## Challenges & how I resolved them

**Setup Note:** While installing Oracle 21c XE, the listener was pointing to a database home (`OraDB21Home1`) that was missing its `bin` folder, so `sqlplus` couldn't connect over the network — kept getting `ORA-12543 host unreachable`. I tried fiddling with firewall rules and testing different hostnames/IPs, but none of that helped because the real problem was the incomplete install, not the network at all.

Fixed it by connecting locally through the other, actually-working home (`dbhomeXE`) using the bequeath connection (`sqlplus / as sysdba`, no host/port needed), then switching into the `XEPDB1` container with `ALTER SESSION SET CONTAINER` before running any of the scripts. Lesson learned: when a "connection" error shows up, check that the install itself is actually complete before chasing network config.

Aside from that, the trickiest part conceptually was making sure the CTE's average was computed correctly — since `customer_totals` only includes customers who've actually ordered something (INNER JOINs all the way down), the average is over 5 customers, not 6, which is exactly what we want for a meaningful "above average" comparison.
