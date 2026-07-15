-- =============================================================
-- ИСХОДНАЯ СХЕМА (до перепроектирования)
-- =============================================================

CREATE DATABASE IF NOT EXISTS shop_original;
USE shop_original;

CREATE TABLE customer (
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(200) NOT NULL,
    phone   VARCHAR(30)  NOT NULL,       -- только один телефон
    address VARCHAR(500) NOT NULL        -- плоская строка, не нормализована
);

CREATE TABLE product (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(200)   NOT NULL,
    price DECIMAL(12, 2) NOT NULL        -- нет истории цен
);

CREATE TABLE customer_order (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT       NOT NULL,
    product_id  BIGINT       NOT NULL,   -- только 1 товар на заказ!
    quantity    INT          NOT NULL,
    status      VARCHAR(30)  NOT NULL,   -- свободная строка, нет справочника
    created_at  DATETIME     NOT NULL,

    FOREIGN KEY (customer_id) REFERENCES customer(id),
    FOREIGN KEY (product_id)  REFERENCES product(id)
);
