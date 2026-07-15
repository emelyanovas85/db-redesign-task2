# Задание 2 — Перепроектирование схемы БД

## Структура репозитория

```
├── sql/
│   ├── original_schema.sql      — исходная схема
│   ├── improved_schema.sql      — улучшенная схема
│   └── sample_data.sql          — тестовые данные
└── docs/
    └── REDESIGN.md              — обоснование изменений
```

## Обзор изменений

| Аспект | До | После |
|---|---|---|
| Телефон клиента | VARCHAR(30) в customer | Отдельная таблица `customer_phone` (1:N) |
| Адрес клиента | VARCHAR(500) в customer | Отдельная таблица `address` (нормализована) |
| Цена товара | DECIMAL в product | + таблица `price_history` (история цен) |
| Заказ | 1 строка = 1 товар | Заказ + позиции `order_item` (M:N через join-table) |
| Статус заказа | VARCHAR(30) | Таблица-справочник `order_status` |
| Аудит | Нет | `created_at` / `updated_at` на всех сущностях |

## Запуск

```bash
mysql -u root -p < sql/improved_schema.sql
mysql -u root -p shop < sql/sample_data.sql
```
