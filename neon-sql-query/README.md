# Neon SQL Query Skill

A Claude skill that provides expert guidance for executing SQL queries on Neon Postgres databases using the Neon MCP (Model Context Protocol).

## Overview

This skill teaches Claude how to effectively interact with Neon databases through the Neon MCP server. It provides:

- ✅ SQL query best practices and patterns
- ✅ Query optimization guidance
- ✅ Neon-specific feature knowledge
- ✅ Error handling strategies
- ✅ Security and safety guidelines
- ✅ Comprehensive SQL examples

## What This Skill Does

When this skill is active, Claude will:

1. **Use Neon MCP tools properly** - Execute queries through the MCP server
2. **Explore schemas first** - Understand database structure before querying
3. **Write optimized queries** - Follow best practices for performance
4. **Format results clearly** - Present data in user-friendly formats
5. **Provide insights** - Explain what the data shows and suggest next steps
6. **Handle errors gracefully** - Troubleshoot issues and explain problems
7. **Ensure safety** - Confirm destructive operations before executing

## Prerequisites

To use this skill, you need:

1. **Neon Account** - Sign up at https://neon.tech
2. **Neon MCP Server** - Configured and running
3. **Claude with MCP support** - Claude Code, Claude Desktop, or API with MCP

## Setup

### 1. Install the Neon MCP Server

Follow the official Neon MCP documentation to set up the MCP server:
- https://neon.tech/docs/mcp

### 2. Configure Connection

The Neon MCP server handles database connections. Configure it with your Neon database connection string:

```
postgresql://[user]:[password]@[host]/[database]?sslmode=require
```

Find your connection string in the Neon console:
1. Go to https://console.neon.tech
2. Select your project
3. Navigate to "Connection Details"
4. Copy the connection string

### 3. Enable the Skill

Add this skill to Claude using your preferred method:
- Claude Code: `/plugin add /path/to/neon-sql-query`
- Claude Desktop: Add via Skills settings
- API: Use the Skills API endpoint

## Usage Examples

Once the skill is loaded and the Neon MCP is configured, you can ask Claude:

### Schema Exploration
- "Show me all tables in the database"
- "Describe the structure of the users table"
- "What are the relationships between tables?"

### Data Queries
- "Find the 10 most recent orders"
- "Show me users who signed up in the last 30 days"
- "Calculate total revenue by product category"
- "Find duplicate email addresses in the users table"

### Data Analysis
- "Analyze user signup trends over the past 3 months"
- "Show me the top 20 customers by total spend"
- "Calculate monthly revenue growth"
- "Identify inactive users who haven't logged in for 90 days"

### Data Modification
- "Add a new user with email john@example.com"
- "Update product prices in the electronics category by 10%"
- "Delete log entries older than 90 days"

### Performance Optimization
- "Explain the query plan for this slow query"
- "Suggest indexes to improve query performance"
- "Optimize this complex JOIN query"

## What's Included

### SKILL.md
The main skill file containing comprehensive guidance on:
- Using Neon MCP tools
- SQL query patterns (SELECT, INSERT, UPDATE, DELETE)
- Query optimization techniques
- Neon-specific features (branching, autoscaling, etc.)
- Error handling and troubleshooting
- Security best practices
- Result formatting guidelines

### example_queries.sql
A comprehensive collection of SQL examples including:
- Database schema inspection
- Data analysis patterns
- JOIN operations
- Window functions
- Common Table Expressions (CTEs)
- Data modification operations
- Performance optimization queries
- Data validation queries
- Reporting and analytics examples

## Key Features

### Intelligent Query Writing

Claude will:
- Explore the database schema before writing queries
- Use appropriate SQL patterns for the task
- Apply LIMIT when exploring data
- Leverage indexes for performance
- Use window functions for advanced analysis

### Safety First

Claude will:
- Always confirm before DELETE or DROP operations
- Test UPDATE/DELETE queries with SELECT first
- Never expose credentials
- Validate destructive operations
- Use appropriate permissions

