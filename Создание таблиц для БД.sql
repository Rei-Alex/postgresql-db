--Таблица Процедуры:

CREATE TABLE IF NOT EXISTS public."Процедуры"
(
    "Процедура_id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY (INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1),
    "Название" text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Процедуры_pkey" PRIMARY KEY ("Процедура_id")
)
TABLESPACE pg_default;
ALTER TABLE IF EXISTS public."Процедуры"
    OWNER to postgres;

--Таблица Расписание работы:

CREATE TABLE IF NOT EXISTS public."Расписание работы"
(
    "Расписание работы_id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY (INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1),
    "Понедельник" text COLLATE pg_catalog."default" NOT NULL,
    "Вторник" text COLLATE pg_catalog."default" NOT NULL,
    "Среда" text COLLATE pg_catalog."default" NOT NULL,
    "Четверг" text COLLATE pg_catalog."default" NOT NULL,
    "Пятница" text COLLATE pg_catalog."default" NOT NULL,
    "Суббота" text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Расписание работы_pkey" PRIMARY KEY ("Расписание работы_id")
)
TABLESPACE pg_default;
ALTER TABLE IF EXISTS public."Расписание работы"
    OWNER to postgres;

--Таблица Направление:

CREATE TABLE IF NOT EXISTS public."Направление"
(
    "направление_id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY (INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1),
    "Название" text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Направление_pkey" PRIMARY KEY ("направление_id")
)
TABLESPACE pg_default;
ALTER TABLE IF EXISTS public."Направление"
    OWNER to postgres;

--Таблица Карта пациентов:

CREATE TABLE IF NOT EXISTS public."Карта пациентов"
(
    "Пациент_id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY (INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1),
    "Имя" text COLLATE pg_catalog."default" NOT NULL,
    "Фамилия" text COLLATE pg_catalog."default" NOT NULL,
    "Отчество" text COLLATE pg_catalog."default" NOT NULL,
    "Пол" text COLLATE pg_catalog."default" NOT NULL,
    "Возраст" integer NOT NULL,
    "Рост" integer,
    "Вес" integer,
    "Телефон" bigint,
    "Адрес" text COLLATE pg_catalog."default",
    CONSTRAINT "Карта пациентов_pkey" PRIMARY KEY ("Пациент_id")
)
TABLESPACE pg_default;
ALTER TABLE IF EXISTS public."Карта пациентов"
    OWNER to postgres;

--Таблица Врачи:

CREATE TABLE IF NOT EXISTS public."Врачи"
(
    "Врач_id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    "Имя" text COLLATE pg_catalog."default" NOT NULL,
    "Фамилия" text COLLATE pg_catalog."default" NOT NULL,
    "Отчество" text COLLATE pg_catalog."default" NOT NULL,
    "Пол" text COLLATE pg_catalog."default" NOT NULL,
    "Возраст" integer NOT NULL,
    "Стаж" integer NOT NULL,
    "Образование" text COLLATE pg_catalog."default" NOT NULL,
    "Часы приёмки" bigint NOT NULL,
    CONSTRAINT "Врачи_pkey" PRIMARY KEY ("Врач_id"),
    CONSTRAINT "Расписание_fkey" FOREIGN KEY ("Часы приёмки")
        REFERENCES public."Расписание работы" ("Расписание работы_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
TABLESPACE pg_default;
ALTER TABLE IF EXISTS public."Врачи"
    OWNER to postgres;

--Таблица Больница:

CREATE TABLE IF NOT EXISTS public."Больница"
(
    "Больница_id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    "Название" text COLLATE pg_catalog."default" NOT NULL,
    "Адрес" text COLLATE pg_catalog."default" NOT NULL,
    "Телефон" bigint NOT NULL,
    "Главный врач" bigint NOT NULL,
    "Время работы пн-пт" text COLLATE pg_catalog."default",
    "Время работы сб" text COLLATE pg_catalog."default",
    "Доп. контакты" jsonb,
    CONSTRAINT "Больница_pkey" PRIMARY KEY ("Больница_id"),
    CONSTRAINT "Глав-врач_fkey" FOREIGN KEY ("Главный врач")
        REFERENCES public."Врачи" ("Врач_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
TABLESPACE pg_default;
ALTER TABLE IF EXISTS public."Больница"
    OWNER to postgres;

--Таблица Направление врача:

CREATE TABLE IF NOT EXISTS public."Направление врача"
(
    "Направление врача_id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    "Направление" bigint NOT NULL,
    "Врач" bigint NOT NULL,
    CONSTRAINT "Направление врача_pkey" PRIMARY KEY ("Направление врача_id"),
    CONSTRAINT "Врач_fkey" FOREIGN KEY ("Врач")
        REFERENCES public."Врачи" ("Врач_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "Направление_fkey" FOREIGN KEY ("Направление")
        REFERENCES public."Направление" ("направление_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
TABLESPACE pg_default;
ALTER TABLE IF EXISTS public."Направление врача"
    OWNER to postgres;

--Таблица Расписание приёма:

CREATE TABLE IF NOT EXISTS public."Расписание приёма"
(
    "Приём_id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    "Пациент" bigint NOT NULL,
    "Врач" bigint NOT NULL,
    "Время начала приёма" time without time zone NOT NULL,
	"Время конца приёма" time without time zone NOT NULL,
    "Процедура" bigint NOT NULL,
    CONSTRAINT "Расписание приёма_pkey" PRIMARY KEY ("Приём_id"),
    CONSTRAINT "Врач_fkey" FOREIGN KEY ("Врач")
        REFERENCES public."Врачи" ("Врач_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "Пациент_fkey" FOREIGN KEY ("Пациент")
        REFERENCES public."Карта пациентов" ("Пациент_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "Процедура_fkey" FOREIGN KEY ("Процедура")
        REFERENCES public."Процедуры" ("Процедура_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Расписание приёма"
    OWNER to postgres;
