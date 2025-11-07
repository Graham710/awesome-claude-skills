---
name: neon-sql-query
description: Expert guidance for executing SQL queries on Neon Postgres databases using the Neon MCP, with query optimization and best practices
---

# Neon SQL Query Skill

This skill provides expert guidance for executing SQL queries against Neon Postgres databases using the Neon MCP (Model Context Protocol) server.

## Overview

When this skill is active, you will use the Neon MCP tools to execute SQL queries efficiently and safely. This skill guides you on:

- Writing effective SQL queries for Neon databases
- Using Neon MCP tools properly
- Query optimization and performance best practices
- Neon-specific features and capabilities
- Error handling and troubleshooting
- Security and data protection

## Using Neon MCP Tools

The Neon MCP server provides tools for interacting with Neon databases. When executing queries:

1. **Always verify which MCP tools are available** - Check what Neon MCP tools you have access to
2. **Use the appropriate tool** - Different tools may be available for queries, schema inspection, etc.
3. **Handle errors gracefully** - Provide clear explanations when queries fail
4. **Format results clearly** - Present query results in a user-friendly format

## Query Best Practices

### Security First

1. **Never expose credentials** - Credentials are handled by the MCP server configuration
2. **Validate user input** - If constructing queries with user input, validate and sanitize
3. **Use appropriate permissions** - Understand that the MCP connection has specific permissions
4. **Be cautious with destructive operations** - Always confirm before DELETE or DROP operations

### Performance Optimization

1. **Use LIMIT for exploration** - When examining data, limit results:
   ```sql
   SELECT * FROM users LIMIT 10;
   ```

2. **Leverage indexes** - Check existing indexes and suggest new ones:
   ```sql
   -- Check existing indexes
   SELECT indexname, indexdef
   FROM pg_indexes
   WHERE tablename = 'users';

   -- Suggest indexes for common queries
   CREATE INDEX idx_users_email ON users(email);
   ```

3. **Use EXPLAIN for optimization**:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM orders
   WHERE created_at > '2024-01-01';
   ```

4. **Aggregate efficiently**:
   ```sql
   -- Good: Specific columns
   SELECT category, COUNT(*), AVG(price)
   FROM products
   GROUP BY category;

   -- Avoid: SELECT * with aggregation
   ```

### Query Patterns

#### Schema Exploration

Always start by understanding the database structure:

```sql
-- List all tables
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Examine table structure
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'your_table'
ORDER BY ordinal_position;

-- Check table relationships
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';
```

#### Data Analysis

```sql
-- Count and statistics
SELECT
    COUNT(*) as total_users,
    COUNT(DISTINCT email) as unique_emails,
    MIN(created_at) as first_signup,
    MAX(created_at) as latest_signup
FROM users;

-- Grouping and aggregation
SELECT
    DATE_TRUNC('day', created_at) as day,
    COUNT(*) as signups
FROM users
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day DESC;

-- Window functions for advanced analysis
SELECT
    user_id,
    order_date,
    amount,
    AVG(amount) OVER (PARTITION BY user_id) as user_avg,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date DESC) as recency_rank
FROM orders;
```

#### JOINs

```sql
-- INNER JOIN - matching records only
SELECT
    u.name,
    u.email,
    COUNT(o.id) as order_count,
    SUM(o.total) as total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.email
ORDER BY total_spent DESC;

-- LEFT JOIN - all records from left table
SELECT
    u.name,
    u.email,
    COALESCE(COUNT(o.id), 0) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.email;

-- Finding orphaned records
SELECT o.id, o.user_id
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL;
```

#### Common Table Expressions (CTEs)

Use CTEs for complex queries:

```sql
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) as month,
        SUM(amount) as revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
revenue_growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) as prev_month,
        revenue - LAG(revenue) OVER (ORDER BY month) as growth
    FROM monthly_revenue
)
SELECT
    month,
    revenue,
    growth,
    ROUND((growth / NULLIF(prev_month, 0)) * 100, 2) as growth_pct
FROM revenue_growth
ORDER BY month DESC;
```

## Neon-Specific Features

### Database Branching

Neon supports database branching for testing:

```sql
-- When working with branches, be aware of:
-- 1. Which branch you're connected to
-- 2. Data isolation between branches
-- 3. Schema changes may need to be applied to multiple branches
```

### Connection Pooling

Neon provides connection pooling. Consider:

- Pooled connections for application use
- Direct connections for admin tasks
- Connection limits and management

### Autoscaling

Neon automatically scales compute. Be aware:

- Query performance may vary with load
- Complex queries benefit from compute scaling
- Monitor query performance in Neon console

### Point-in-Time Recovery

Queries can reference historical data:

```sql
-- Neon supports querying historical states
-- Check Neon documentation for syntax
```

## Data Modification

### INSERT Operations

```sql
-- Single record
INSERT INTO users (name, email, created_at)
VALUES ('John Doe', 'john@example.com', NOW())
RETURNING id, created_at;

-- Multiple records
INSERT INTO products (name, category, price)
VALUES
    ('Product A', 'electronics', 299.99),
    ('Product B', 'electronics', 199.99)
RETURNING id, name;

