-- create inserted data with ai to save time

INSERT INTO customers VALUES (1, 'Nathan Drake', 'ndrake@gmail.com', 'Kigali');
INSERT INTO customers VALUES (2, 'Ellie Williams', 'ellie.w@gmail.com', 'Musanze');
INSERT INTO customers VALUES (3, 'Geralt Rivia', 'geralt.r@gmail.com', 'Kigali');
INSERT INTO customers VALUES (4, 'Lara Croft', 'lara.croft@gmail.com', 'Huye');
INSERT INTO customers VALUES (5, 'Kratos Olympus', 'kratos.o@gmail.com', 'Rubavu');
INSERT INTO customers VALUES (6, 'Aloy Sobeck', 'aloy.s@gmail.com', 'Kigali');

INSERT INTO products VALUES (1, 'Rice 5kg', 'Grocery', 12.50);
INSERT INTO products VALUES (2, 'Cooking Oil 2L', 'Grocery', 9.00);
INSERT INTO products VALUES (3, 'Sugar 1kg', 'Grocery', 2.20);
INSERT INTO products VALUES (4, 'Fresh Milk 1L', 'Dairy', 1.50);
INSERT INTO products VALUES (5, 'Cheddar Cheese', 'Dairy', 6.75);
INSERT INTO products VALUES (6, 'Yogurt 500ml', 'Dairy', 2.00);
INSERT INTO products VALUES (7, 'Dish Soap', 'Household', 3.30);
INSERT INTO products VALUES (8, 'Toilet Paper 12pk', 'Household', 5.60);

INSERT INTO orders VALUES (1, 1, DATE '2026-06-02');
INSERT INTO orders VALUES (2, 2, DATE '2026-06-03');
INSERT INTO orders VALUES (3, 1, DATE '2026-06-10');
INSERT INTO orders VALUES (4, 3, DATE '2026-06-12');
INSERT INTO orders VALUES (5, 4, DATE '2026-06-15');
INSERT INTO orders VALUES (6, 1, DATE '2026-06-20');
INSERT INTO orders VALUES (7, 5, DATE '2026-06-21');
INSERT INTO orders VALUES (8, 3, DATE '2026-06-25');
INSERT INTO orders VALUES (9, 2, DATE '2026-07-01');
INSERT INTO orders VALUES (10, 4, DATE '2026-07-03');
INSERT INTO orders VALUES (11, 1, DATE '2026-07-08');
INSERT INTO orders VALUES (12, 5, DATE '2026-07-10');
INSERT INTO orders VALUES (13, 3, DATE '2026-07-15');
INSERT INTO orders VALUES (14, 2, DATE '2026-07-18');
INSERT INTO orders VALUES (15, 4, DATE '2026-07-22');

INSERT INTO order_items VALUES (1, 1, 1, 2);
INSERT INTO order_items VALUES (2, 1, 4, 3);
INSERT INTO order_items VALUES (3, 2, 2, 1);
INSERT INTO order_items VALUES (4, 2, 7, 2);
INSERT INTO order_items VALUES (5, 3, 3, 4);
INSERT INTO order_items VALUES (6, 3, 5, 1);
INSERT INTO order_items VALUES (7, 4, 1, 1);
INSERT INTO order_items VALUES (8, 4, 6, 5);
INSERT INTO order_items VALUES (9, 5, 8, 2);
INSERT INTO order_items VALUES (10, 5, 2, 1);
INSERT INTO order_items VALUES (11, 6, 4, 2);
INSERT INTO order_items VALUES (12, 6, 3, 3);
INSERT INTO order_items VALUES (13, 7, 5, 2);
INSERT INTO order_items VALUES (14, 7, 7, 1);
INSERT INTO order_items VALUES (15, 8, 1, 3);
INSERT INTO order_items VALUES (16, 8, 6, 2);
INSERT INTO order_items VALUES (17, 9, 2, 2);
INSERT INTO order_items VALUES (18, 9, 8, 1);
INSERT INTO order_items VALUES (19, 10, 4, 4);
INSERT INTO order_items VALUES (20, 10, 3, 2);
INSERT INTO order_items VALUES (21, 11, 5, 1);
INSERT INTO order_items VALUES (22, 11, 1, 2);
INSERT INTO order_items VALUES (23, 12, 6, 3);
INSERT INTO order_items VALUES (24, 13, 7, 2);
INSERT INTO order_items VALUES (25, 14, 8, 3);

COMMIT;
