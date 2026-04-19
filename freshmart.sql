-- FreshMart Retail Insights

-- DROP TABLE IF EXISTS sales_transactions;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(category_id),
    product_name VARCHAR(150) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_count INTEGER NOT NULL,
    expiry_date DATE NOT NULL
);

CREATE TABLE sales_transactions (
    sale_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL,
    transaction_date DATE NOT NULL
);

-- Dummy data: Categories
INSERT INTO categories (category_name)
VALUES
    ('Dairy'),
    ('Bakery'),
    ('Beverages'),
    ('Produce'),
    ('Snacks'),
    ('Frozen');

-- Dummy data: Products
INSERT INTO products (category_id, product_name, unit_price, stock_count, expiry_date)
VALUES
    -- Dairy
    (1, 'Whole Milk 1L', 2.80, 120, CURRENT_DATE + INTERVAL '3 days'),
    (1, 'Greek Yogurt 500g', 4.50,  65, CURRENT_DATE + INTERVAL '6 days'),
    (1, 'Cheddar Cheese 200g', 5.20,  40, CURRENT_DATE + INTERVAL '20 days'),

    -- Bakery
    (2, 'Sourdough Bread', 3.50,  80, CURRENT_DATE + INTERVAL '2 days'),
    (2, 'Burger Buns 6-pack', 2.90,  35, CURRENT_DATE + INTERVAL '5 days'),

    -- Beverages
    (3, 'Orange Juice 1L', 3.20,  90, CURRENT_DATE + INTERVAL '10 days'),
    (3, 'Cola 2L', 2.40, 200, CURRENT_DATE + INTERVAL '120 days'),

    -- Produce
    (4, 'Bananas 1kg', 1.80, 150, CURRENT_DATE + INTERVAL '4 days'),
    (4, 'Apples 1kg', 2.20,  60, CURRENT_DATE + INTERVAL '12 days'),

    -- Snacks
    (5, 'Potato Chips 200g', 2.10, 110, CURRENT_DATE + INTERVAL '180 days'),
    (5, 'Trail Mix 250g', 3.90,  55, CURRENT_DATE + INTERVAL '90 days'),

    -- Frozen
    (6, 'Frozen Peas 500g', 2.70,  75, CURRENT_DATE + INTERVAL '240 days'),
    (6, 'Vanilla Ice Cream 1L', 6.50,  48, CURRENT_DATE + INTERVAL '150 days');

-- Dummy data: SalesTransactions
INSERT INTO sales_transactions (product_id, quantity, sale_price, transaction_date)
VALUES
    -- Whole Milk (recent + last month)
    (1, 12, 2.80, CURRENT_DATE - INTERVAL '2 days'),
    (1, 10, 2.80, CURRENT_DATE - INTERVAL '10 days'),
    (1,  9, 2.80, CURRENT_DATE - INTERVAL '35 days'),

    -- Greek Yogurt (recent)
    (2,  7, 4.50, CURRENT_DATE - INTERVAL '3 days'),
    (2,  5, 4.50, CURRENT_DATE - INTERVAL '28 days'),

    -- Cheddar Cheese (only old sale, should be dead stock for last 2 months)
    (3, 11, 5.20, CURRENT_DATE - INTERVAL '80 days'),

    -- Sourdough Bread (recent)
    (4, 16, 3.50, CURRENT_DATE - INTERVAL '1 day'),
    (4, 14, 3.50, CURRENT_DATE - INTERVAL '20 days'),

    -- Orange Juice (recent)
    (6, 20, 3.20, CURRENT_DATE - INTERVAL '9 days'),

    -- Cola (last month heavy revenue)
    (7, 40, 2.40, date_trunc('month', CURRENT_DATE) - INTERVAL '7 days'),
    (7, 35, 2.40, date_trunc('month', CURRENT_DATE) - INTERVAL '12 days'),

    -- Bananas (recent)
    (8, 30, 1.80, CURRENT_DATE - INTERVAL '5 days'),

    -- Apples (last month)
    (9, 25, 2.20, date_trunc('month', CURRENT_DATE) - INTERVAL '10 days'),

    -- Chips (only old sale, should be dead stock for last 2 months)
    (10, 50, 2.10, CURRENT_DATE - INTERVAL '95 days'),

    -- Frozen Peas (last month)
    (12, 18, 2.70, date_trunc('month', CURRENT_DATE) - INTERVAL '8 days');

-- Expiring Soon
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.stock_count,
    p.expiry_date
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.expiry_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
  AND p.stock_count > 50
ORDER BY p.expiry_date, p.stock_count DESC;

-- Dead Stock`
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.stock_count,
    p.expiry_date
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE NOT EXISTS (
    SELECT 1
    FROM sales_transactions st
    WHERE st.product_id = p.product_id
    AND st.transaction_date >= CURRENT_DATE - INTERVAL '2 months'
)
ORDER BY p.product_id;

-- Revenue Contribution
SELECT
    c.category_name,
    ROUND(SUM(st.quantity * st.sale_price), 2) AS total_revenue_last_month
FROM sales_transactions st
JOIN products p ON p.product_id = st.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE st.transaction_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
    AND st.transaction_date < date_trunc('month', CURRENT_DATE)
GROUP BY c.category_name
ORDER BY total_revenue_last_month DESC;