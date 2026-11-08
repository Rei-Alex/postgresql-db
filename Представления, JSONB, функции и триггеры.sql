-- 1. ПРЕДСТАВЛЕНИЯ

CREATE MATERIALIZED VIEW IF NOT EXISTS посетитель AS
SELECT
    "Карта пациентов"."Имя" AS "Имя_пациента",
    "Карта пациентов"."Фамилия" AS "Фамилия_пациента",
    "Карта пациентов"."Отчество" AS "Отчество_пациента",
    "Врачи"."Имя" AS "Имя_Врача",
    "Врачи"."Фамилия" AS "Фамилия_Врача",
    "Врачи"."Отчество" AS "Отчество_Врача",
    "Расписание приёма"."Время начала приёма",
    "Расписание приёма"."Время конца приёма",
    "Процедуры"."Название" AS "Процедура"
FROM "Расписание приёма"
INNER JOIN "Процедуры" ON "Расписание приёма"."Процедура" = "Процедуры"."Процедура_id"
INNER JOIN "Врачи" ON "Расписание приёма"."Врач" = "Врачи"."Врач_id"
INNER JOIN "Карта пациентов" ON "Расписание приёма"."Пациент" = "Карта пациентов"."Пациент_id";

CREATE OR REPLACE VIEW "Регистратура" AS
SELECT *
FROM "Карта пациентов";

-- 2. РАБОТА С JSONB

-- 1. Получение всего JSONB-поля
SELECT "Доп. контакты" FROM "Больница";

-- 2. Извлечение телефона второго сотрудника из массива
SELECT "Доп. контакты" -> 'Данные' -> 1 ->> 'Телефон' AS "Телефон"
FROM "Больница";

-- 3. Извлечение значения по пути #>>
SELECT "Доп. контакты" #>> '{Данные,0,Телефон}' AS "Телефон"
FROM "Больница";

-- 4. Поиск контакта по имени через разворачивание массива jsonb_array_elements
SELECT json.val ->> 'Телефон' AS "Телефон"
FROM "Больница" AS tabl
CROSS JOIN LATERAL jsonb_array_elements(tabl."Доп. контакты" -> 'Данные') AS json(val)
WHERE json.val ->> 'Имя' = 'Анна';

-- 5. Разбор ключей и значений верхнего уровня
SELECT jsonb_each("Доп. контакты")
FROM "Больница";

-- 6. Обновление номера телефона внутри JSONB без изменения таблицы
SELECT "Доп. контакты",
       jsonb_set("Доп. контакты", '{Данные,0,Телефон}', '"89993332121"') AS updated_json
FROM "Больница";

-- 7. Преобразование строк таблицы в JSON-объекты
SELECT ROW_TO_JSON(X)
FROM (SELECT "Направление", "Врач" FROM "Направление врача") AS X;

-- 3. ХРАНИМЫЕ ФУНКЦИИ

-- 1. Средний стаж врачей (PL/pgSQL)
CREATE OR REPLACE FUNCTION avg_staj() RETURNS integer AS $$
DECLARE
    i integer;
BEGIN
    SELECT AVG("Стаж") INTO i FROM "Врачи";
    RETURN i;
END;
$$ LANGUAGE plpgsql;

-- 2. Табличная функция: врачи со стажем более 4 лет
CREATE OR REPLACE FUNCTION staj_vracha()
RETURNS TABLE("Стаж" int, "Фамилия" text) AS $$
    SELECT "Стаж", "Фамилия"
    FROM "Врачи"
    WHERE "Стаж" > 4;
$$ LANGUAGE SQL;

-- 3. Функция сложения с OUT-параметром, переименование и удаление
CREATE OR REPLACE FUNCTION add(x int, y int, OUT sum int)
AS 'SELECT x + y'
LANGUAGE SQL;

ALTER FUNCTION add(x int, y int, OUT sum int) RENAME TO "sum";
DROP FUNCTION IF EXISTS "sum"(x int, y int, OUT sum int);

-- 4. Получение записи врача по ID
CREATE OR REPLACE FUNCTION get_vrach(p_id integer) RETURNS "Врачи" AS $$
    SELECT *
    FROM "Врачи"
    WHERE "Врач_id" = p_id;
$$ LANGUAGE SQL;

-- 4. ТРИГГЕРЫ

-- 1. Проверка занятости времени приёма у врача перед вставкой
CREATE OR REPLACE FUNCTION prov()
RETURNS trigger AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM "Расписание приёма"
        WHERE "Время начала приёма" = NEW."Время начала приёма"
          AND "Врач" = NEW."Врач"
    ) THEN
        RAISE EXCEPTION 'ЗАНЯТО: у выбранного врача уже есть запись на это время';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_prov
BEFORE INSERT ON public."Расписание приёма"
FOR EACH ROW
EXECUTE FUNCTION prov();

-- 2. Каскадное удаление записей приёма при удалении врача
CREATE OR REPLACE FUNCTION fynk_del_doctor()
RETURNS trigger AS $$
BEGIN
    DELETE FROM "Расписание приёма"
    WHERE "Врач" = OLD."Врач_id";

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER del_doctor
BEFORE DELETE ON "Врачи"
FOR EACH ROW
EXECUTE FUNCTION fynk_del_doctor();

ALTER TRIGGER del_doctor ON "Врачи" RENAME TO doctor_del;

-- 3. INSTEAD OF триггер для вставки пациентов через представление "Регистратура"
CREATE OR REPLACE FUNCTION add_reg()
RETURNS trigger AS $$
BEGIN
    INSERT INTO "Карта пациентов" (
        "Адрес", "Вес", "Возраст", "Имя", "Фамилия", "Отчество", "Пол", "Рост", "Телефон"
    )
    VALUES (
        NEW."Адрес", NEW."Вес", NEW."Возраст", NEW."Имя", NEW."Фамилия", NEW."Отчество", NEW."Пол", NEW."Рост", NEW."Телефон"
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reg
INSTEAD OF INSERT ON "Регистратура"
FOR EACH ROW
EXECUTE FUNCTION add_reg();
