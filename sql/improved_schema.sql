-- ============================================================
-- REDESIGNED SCHEMA
-- Business requirements addressed:
--   1. Multiple products in one order  -> order_item table
--   2. Customer can have multiple addresses -> customer_address table
--   3. Customer can have multiple phone numbers -> customer_phone table
--   4. Store history of order status changes -> order_status_history table
-- ============================================================

-- ------------------------------------------------------------
-- 1. customer  (personal data only, no address/phone here)
-- ------------------------------------------------------------
CREATE TABLE customer (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(200) NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 2. customer_phone  (req #3 – multiple phones per customer)
-- ------------------------------------------------------------
CREATE TABLE customer_phone (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT      NOT NULL,
    phone       VARCHAR(30) NOT NULL,
    is_primary  BOOLEAN     NOT NULL DEFAULT FALSE,

    FOREIGN KEY (customer_id) REFERENCES customer(id)
);

-- ------------------------------------------------------------
-- 3. customer_address  (req #2 – multiple addresses per customer)
-- ------------------------------------------------------------
CREATE TABLE customer_address (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT       NOT NULL,
    address     VARCHAR(500) NOT NULL,
    is_primary  BOOLEAN      NOT NULL DEFAULT FALSE,

    FOREIGN KEY (customer_id) REFERENCES customer(id)
);

-- ------------------------------------------------------------
-- 4. product
-- ------------------------------------------------------------
CREATE TABLE product (
    id    BIGINT         AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(200)   NOT NULL,
    price DECIMAL(12, 2) NOT NULL
);

-- ------------------------------------------------------------
-- 5. customer_order  (head record; status = current status)
--    product_id and quantity are REMOVED – moved to order_item
-- ------------------------------------------------------------
CREATE TABLE customer_order (
    id                  BIGINT      AUTO_INCREMENT PRIMARY KEY,
    customer_id         BIGINT      NOT NULL,
    shipping_address_id BIGINT      NULL,          -- optional: which address to ship to
    status              VARCHAR(30) NOT NULL,
    created_at          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)         REFERENCES customer(id),
    FOREIGN KEY (shipping_address_id) REFERENCES customer_address(id)
);

-- ------------------------------------------------------------
-- 6. order_item  (req #1 – multiple products per order)
-- ------------------------------------------------------------
CREATE TABLE order_item (
    id         BIGINT         AUTO_INCREMENT PRIMARY KEY,
    order_id   BIGINT         NOT NULL,
    product_id BIGINT         NOT NULL,
    quantity   INT            NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,   -- price snapshot at the time of order

    FOREIGN KEY (order_id)   REFERENCES customer_order(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
);

-- ------------------------------------------------------------
-- 7. order_status_history  (req #4 – audit trail of statuses)
-- ------------------------------------------------------------
CREATE TABLE order_status_history (
    id         BIGINT      AUTO_INCREMENT PRIMARY KEY,
    order_id   BIGINT      NOT NULL,
    status     VARCHAR(30) NOT NULL,
    changed_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comment    VARCHAR(500) NULL,

    FOREIGN KEY (order_id) REFERENCES customer_order(id)
);
