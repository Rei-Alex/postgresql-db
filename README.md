# Hospital Information System — PostgreSQL Database

Проектирование реляционной базы данных и серверной логики на **PostgreSQL / PL/pgSQL** для информационной системы медицинского учреждения.

## Структура репозитория
* `01_create_tables.sql` — DDL-скрипт создания 8 нормализованных таблиц с ограничениями целостности (`PRIMARY KEY`, `FOREIGN KEY`, `IDENTITY`).
* `02_insert_data.sql` — DML-скрипт наполнения справочников и связующих таблиц тестовыми данными.
* `03_queries.sql` — 30 аналитических запросов (`INNER JOIN`, фильтрация, агрегации, `GROUP BY`, `HAVING`).
* `04_views_json_functions_triggers.sql` — представления (`VIEW`, `MATERIALIZED VIEW`), работа с `JSONB`, хранимые функции и триггеры (`PL/pgSQL`).