-- Upsert (INSERT ... ON CONFLICT)
INSERT INTO user_stats (user_id, login_count, last_login)
VALUES ($1, 1, NOW())
ON CONFLICT (user_id)
DO UPDATE SET
    login_count = user_stats.login_count + 1,
    last_login = NOW()
RETURNING *;
```

### UPDATE Operations

```sql
-- Simple update
UPDATE products
SET price = price * 1.1
WHERE category = 'electronics'
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

-- Conditional update
UPDATE products
SET
    stock_status = CASE
        WHEN stock_quantity = 0 THEN 'out_of_stock'
        WHEN stock_quantity < 10 THEN 'low_stock'
        ELSE 'in_stock'
    END
WHERE category = 'electronics';
```

### DELETE Operations

**Always be cautious with DELETE!**

```sql
-- Delete with conditions
DELETE FROM logs
WHERE created_at < NOW() - INTERVAL '90 days'
RETURNING id, created_at;

-- Safe pattern: Test with SELECT first
-- Step 1: Test the condition
SELECT id, created_at
FROM logs
WHERE created_at < NOW() - INTERVAL '90 days'
LIMIT 10;

-- Step 2: If confirmed, execute delete
DELETE FROM logs
WHERE created_at < NOW() - INTERVAL '90 days';
```

## Error Handling

### Common Errors

**Syntax Errors**
- Check SQL syntax carefully
- Verify table and column names exist
- Ensure proper quote usage (single quotes for strings)

**Permission Errors**
- Verify MCP connection has necessary permissions
- Check if operation is allowed on the table
- Confirm user role has required privileges

**Connection Errors**
- The MCP server handles connections
- If connection fails, check MCP server configuration
- Verify Neon database is active

**Timeout Errors**
- Query is taking too long
- Optimize with indexes or limit result set
- Consider breaking into smaller queries

### Troubleshooting Steps

1. **Verify table exists**:
   ```sql
   SELECT table_name
   FROM information_schema.tables
   WHERE table_name = 'your_table';
   ```

2. **Check column names**:
   ```sql
   SELECT column_name
   FROM information_schema.columns
   WHERE table_name = 'your_table';
   ```

3. **Test with simple query**:
   ```sql
   SELECT * FROM your_table LIMIT 1;
   ```

4. **Use EXPLAIN for slow queries**:
   ```sql
   EXPLAIN ANALYZE your_slow_query;
   ```

## Response Formatting

When presenting query results:

1. **Use tables for structured data** - Format results clearly
2. **Highlight key findings** - Point out important insights
3. **Explain what the query does** - Help users understand the logic
4. **Suggest next steps** - Offer relevant follow-up queries
5. **Show row counts** - Indicate how many results were returned

Example response format:
```
I've queried the users table and found 1,247 total users.

Here are the top 10 most recent signups:

[formatted table]

Key insights:
- 45 users signed up in the last 24 hours
- Average signup time is 3:00 PM UTC
- Most users are from the US (67%)

Would you like me to:
- Analyze user activity patterns?
- Check user engagement metrics?
- Examine signup trends over time?
```

## Data Validation

### Finding Data Issues

```sql
-- Duplicate detection
SELECT email, COUNT(*) as count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- NULL value analysis
SELECT
    COUNT(*) as total,
    COUNT(column_name) as non_null,
    COUNT(*) - COUNT(column_name) as null_count
FROM table_name;

-- Orphaned records
SELECT c.id
FROM child_table c
LEFT JOIN parent_table p ON c.parent_id = p.id
WHERE p.id IS NULL;

-- Value distribution
SELECT
    column_name,
    COUNT(*) as frequency,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM table_name
GROUP BY column_name
ORDER BY frequency DESC;
```

## Transaction Management

While the MCP handles connection management, understand transaction concepts:

```sql
-- Transactions ensure atomicity
BEGIN;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
INSERT INTO transactions (from_id, to_id, amount) VALUES (1, 2, 100);

COMMIT;  -- or ROLLBACK if there's an error
```

Note: Check if the Neon MCP supports explicit transaction control through its tools.

## Workflow

When a user requests data or analysis:

1. **Understand the request** - Clarify what data is needed
2. **Explore the schema** - Identify relevant tables and columns
3. **Write the query** - Construct appropriate SQL
4. **Execute using MCP** - Use available Neon MCP tools
5. **Format results** - Present data clearly
6. **Provide insights** - Explain what the data shows
7. **Offer next steps** - Suggest follow-up queries or actions

## Resources

Reference these for complex queries:

- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Neon Documentation**: https://neon.tech/docs
- **SQL Best Practices**: Focus on clarity, performance, and security
- **Query Optimization**: Use EXPLAIN, indexes, and efficient patterns

## Important Reminders

- ✅ Always explore schema before writing complex queries
- ✅ Use LIMIT when exploring unfamiliar data
- ✅ Test DELETE/UPDATE operations with SELECT first
- ✅ Format results clearly for users
- ✅ Explain query logic and findings
- ✅ Suggest optimizations when queries are slow
- ✅ Be cautious with destructive operations
- ✅ Leverage Neon's PostgreSQL compatibility
- ❌ Never expose connection strings or credentials
- ❌ Don't execute destructive queries without confirmation
- ❌ Avoid SELECT * on large tables without LIMIT
