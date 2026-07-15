-- =============================================================
-- УЛУЧШЕННАЯ СХЕМА (после перепроектирования)
-- =============================================================
-- Изменения:
--   1. customer_phone  — несколько телефонов на клиента (1:N)
--   2. address         — нормализованный адрес, переиспользуется
--   3. customer_address — связь клиент ↔ адрес (M:N, тип адреса)
--   4. price_history   — история изменения цен товара
--   5. order_status    — справочник статусов заказа
--   6. customer_order  — заказ теперь «шапка» (без product_id)
--   7. order_item      — позиции заказа (M:N товар–заказ)
--   8. updated_at      — аудит на всех основных таблицах
-- =============================================================

CREATE DATABASE IF NOT EXISTS shop;
USE shop;

-- -----------------------------------------------------------
-- 1. Клиент
-- -----------------------------------------------------------
CREATE TABLE customer (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(200) NOT NULL,
    email      VARCHAR(255)          UNIQUE,          -- добавлен email
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP
);

-- Несколько телефонов на одного клиента
CREATE TABLE customer_phone (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT      NOT NULL,
    phone       VARCHAR(30) NOT NULL,
    is_primary  TINYINT(1)  NOT NULL DEFAULT 0,       -- основной номер
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE
);

-- -----------------------------------------------------------
-- 2. Нормализованный адрес
-- -----------------------------------------------------------
CREATE TABLE address (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    country     VARCHAR(100) NOT NULL DEFAULT 'Россия',
    city        VARCHAR(100) NOT NULL,
    street      VARCHAR(255) NOT NULL,
    building    VARCHAR(20)  NOT NULL,
    apartment   VARCHAR(20),
    postal_code VARCHAR(20)
);

-- Клиент может иметь несколько адресов (дом, офис и т.д.)
CREATE TABLE customer_address (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT      NOT NULL,
    address_id  BIGINT      NOT NULL,
    type        ENUM('HOME','WORK','OTHER') NOT NULL DEFAULT 'HOME',
    is_default  TINYINT(1)  NOT NULL DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE,
    FOREIGN KEY (address_id)  REFERENCES address(id)
);

-- -----------------------------------------------------------
-- 3. Товар
-- -----------------------------------------------------------
CREATE TABLE product (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(200)   NOT NULL,
    description TEXT,
    sku         VARCHAR(100)   UNIQUE,                -- артикул
    created_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- Текущая цена — последняя запись по effective_from
CREATE TABLE price_history (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id     BIGINT         NOT NULL,
    price          DECIMAL(12, 2) NOT NULL,
    effective_from DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE,
    INDEX idx_ph_product_date (product_id, effective_from)
);

-- -----------------------------------------------------------
-- 4. Справочник статусов заказа
-- -----------------------------------------------------------
CREATE TABLE order_status (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(30)  NOT NULL UNIQUE,
    description VARCHAR(255)
);

INSERT INTO order_status (code, description) VALUES
    ('PENDING',    'Ожидает обработки'),
    ('CONFIRMED',  'Подтверждён'),
    ('SHIPPED',    'Отправлен'),
    ('DELIVERED',  'Доставлен'),
    ('CANCELLED',  'Отменён'),
    ('RETURNED',   'Возврат');

-- -----------------------------------------------------------
-- 5. Заказ (шапка)
-- -----------------------------------------------------------
CREATE TABLE customer_order (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id      BIGINT   NOT NULL,
    delivery_address BIGINT,                          -- FK → address
    order_status_id  INT      NOT NULL DEFAULT 1,
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                                       ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)      REFERENCES customer(id),
    FOREIGN KEY (delivery_address) REFERENCES address(id),
    FOREIGN KEY (order_status_id)  REFERENCES order_status(id)
);

-- -----------------------------------------------------------
-- 6. Позиции заказа (order lines)
-- -----------------------------------------------------------
CREATE TABLE order_item (
    id         BIGINT         AUTO_INCREMENT PRIMARY KEY,
    order_id   BIGINT         NOT NULL,
    product_id BIGINT         NOT NULL,
    quantity   INT            NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL,               -- цена на момент заказа

    FOREIGN KEY (order_id)   REFERENCES customer_order(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(id),
    UNIQUE KEY uq_order_product (order_id, product_id)
);

-- -----------------------------------------------------------
-- Полезные индексы
-- -----------------------------------------------------------
CREATE INDEX idx_order_customer    ON customer_order(customer_id);
CREATE INDEX idx_order_status      ON customer_order(order_status_id);
CREATE INDEX idx_order_item_order  ON order_item(order_id);
CREATE INDEX idx_order_item_prod   ON order_item(product_id);
