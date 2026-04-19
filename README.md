# FreshMart Retail Insights (SQL Use Case)

This repository contains a self-contained SQL script (`freshmart.sql`) that creates a small retail dataset for **FreshMart** and runs a few analytics queries to generate inventory and revenue insights.

## Contents

- `freshmart.sql`
  - Creates tables for categories, products, and sales transactions
  - Inserts sample (dummy) data
  - Runs analytical queries:
    - Expiring Soon inventory
    - Dead Stock detection
    - Revenue Contribution by category (last month)

## Database Compatibility

The script is written for **PostgreSQL** (uses `SERIAL`, `INTERVAL`, and `date_trunc`).

## Schema Overview

### Tables

- **categories**
  - `category_id` (PK)
  - `category_name`

- **products**
  - `product_id` (PK)
  - `category_id` (FK → `categories.category_id`)
  - `product_name`
  - `unit_price`
  - `stock_count`
  - `expiry_date`

- **sales_transactions**
  - `sale_id` (PK)
  - `product_id` (FK → `products.product_id`)
  - `quantity`
  - `sale_price`
  - `transaction_date`

## What the Script Does

1. **Creates tables**
   - `categories`, `products`, `sales_transactions`

2. **Loads sample data**
   - Several product categories (Dairy, Bakery, Beverages, Produce, Snacks, Frozen)
   - Example products with expiry dates relative to `CURRENT_DATE`
   - Example sales transactions across recent days and previous months

3. **Runs insight queries**

### 1) Expiring Soon (High Stock)

Finds products that:
- expire within the next 7 days (from `CURRENT_DATE`)
- have stock greater than 50

This helps identify items that may require markdowns, promotions, or urgent replenishment adjustments.

### 2) Dead Stock (No Sales in Last 2 Months)

Finds products with **no sales transactions in the last 2 months**.

This helps identify slow-moving inventory and potential assortment issues.

### 3) Revenue Contribution (Last Month)

Computes total revenue by category for the **previous calendar month**, ordered by highest revenue.

This helps understand which categories drove revenue most recently.

## How to Run

### Option A: psql (PostgreSQL CLI)

1. Create a database (optional example):
   ```bash
   createdb freshmart
   ```

2. Run the script:
   ```bash
   psql -d freshmart -f freshmart.sql
   ```

### Option B: Any PostgreSQL client

- Open `freshmart.sql` in your SQL editor (DBeaver, DataGrip, pgAdmin, etc.)
- Execute the script

## Notes

- The dataset uses `CURRENT_DATE` for expiry and transaction timing, so results will vary depending on the day you run the script.
- If you re-run the script, consider uncommenting the `DROP TABLE IF EXISTS ...` statements at the top to reset the schema cleanly.
