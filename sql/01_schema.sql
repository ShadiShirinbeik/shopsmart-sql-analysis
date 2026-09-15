-- ShopSmart schema

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    region        VARCHAR(20) NOT NULL,
    signup_date   DATE NOT NULL
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    category      VARCHAR(50) NOT NULL,
    product_name  VARCHAR(100) NOT NULL,
    unit_price    NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id),
    order_date    DATE NOT NULL,
    total_amount  NUMERIC(10,2) NOT NULL
);

CREATE TABLE promotions (
    promotion_id	  INT PRIMARY KEY,
    product_id        INT NOT NULL REFERENCES products(product_id),
    start_date        DATE NOT NULL,
    end_date          DATE NOT NULL,
    discount_percent  INT NOT NULL
);

CREATE TABLE order_items (		
    order_item_id  INT PRIMARY KEY,
    order_id       INT NOT NULL REFERENCES orders(order_id),
    product_id     INT NOT NULL REFERENCES products(product_id),
    quantity       INT NOT NULL,
    unit_price     NUMERIC(10,2) NOT NULL,   -- price at time of sale (may differ from catalog)
    discount       NUMERIC(4,2) NOT NULL     -- fraction: 0.10 = 10%
);