### Clear Communication

Claude will:
- Format query results in readable tables
- Explain what each query does
- Provide insights from the data
- Suggest follow-up queries
- Help troubleshoot errors

### Neon-Optimized

Claude understands:
- Database branching for testing
- Connection pooling strategies
- Autoscaling behavior
- Point-in-time recovery
- Neon-specific best practices

## Example Workflow

1. **User**: "Show me how many orders were placed last month"

2. **Claude**:
   - Explores schema to find the orders table
   - Checks date columns available
   - Writes optimized query
   - Executes via Neon MCP
   - Presents results with insights

3. **Claude's Response**:
   ```
   I've queried the orders table for last month's data.

   Total orders placed in October 2024: 1,847

   Breakdown by status:
   - Completed: 1,654 (89.5%)
   - Processing: 128 (6.9%)
   - Cancelled: 65 (3.5%)

   Would you like me to:
   - Compare this to previous months?
   - Analyze order trends by day of week?
   - Break down by product category?
   ```

## Neon-Specific Capabilities

### Database Branching
- Query different branches for testing
- Understand data isolation between branches
- Manage schema changes across branches

### Performance
- Leverage Neon's autoscaling
- Understand compute scaling impact
- Optimize for serverless Postgres
- Monitor query performance

### Modern Postgres Features
- Full PostgreSQL compatibility
- Latest Postgres version support
- Advanced SQL features (CTEs, window functions, etc.)
- JSON/JSONB support

## Best Practices

The skill teaches Claude to:

1. **Explore Before Querying** - Always understand the schema first
2. **Start Small** - Use LIMIT when exploring unfamiliar data
3. **Optimize Queries** - Use EXPLAIN for slow queries
4. **Index Appropriately** - Suggest indexes for common queries
5. **Format Results** - Present data clearly to users
6. **Provide Context** - Explain what the data means
7. **Suggest Actions** - Recommend next steps
8. **Handle Errors** - Troubleshoot and explain problems
9. **Ensure Safety** - Confirm destructive operations
10. **Leverage Neon** - Use Neon-specific features effectively

## Troubleshooting

### Skill Not Loading
- Verify SKILL.md has proper frontmatter
- Check skill is in Claude's skills directory
- Restart Claude after adding the skill

### MCP Connection Issues
- Verify Neon MCP server is running
- Check connection string in MCP configuration
- Ensure Neon database is active
- Confirm network connectivity

### Query Errors
- Check table and column names exist
- Verify SQL syntax is correct
- Ensure user has required permissions
- Review error messages for details

## Resources

- **Neon Documentation**: https://neon.tech/docs
- **Neon MCP Setup**: https://neon.tech/docs/mcp
- **PostgreSQL Docs**: https://www.postgresql.org/docs/
- **SQL Tutorial**: https://www.postgresql.org/docs/current/tutorial.html
- **Query Optimization**: https://www.postgresql.org/docs/current/performance-tips.html

## Advanced Usage

### Complex Analytics

Ask Claude to:
- Build cohort analysis queries
- Calculate customer lifetime value
- Analyze time-series data
- Create pivot table queries
- Generate reports with CTEs

### Performance Tuning

Ask Claude to:
- Analyze slow query logs
- Suggest index strategies
- Optimize JOIN operations
- Refactor complex queries
- Use EXPLAIN ANALYZE

### Data Integrity

Ask Claude to:
- Find duplicate records
- Identify orphaned data
- Validate referential integrity
- Check for NULL values
- Analyze data quality

## Contributing

Suggestions for improvements are welcome! Consider:
- Additional query patterns
- More Neon-specific guidance
- Enhanced error handling
- Additional examples
- Performance optimization tips

## License

This skill is provided as-is for use with Claude. Modify and distribute as needed.

## Acknowledgments

Built for the Claude Skills ecosystem. Designed to work seamlessly with the Neon MCP server for powerful database interactions.
