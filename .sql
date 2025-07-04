-- =============================
-- Users & Roles
-- =============================

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password TEXT NOT NULL,
    role ENUM('SUPER_ADMIN', 'SUB_ADMIN', 'PHARMACY_OWNER', 'PHARMACY_STAFF', 'CASHIER', 'CUSTOMER') NOT NULL,
    pharmacy_id BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- =============================
-- Pharmacies (Multi-Tenant)
-- =============================

CREATE TABLE pharmacies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255),
    owner_id BIGINT NOT NULL,
    subscription_plan ENUM('FREE_TRIAL', 'ADVANCED', 'PREMIUM') NOT NULL DEFAULT 'FREE_TRIAL',
    subscription_status ENUM('ACTIVE', 'INACTIVE', 'EXPIRED') NOT NULL DEFAULT 'ACTIVE',
    subscription_start DATE,
    subscription_end DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id)
);

-- =============================
-- Subscription Payments (Chapa)
-- =============================

CREATE TABLE payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    pharmacy_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'Chapa',
    status ENUM('PENDING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_code VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id)
);

-- =============================
-- Inventory & Medicines
-- =============================

CREATE TABLE medicines (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100), -- e.g. Painkiller, Antibiotic
    stock INT DEFAULT 0,
    price DECIMAL(10,2),
    expiry_date DATE,
    barcode VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id)
);

-- =============================
-- Cosmetics (Optional Inventory)
-- =============================

CREATE TABLE cosmetics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    stock INT DEFAULT 0,
    price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id)
);

-- =============================
-- Sales & Transactions
-- =============================

CREATE TABLE sales (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_id BIGINT NOT NULL,
    cashier_id BIGINT NOT NULL,
    item_type ENUM('MEDICINE', 'COSMETIC') NOT NULL,
    item_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id),
    FOREIGN KEY (cashier_id) REFERENCES users(id)
);

-- =============================
-- Notifications
-- =============================

CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_id BIGINT NOT NULL,
    title VARCHAR(150),
    message TEXT,
    type ENUM('EXPIRY_ALERT', 'STOCK_ALERT', 'UNSOLD_ALERT', 'PANDEMIC_ALERT', 'SUBSCRIPTION_ALERT', 'NEW_FEATURE_ALERT') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id)
);

-- =============================
-- Customer Search Payments
-- =============================

CREATE TABLE customer_payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'Chapa',
    status ENUM('PENDING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
    paid_for_medicine_search BOOLEAN DEFAULT TRUE,
    medicine_quota_remaining INT DEFAULT 3,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id)
);

-- =============================
-- Medicine Search Logs (Per Payment)
-- =============================

CREATE TABLE medicine_searches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    medicine_name VARCHAR(150) NOT NULL,
    search_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id)
);
