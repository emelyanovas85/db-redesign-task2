# Обоснование перепроектирования

## Проблемы исходной схемы

### 1. Нарушение 1НФ — множественные значения в поле

Поле `customer.phone VARCHAR(30)` допускает хранение только **одного** номера,
что не отражает реальность (у клиента может быть несколько контактов).

**Решение:** отдельная таблица `customer_phone` (1:N).

### 2. Нарушение 2НФ — денормализованный адрес

`customer.address VARCHAR(500)` — плоская строка без структуры:
- Нельзя выполнить поиск по городу/улице
- Нельзя переиспользовать адрес (например, доставку)
- Нет проверки формата

**Решение:** таблица `address` (country, city, street, building, apartment, postal_code) +
связующая `customer_address` с типом адреса.

### 3. Один заказ — один товар

`customer_order` содержит `product_id` и `quantity` — заказ физически не
может включать несколько позиций без дублирования строки.

**Решение:** разделить на
- `customer_order` — «шапка» заказа (клиент, адрес, статус, время)
- `order_item` — строки заказа (товар, кол-во, цена на момент заказа)

Это классическая схема Order / Order Line.

### 4. Нет истории цен

`product.price` перезаписывается при изменении цены. Исторические заказы
теряют реальную стоимость покупки.

**Решение:** таблица `price_history` (product_id, price, effective_from).
В `order_item.unit_price` фиксируется цена **на момент заказа**.

### 5. Статус — свободная строка

`status VARCHAR(30)` допускает произвольный текст, нет ограничений.

**Решение:** справочник `order_status` с кодами и описаниями. FK гарантирует
целостность.

### 6. Отсутствие аудита

В исходной схеме `created_at` только в заказе. Нет `updated_at`.

**Решение:** `created_at` + `updated_at DEFAULT ... ON UPDATE CURRENT_TIMESTAMP`
на всех основных таблицах.

---

## ER-диаграмма (текстовая)

```
customer (1) ──< customer_phone
customer (1) ──< customer_address >── address
customer (1) ──< customer_order
customer_order >── order_status
customer_order (1) ──< order_item >── product
product (1) ──< price_history
customer_order >── address  (delivery_address)
```

---

## Нормальные формы

| Таблица | 1НФ | 2НФ | 3НФ |
|---|---|---|---|
| customer | ✅ | ✅ | ✅ |
| customer_phone | ✅ | ✅ | ✅ |
| address | ✅ | ✅ | ✅ |
| product | ✅ | ✅ | ✅ |
| price_history | ✅ | ✅ | ✅ |
| order_status | ✅ | ✅ | ✅ |
| customer_order | ✅ | ✅ | ✅ |
| order_item | ✅ | ✅ | ✅ |
