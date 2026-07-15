-- ============================================================
-- ORIGINAL SCHEMA (before redesign)
-- ============================================================

CREATE TABLE customer (
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(200) NOT NULL,
    phone   VARCHAR(30)  NOT NULL,
    address VARCHAR(500) NOT NULL
);

CREATE TABLE product (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(200)    NOT NULL,
    price DECIMAL(12, 2)  NOT NULL
);

CREATE TABLE customer_order (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT       NOT NULL,
    product_id  BIGINT       NOT NULL,
    quantity    INT          NOT NULL,
    status      VARCHAR(30)  NOT NULL,
    created_at  DATETIME     NOT NULL,

    FOREIGN KEY (customer_id) REFERENCES customer(id),
    FOREIGN KEY (product_id)  REFERENCES product(id)
);
