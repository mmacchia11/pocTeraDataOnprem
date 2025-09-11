-- Data Warehouse setup (ClickHouse simulating Teradata DW)
-- This creates a columnar data warehouse structure

-- Create database
CREATE DATABASE IF NOT EXISTS sample_dw;

-- Use the database
USE sample_dw;

-- Dimension Tables (SCD Type 2 for DW)
CREATE TABLE dim_customers (
    customer_key UInt64,
    customer_id UInt32,
    customer_name String,
    email String,
    phone String,
    address String,
    city String,
    state String,
    country String,
    postal_code String,
    customer_type String,
    credit_limit Decimal(12,2),
    effective_date Date,
    expiry_date Date,
    is_current UInt8,
    created_date Date
) ENGINE = MergeTree()
ORDER BY (customer_key, effective_date);

CREATE TABLE dim_products (
    product_key UInt64,
    product_id UInt32,
    product_name String,
    category_id UInt32,
    category_name String,
    supplier_id UInt32,
    supplier_name String,
    unit_price Decimal(10,2),
    discontinued UInt8,
    effective_date Date,
    expiry_date Date,
    is_current UInt8
) ENGINE = MergeTree()
ORDER BY (product_key, effective_date);

CREATE TABLE dim_employees (
    employee_key UInt64,
    employee_id UInt32,
    first_name String,
    last_name String,
    title String,
    department_id UInt32,
    department_name String,
    manager_id Nullable(UInt32),
    salary Decimal(10,2),
    hire_date Date,
    effective_date Date,
    expiry_date Date,
    is_current UInt8
) ENGINE = MergeTree()
ORDER BY (employee_key, effective_date);

CREATE TABLE dim_date (
    date_key UInt32,
    date Date,
    year UInt16,
    quarter UInt8,
    month UInt8,
    day UInt8,
    day_of_week UInt8,
    day_name String,
    month_name String,
    is_weekend UInt8,
    is_holiday UInt8
) ENGINE = MergeTree()
ORDER BY date_key;

-- Fact Tables (Partitioned by date for DW performance)
CREATE TABLE fact_sales (
    sale_key UInt64,
    date_key UInt32,
    customer_key UInt64,
    product_key UInt64,
    employee_key UInt64,
    order_id UInt32,
    quantity UInt32,
    unit_price Decimal(10,2),
    discount Decimal(4,2),
    net_amount Decimal(12,2),
    gross_amount Decimal(12,2),
    cost_amount Decimal(12,2),
    profit_amount Decimal(12,2),
    sale_date Date,
    created_timestamp DateTime
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(sale_date)
ORDER BY (date_key, customer_key, product_key);

CREATE TABLE fact_inventory (
    inventory_key UInt64,
    date_key UInt32,
    product_key UInt64,
    movement_type String,
    quantity_in UInt32,
    quantity_out UInt32,
    quantity_balance UInt32,
    unit_cost Decimal(10,2),
    total_value Decimal(12,2),
    movement_date Date,
    created_timestamp DateTime
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(movement_date)
ORDER BY (date_key, product_key);

-- Aggregate Tables (Pre-calculated for DW performance)
CREATE TABLE agg_sales_monthly (
    year_month UInt32,
    customer_key UInt64,
    product_key UInt64,
    total_sales Decimal(15,2),
    total_quantity UInt64,
    total_orders UInt32,
    avg_order_value Decimal(10,2),
    total_profit Decimal(15,2),
    created_date Date
) ENGINE = SummingMergeTree()
PARTITION BY toYear(created_date)
ORDER BY (year_month, customer_key, product_key);

CREATE TABLE agg_sales_daily (
    date_key UInt32,
    total_sales Decimal(15,2),
    total_orders UInt32,
    total_customers UInt32,
    avg_order_value Decimal(10,2),
    created_timestamp DateTime
) ENGINE = ReplacingMergeTree()
ORDER BY date_key;

-- Customer Analytics (DW specific tables)
CREATE TABLE customer_lifetime_value (
    customer_key UInt64,
    first_purchase_date Date,
    last_purchase_date Date,
    total_orders UInt32,
    total_spent Decimal(15,2),
    avg_order_value Decimal(10,2),
    customer_segment String,
    ltv_score Decimal(8,2),
    calculated_date Date
) ENGINE = ReplacingMergeTree()
ORDER BY customer_key;

-- Product Performance (DW Analytics)
CREATE TABLE product_performance (
    product_key UInt64,
    year_month UInt32,
    units_sold UInt64,
    revenue Decimal(15,2),
    profit Decimal(15,2),
    profit_margin Decimal(5,4),
    rank_by_revenue UInt32,
    rank_by_profit UInt32,
    calculated_date Date
) ENGINE = ReplacingMergeTree()
PARTITION BY toYear(calculated_date)
ORDER BY (year_month, product_key);