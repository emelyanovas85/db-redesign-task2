-- =============================================================
-- Тестовые данные для улучшенной схемы
-- =============================================================
USE shop;

-- Клиенты
INSERT INTO customer (name, email) VALUES
    ('Иван Петров',    'ivan@example.com'),
    ('Мария Сидорова', 'maria@example.com');

-- Телефоны
INSERT INTO customer_phone (customer_id, phone, is_primary) VALUES
    (1, '+7-921-000-0001', 1),
    (1, '+7-812-123-4567', 0),
    (2, '+7-921-000-0002', 1);

-- Адреса
INSERT INTO address (city, street, building, postal_code) VALUES
    ('Санкт-Петербург', 'Невский проспект',   '1',  '190000'),
    ('Санкт-Петербург', 'ул. Ленина',          '5',  '190001');

-- Привязка клиентов к адресам
INSERT INTO customer_address (customer_id, address_id, type, is_default) VALUES
    (1, 1, 'HOME', 1),
    (2, 2, 'HOME', 1);

-- Товары
INSERT INTO product (name, sku, description) VALUES
    ('Ноутбук ASUS X15', 'ASUS-X15-001', '15.6", Core i5, 16 GB RAM'),
    ('Мышь Logitech MX', 'LOG-MX-002',  'Беспроводная, 4000 dpi');

-- История цен
INSERT INTO price_history (product_id, price, effective_from) VALUES
    (1, 75000.00, '2024-01-01 00:00:00'),
    (1, 72000.00, '2024-06-01 00:00:00'),
    (2,  5500.00, '2024-01-01 00:00:00'),
    (2,  4990.00, '2024-09-01 00:00:00');

-- Заказ №1 (два товара)
INSERT INTO customer_order (customer_id, delivery_address, order_status_id) VALUES
    (1, 1, 2);  -- статус CONFIRMED

INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 72000.00),
    (1, 2, 2,  4990.00);

-- Заказ №2
INSERT INTO customer_order (customer_id, delivery_address, order_status_id) VALUES
    (2, 2, 1);  -- статус PENDING

INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES
    (2, 2, 1, 4990.00);

-- -----------------------------------------------------------
-- Полезные запросы
-- -----------------------------------------------------------

-- Текущая цена товара
-- SELECT p.name, ph.price
-- FROM product p
-- JOIN price_history ph ON ph.product_id = p.id
-- WHERE ph.effective_from = (
--     SELECT MAX(effective_from) FROM price_history WHERE product_id = p.id
-- );

-- Сумма заказа
-- SELECT co.id, SUM(oi.quantity * oi.unit_price) AS total
-- FROM customer_order co
-- JOIN order_item oi ON oi.order_id = co.id
-- GROUP BY co.id;
