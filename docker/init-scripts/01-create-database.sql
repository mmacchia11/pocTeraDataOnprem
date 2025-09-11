-- Initial database setup (PostgreSQL simulating Teradata)
-- This script creates a sample database structure

-- Create admin user with fixed password
CREATE USER admin_user WITH PASSWORD 'root';

-- Create application user with generated password  
CREATE USER app_user WITH PASSWORD 'app_pass';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE sample_db TO admin_user;
GRANT CONNECT ON DATABASE sample_db TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL SEQUENCES IN SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON SEQUENCES TO app_user;

-- Create sample table structure (empty, data will be mounted from other repos)
DATABASE sample_db;

-- Core business entities
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    customer_type VARCHAR(20),
    credit_limit DECIMAL(12,2),
    created_date DATE,
    last_updated TIMESTAMP
) PRIMARY INDEX (customer_id);

CREATE TABLE products (
    product_id INTEGER NOT NULL,
    product_name VARCHAR(100),
    category_id INTEGER,
    supplier_id INTEGER,
    unit_price DECIMAL(10,2),
    units_in_stock INTEGER,
    units_on_order INTEGER,
    reorder_level INTEGER,
    discontinued CHAR(1),
    created_date DATE
) PRIMARY INDEX (product_id);

CREATE TABLE categories (
    category_id INTEGER NOT NULL,
    category_name VARCHAR(50),
    description VARCHAR(200)
) PRIMARY INDEX (category_id);

CREATE TABLE suppliers (
    supplier_id INTEGER NOT NULL,
    supplier_name VARCHAR(100),
    contact_name VARCHAR(50),
    contact_title VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100)
) PRIMARY INDEX (supplier_id);

-- Transactional tables
CREATE TABLE orders (
    order_id INTEGER NOT NULL,
    customer_id INTEGER,
    employee_id INTEGER,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via INTEGER,
    freight DECIMAL(10,2),
    ship_name VARCHAR(100),
    ship_address VARCHAR(200),
    ship_city VARCHAR(50),
    ship_region VARCHAR(50),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(50),
    order_status VARCHAR(20),
    total_amount DECIMAL(12,2)
) PRIMARY INDEX (order_id);

CREATE TABLE order_details (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    unit_price DECIMAL(10,2),
    quantity INTEGER,
    discount DECIMAL(4,2)
) PRIMARY INDEX (order_id, product_id);

-- Employee and organizational structure
CREATE TABLE employees (
    employee_id INTEGER NOT NULL,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(50),
    title_of_courtesy VARCHAR(10),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(200),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    home_phone VARCHAR(20),
    extension VARCHAR(10),
    reports_to INTEGER,
    salary DECIMAL(10,2),
    department_id INTEGER
) PRIMARY INDEX (employee_id);

CREATE TABLE departments (
    department_id INTEGER NOT NULL,
    department_name VARCHAR(50),
    manager_id INTEGER,
    budget DECIMAL(12,2),
    location VARCHAR(100)
) PRIMARY INDEX (department_id);

-- Shipping and logistics
CREATE TABLE shippers (
    shipper_id INTEGER NOT NULL,
    company_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
) PRIMARY INDEX (shipper_id);

-- Financial and analytical tables
CREATE TABLE sales_summary (
    summary_id INTEGER NOT NULL,
    year_month INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    category_id INTEGER,
    total_sales DECIMAL(15,2),
    total_quantity INTEGER,
    total_orders INTEGER,
    avg_order_value DECIMAL(10,2)
) PRIMARY INDEX (summary_id);

CREATE TABLE inventory_movements (
    movement_id INTEGER NOT NULL,
    product_id INTEGER,
    movement_type VARCHAR(20),
    quantity INTEGER,
    unit_cost DECIMAL(10,2),
    movement_date DATE,
    reference_id INTEGER,
    notes VARCHAR(200)
) PRIMARY INDEX (movement_id);

-- Customer relationship management
CREATE TABLE customer_interactions (
    interaction_id INTEGER NOT NULL,
    customer_id INTEGER,
    employee_id INTEGER,
    interaction_type VARCHAR(30),
    interaction_date TIMESTAMP,
    subject VARCHAR(100),
    notes VARCHAR(500),
    follow_up_date DATE
) PRIMARY INDEX (interaction_id);

-- Foreign Key relationships (Teradata uses REFERENCES for documentation)
-- Products -> Categories
ALTER TABLE products ADD CONSTRAINT fk_products_category 
    FOREIGN KEY (category_id) REFERENCES categories(category_id);

-- Products -> Suppliers  
ALTER TABLE products ADD CONSTRAINT fk_products_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id);

-- Orders -> Customers
ALTER TABLE orders ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Orders -> Employees
ALTER TABLE orders ADD CONSTRAINT fk_orders_employee
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

-- Orders -> Shippers
ALTER TABLE orders ADD CONSTRAINT fk_orders_shipper
    FOREIGN KEY (ship_via) REFERENCES shippers(shipper_id);

-- Order Details -> Orders
ALTER TABLE order_details ADD CONSTRAINT fk_order_details_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Order Details -> Products
ALTER TABLE order_details ADD CONSTRAINT fk_order_details_product
    FOREIGN KEY (product_id) REFERENCES products(product_id);

-- Employees -> Employees (self-reference for manager)
ALTER TABLE employees ADD CONSTRAINT fk_employees_manager
    FOREIGN KEY (reports_to) REFERENCES employees(employee_id);

-- Employees -> Departments
ALTER TABLE employees ADD CONSTRAINT fk_employees_department
    FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- Departments -> Employees (manager)
ALTER TABLE departments ADD CONSTRAINT fk_departments_manager
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- Sales Summary -> Customers
ALTER TABLE sales_summary ADD CONSTRAINT fk_sales_summary_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Sales Summary -> Products
ALTER TABLE sales_summary ADD CONSTRAINT fk_sales_summary_product
    FOREIGN KEY (product_id) REFERENCES products(product_id);

-- Sales Summary -> Categories
ALTER TABLE sales_summary ADD CONSTRAINT fk_sales_summary_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id);

-- Inventory Movements -> Products
ALTER TABLE inventory_movements ADD CONSTRAINT fk_inventory_movements_product
    FOREIGN KEY (product_id) REFERENCES products(product_id);

-- Customer Interactions -> Customers
ALTER TABLE customer_interactions ADD CONSTRAINT fk_customer_interactions_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Customer Interactions -> Employees
ALTER TABLE customer_interactions ADD CONSTRAINT fk_customer_interactions_employee
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id);