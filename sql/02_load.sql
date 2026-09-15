-- Run from the repo root with psql:  psql -d shopsmart -f sql/02_load.sql

\copy customers   FROM 'data/customers.csv'   CSV HEADER
\copy products    FROM 'data/products.csv'    CSV HEADER
\copy orders      FROM 'data/orders.csv'      CSV HEADER
\copy promotions  FROM 'data/promotions.csv'  CSV HEADER
\copy order_items FROM 'data/order_items.csv' CSV HEADER

-- to check: expected 200 / 50 / 300 / 20 / 970
SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'promotions',  COUNT(*) FROM promotions
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;