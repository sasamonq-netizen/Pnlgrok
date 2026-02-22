-- Database schema for Pnlgrok

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE balance_log ENABLE ROW LEVEL SECURITY;

-- Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Services Table
CREATE TABLE services (
    service_id SERIAL PRIMARY KEY,
    category_id INT REFERENCES categories(category_id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Packages Table
CREATE TABLE packages (
    package_id SERIAL PRIMARY KEY,
    service_id INT REFERENCES services(service_id),
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    package_id INT REFERENCES packages(package_id),
    order_status VARCHAR(50), -- e.g., Pending, Completed, Refunded
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Balance Log Table
CREATE TABLE balance_log (
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    amount DECIMAL(10, 2),
    log_type VARCHAR(50), -- e.g., Deposit, Refund, Withdrawal
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deposits Table
CREATE TABLE deposits (
    deposit_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    amount DECIMAL(10, 2),
    status VARCHAR(50), -- e.g., Pending, Approved, Rejected
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin Audit Log Table
CREATE TABLE admin_audit_log (
    audit_id SERIAL PRIMARY KEY,
    admin_action VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Row Level Security Policies
CREATE POLICY user_policy ON users
    FOR SELECT
    USING (user_id = current_setting('app.current_user_id')::INT);

CREATE POLICY order_policy ON orders
    FOR SELECT
    USING (user_id = current_setting('app.current_user_id')::INT);

CREATE POLICY balance_log_policy ON balance_log
    FOR SELECT
    USING (user_id = current_setting('app.current_user_id')::INT);

-- Backend Functions
CREATE OR REPLACE FUNCTION approve_deposit(deposit_id INT) RETURNS VOID AS $$
BEGIN
    UPDATE deposits SET status = 'Approved' WHERE deposit_id = deposit_id;
    INSERT INTO balance_log (user_id, amount, log_type)
    SELECT user_id, amount, 'Deposit' FROM deposits WHERE deposit_id = deposit_id;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION refund_order(order_id INT) RETURNS VOID AS $$
BEGIN
    UPDATE orders SET order_status = 'Refunded' WHERE order_id = order_id;
    INSERT INTO balance_log (user_id, amount, log_type)
    SELECT user_id, price FROM orders JOIN packages ON orders.package_id = packages.package_id WHERE order_id = order_id;
END; $$ LANGUAGE plpgsql;

-- Add any other functions needed for atomic transactions.