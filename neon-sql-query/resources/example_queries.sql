-- Example SQL Queries for Neon Databases
-- These examples demonstrate common operations and best practices

-- =============================================================================
-- DATABASE INSPECTION
-- =============================================================================

-- List all tables in the public schema
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Show table structure with column details
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'your_table_name'
ORDER BY ordinal_position;

-- Get table sizes and row counts
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS indexes_size,
    n_live_tup AS estimated_rows
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- List all indexes
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- =============================================================================
-- DATA QUERIES
-- =============================================================================

-- Basic SELECT with filtering and ordering
SELECT *
FROM users
WHERE created_at >= '2024-01-01'
    AND status = 'active'
ORDER BY created_at DESC
LIMIT 100;

-- Aggregation with grouping
SELECT
    category,
    COUNT(*) as product_count,
    AVG(price) as avg_price,
    MIN(price) as min_price,
    MAX(price) as max_price,
    SUM(stock_quantity) as total_stock
FROM products
GROUP BY category
HAVING COUNT(*) > 5
ORDER BY product_count DESC;

-- JOIN operations
SELECT
    o.id as order_id,
    u.name as customer_name,
    u.email as customer_email,
    o.total_amount,
    o.status,
    o.created_at as order_date
FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE o.created_at >= NOW() - INTERVAL '30 days'
    AND o.status = 'completed'
ORDER BY o.created_at DESC;

-- Window functions
SELECT
    user_id,
    order_date,
    amount,
    SUM(amount) OVER (PARTITION BY user_id ORDER BY order_date) as running_total,
    AVG(amount) OVER (PARTITION BY user_id) as user_avg_order,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date DESC) as order_rank
FROM orders;

-- Common Table Expressions (CTEs)
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) as month,
        SUM(amount) as total_sales,
        COUNT(*) as order_count
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
sales_growth AS (
    SELECT
        month,
        total_sales,
        order_count,
        LAG(total_sales) OVER (ORDER BY month) as prev_month_sales,
        total_sales - LAG(total_sales) OVER (ORDER BY month) as sales_change
    FROM monthly_sales
)
SELECT
    month,
    total_sales,
    order_count,
    sales_change,
    ROUND((sales_change / NULLIF(prev_month_sales, 0)) * 100, 2) as growth_percentage
FROM sales_growth
ORDER BY month DESC;

-- =============================================================================
-- DATA MODIFICATION
-- =============================================================================

-- Insert single record
INSERT INTO users (name, email, created_at)
VALUES ('John Doe', 'john@example.com', NOW())
RETURNING id, name, created_at;

-- Insert multiple records
INSERT INTO products (name, category, price, stock_quantity)
VALUES
    ('Product A', 'electronics', 299.99, 50),
    ('Product B', 'electronics', 199.99, 75),
    ('Product C', 'clothing', 49.99, 100)
RETURNING id, name;

-- Update with conditions
UPDATE products
SET
    price = price * 1.1,
    updated_at = NOW()
WHERE category = 'electronics'
    AND stock_quantity > 0
RETURNING id, name, price;

-- Update with JOIN (using subquery)
UPDATE orders o
SET status = 'shipped'
WHERE id IN (
    SELECT order_id
    FROM shipments
    WHERE shipped_date = CURRENT_DATE
)
RETURNING id, status;

-- Delete with conditions
DELETE FROM logs
WHERE created_at < NOW() - INTERVAL '90 days'
RETURNING id;

-- Upsert (INSERT ... ON CONFLICT)
INSERT INTO user_preferences (user_id, preference_key, preference_value)
VALUES (123, 'theme', 'dark')
ON CONFLICT (user_id, preference_key)
DO UPDATE SET
    preference_value = EXCLUDED.preference_value,
    updated_at = NOW()
RETURNING *;

-- =============================================================================
-- PERFORMANCE OPTIMIZATION
-- =============================================================================

-- Analyze query execution plan
EXPLAIN ANALYZE
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= '2024-01-01'
GROUP BY u.id, u.name
HAVING COUNT(o.id) > 5;

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_status ON orders(status) WHERE status IN ('pending', 'processing');

-- Composite index
CREATE INDEX idx_orders_user_status ON orders(user_id, status, created_at DESC);

-- Vacuum and analyze tables (for maintenance)
VACUUM ANALYZE users;
VACUUM ANALYZE orders;

-- =============================================================================
-- DATA VALIDATION
-- =============================================================================

-- Find duplicate records
SELECT email, COUNT(*)
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- Find orphaned records
SELECT o.id, o.user_id
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL;

-- Check for NULL values
SELECT
    COUNT(*) as total_records,
    COUNT(email) as records_with_email,
    COUNT(*) - COUNT(email) as records_without_email,
    ROUND((COUNT(*) - COUNT(email))::numeric / COUNT(*) * 100, 2) as null_percentage
FROM users;

-- Verify referential integrity
SELECT
    COUNT(*) as total_orders,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(*) - COUNT(user_id) as orders_without_user
FROM orders;

-- =============================================================================
-- REPORTING & ANALYTICS
-- =============================================================================

-- Daily active users
SELECT
    DATE(last_login) as date,
    COUNT(DISTINCT user_id) as daily_active_users
FROM user_activity
WHERE last_login >= NOW() - INTERVAL '30 days'
GROUP BY DATE(last_login)
ORDER BY date DESC;

-- Revenue by product category
SELECT
    p.category,
    COUNT(DISTINCT o.id) as order_count,
    SUM(oi.quantity) as units_sold,
    SUM(oi.quantity * oi.unit_price) as total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'completed'
    AND o.created_at >= NOW() - INTERVAL '90 days'
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Customer lifetime value
SELECT
    u.id,
    u.name,
    u.email,
    COUNT(o.id) as total_orders,
    SUM(o.total_amount) as lifetime_value,
    AVG(o.total_amount) as avg_order_value,
    MIN(o.created_at) as first_order,
    MAX(o.created_at) as last_order
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 'completed'
GROUP BY u.id, u.name, u.email
ORDER BY lifetime_value DESC
LIMIT 100;

-- =============================================================================
-- TRANSACTION EXAMPLES
-- =============================================================================

-- Begin transaction
BEGIN;

-- Multiple operations that should succeed or fail together
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
INSERT INTO transactions (from_account, to_account, amount, created_at)
VALUES (1, 2, 100, NOW());

-- Commit if everything succeeded
COMMIT;

-- Or rollback if there was an error
-- ROLLBACK;

-- =============================================================================
-- NEON-SPECIFIC FEATURES
-- =============================================================================

-- Check current database size (useful for monitoring Neon usage)
SELECT pg_size_pretty(pg_database_size(current_database())) as database_size;

-- Monitor active connections
SELECT
    count(*) as connection_count,
    state,
    usename
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY state, usename;

-- Check for long-running queries
SELECT
    pid,
    now() - query_start as duration,
    state,
    query
FROM pg_stat_activity
WHERE state != 'idle'
    AND query_start < now() - interval '1 minute'
ORDER BY duration DESC;
