-- 1) таблицы и sequence
DO $$
BEGIN
DROP TABLE IF EXISTS temperature_calculations, parameters, logs, users, equipment_types, positions, types_parameters, units_measurement, base_units CASCADE;

DROP SEQUENCE IF EXISTS positions_id_seq CASCADE;
DROP SEQUENCE IF EXISTS equipment_types_id_seq CASCADE;
DROP SEQUENCE IF EXISTS users_id_seq CASCADE;
DROP SEQUENCE IF EXISTS logs_id_seq CASCADE;
DROP SEQUENCE IF EXISTS base_units_id_seq CASCADE;
DROP SEQUENCE IF EXISTS units_measurement_id_seq CASCADE;
DROP SEQUENCE IF EXISTS types_parameters_id_seq CASCADE;
DROP SEQUENCE IF EXISTS parameters_id_seq CASCADE;
DROP SEQUENCE IF EXISTS temperature_calculations_id_seq CASCADE;

-- счётчики
CREATE SEQUENCE positions_id_seq;
CREATE SEQUENCE equipment_types_id_seq;
CREATE SEQUENCE users_id_seq;
CREATE SEQUENCE logs_id_seq;
CREATE SEQUENCE base_units_id_seq;
CREATE SEQUENCE units_measurement_id_seq;
CREATE SEQUENCE types_parameters_id_seq;
CREATE SEQUENCE parameters_id_seq;
CREATE SEQUENCE temperature_calculations_id_seq;

-- Должности
CREATE TABLE positions (
    id INT DEFAULT nextval('positions_id_seq'),
    title TEXT
);

-- Типы оборудования
CREATE TABLE equipment_types (
    id INT DEFAULT nextval('equipment_types_id_seq'),
    short_name CHAR(3),
    full_name TEXT
);

-- Пользователи
CREATE TABLE users (
    id INT DEFAULT nextval('users_id_seq'),
    name TEXT,
    last_name TEXT,
    patronymic TEXT,
    position_id INT
);

-- Базовые единицы измерения
CREATE TABLE base_units (
    id INT DEFAULT nextval('base_units_id_seq'),
    name TEXT
);

-- Единицы измерения
CREATE TABLE units_measurement (
    id INT DEFAULT nextval('units_measurement_id_seq'),
    name TEXT,
    base_unit_id INT
);

-- Типы параметров
CREATE TABLE types_parameters (
    id INT DEFAULT nextval('types_parameters_id_seq'),
    name TEXT
);

-- Пачки измерений
CREATE TABLE logs (
    id INT DEFAULT nextval('logs_id_seq'),
    user_id INT,
    equipment_type_id INT,
    measured_at TIMESTAMP
);

-- Значения параметров
CREATE TABLE parameters (
    id INT DEFAULT nextval('parameters_id_seq'),
    log_id INT,
    param_id INT,
    units_id INT,
    param_value NUMERIC
);

-- Расчет температуры
CREATE TABLE temperature_calculations (
    id INT DEFAULT nextval('temperature_calculations_id_seq'),
    temperature NUMERIC(4,1),
    correction NUMERIC(3,1)
);
END $$;

-- комментарии объектов
DO $$
BEGIN
COMMENT ON TABLE positions IS 'Должности';
COMMENT ON COLUMN positions.id IS 'Код должности';
COMMENT ON COLUMN positions.title IS 'Название должности';

COMMENT ON TABLE equipment_types IS 'Типы оборудования';
COMMENT ON COLUMN equipment_types.id IS 'Код типа оборудования';
COMMENT ON COLUMN equipment_types.short_name IS 'Краткое обозначение';
COMMENT ON COLUMN equipment_types.full_name IS 'Полное наименование';

COMMENT ON TABLE users IS 'Пользователи';
COMMENT ON COLUMN users.id IS 'Код пользователя';
COMMENT ON COLUMN users.name IS 'Имя';
COMMENT ON COLUMN users.last_name IS 'Фамилия';
COMMENT ON COLUMN users.patronymic IS 'Отчество';
COMMENT ON COLUMN users.position_id IS 'Код должности';

COMMENT ON TABLE base_units IS 'Базовые единицы измерения';
COMMENT ON COLUMN base_units.id IS 'Код базовой единицы';
COMMENT ON COLUMN base_units.name IS 'Наименование базовой единицы';

COMMENT ON TABLE units_measurement IS 'Единицы измерения';
COMMENT ON COLUMN units_measurement.id IS 'Код единицы измерения';
COMMENT ON COLUMN units_measurement.name IS 'Наименование единицы измерения';
COMMENT ON COLUMN units_measurement.base_unit_id IS 'Код базовой единицы';

COMMENT ON TABLE types_parameters IS 'Типы параметров';
COMMENT ON COLUMN types_parameters.id IS 'Код типа параметра';
COMMENT ON COLUMN types_parameters.name IS 'Наименование типа параметра';

COMMENT ON TABLE logs IS 'Пачки измерений';
COMMENT ON COLUMN logs.id IS 'Код пачки';
COMMENT ON COLUMN logs.user_id IS 'Код пользователя';
COMMENT ON COLUMN logs.equipment_type_id IS 'Код типа оборудования';
COMMENT ON COLUMN logs.measured_at IS 'Дата и время измерения';

COMMENT ON TABLE parameters IS 'Значения параметров';
COMMENT ON COLUMN parameters.id IS 'Код значения параметра';
COMMENT ON COLUMN parameters.log_id IS 'Код пачки';
COMMENT ON COLUMN parameters.param_id IS 'Код типа параметра';
COMMENT ON COLUMN parameters.units_id IS 'Код единицы измерения';
COMMENT ON COLUMN parameters.param_value IS 'Значение параметра';

COMMENT ON TABLE temperature_calculations IS 'Расчет температуры';
COMMENT ON COLUMN temperature_calculations.id IS 'Код записи';
COMMENT ON COLUMN temperature_calculations.temperature IS 'Температура, °C';
COMMENT ON COLUMN temperature_calculations.correction IS 'Поправка';
END $$;

-- 2) тестовые данные
DO $$
BEGIN
-- Должности
INSERT INTO positions (title) VALUES
    ('Наблюдатель'),
    ('Старший наблюдатель'),
    ('Командир метеостанции');

-- Типы оборудования
INSERT INTO equipment_types (short_name, full_name) VALUES
    ('ДМК', 'Десантный метеорологический комплект'),
    ('ВР', 'Ветровое ружьё');

-- Пользователи
INSERT INTO users (last_name, name, patronymic, position_id) VALUES
    ('Петров', 'Иван', 'Петрович', 1),
    ('Кузнецов', 'Сергей', 'Сергеевич', 2),
    ('Смирнов', 'Алексей', 'Алексеевич', 3),
    ('Сидоров', 'Сидор', 'Сидорович', 1),
    ('Морозов', 'Дмитрий', 'Андреевич', 3);

-- Базовые единицы измерения
INSERT INTO base_units (name) VALUES
    ('Длина'),
    ('Температура'),
    ('Давление'),
    ('Угол'),
    ('Скорость');

-- Единицы измерения
INSERT INTO units_measurement (name, base_unit_id) VALUES
    ('Метры', 1),
    ('Миллиметры ртутного столба', 3),
    ('Градусы Цельсия', 2),
    ('Градусы', 4),
    ('Метры в секунду', 5);

-- Типы параметров
INSERT INTO types_parameters (name) VALUES
    ('Высота метеопоста'),
    ('Температура'),
    ('Давление'),
    ('Направление ветра'),
    ('Скорость ветра'),
    ('Дальность сноса пуль');

-- Пачки измерений
INSERT INTO logs (user_id, equipment_type_id, measured_at) VALUES
    (1, 1, '2026-09-21 09:30'),
    (2, 2, '2026-09-21 14:05'),
    (4, 1, '2026-09-22 07:15'),
    (5, 1, '2026-09-22 08:40');

-- Значения параметров
INSERT INTO parameters (log_id, param_id, units_id, param_value) VALUES
    (1, 1, 1, 100),
    (1, 2, 3, 25.0),
    (1, 3, 2, 765),
    (1, 4, 4, 15),
    (1, 5, 5, 6),
    (2, 1, 1, 60),
    (2, 2, 3, -5.0),
    (2, 3, 2, 743),
    (2, 4, 4, 30),
    (2, 6, 1, 85),
    (3, 1, 1, 100),
    (3, 2, 3, 17.0),
    (3, 3, 2, 750),
    (3, 4, 4, 9),
    (3, 5, 5, 4),
    (4, 1, 1, 100),
    (4, 2, 3, 22.0),
    (4, 3, 2, 758),
    (4, 4, 4, 12),
    (4, 5, 5, 5);

-- Расчет температуры
INSERT INTO temperature_calculations (temperature, correction) VALUES
    (0, 0.5),
    (5, 0.5),
    (10, 1.0),
    (15, 1.0),
    (20, 1.5),
    (25, 2.0),
    (30, 3.5),
    (40, 4.5);
END $$;

-- 3) связи и ограничения
DO $$
BEGIN
-- обязательные поля NOT NULL
ALTER TABLE positions ALTER COLUMN title SET NOT NULL;

ALTER TABLE equipment_types
    ALTER COLUMN short_name SET NOT NULL,
    ALTER COLUMN full_name SET NOT NULL;

ALTER TABLE users
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN last_name SET NOT NULL,
    ALTER COLUMN patronymic SET NOT NULL,
    ALTER COLUMN position_id SET NOT NULL;

ALTER TABLE base_units ALTER COLUMN name SET NOT NULL;

ALTER TABLE units_measurement
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN base_unit_id SET NOT NULL;

ALTER TABLE types_parameters ALTER COLUMN name SET NOT NULL;

ALTER TABLE logs
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN equipment_type_id SET NOT NULL,
    ALTER COLUMN measured_at SET NOT NULL;

ALTER TABLE parameters
    ALTER COLUMN log_id SET NOT NULL,
    ALTER COLUMN param_id SET NOT NULL,
    ALTER COLUMN units_id SET NOT NULL,
    ALTER COLUMN param_value SET NOT NULL;

ALTER TABLE temperature_calculations
    ALTER COLUMN temperature SET NOT NULL,
    ALTER COLUMN correction SET NOT NULL;

-- первичные ключи
ALTER TABLE positions ADD PRIMARY KEY (id);
ALTER TABLE equipment_types ADD PRIMARY KEY (id);
ALTER TABLE users ADD PRIMARY KEY (id);
ALTER TABLE base_units ADD PRIMARY KEY (id);
ALTER TABLE units_measurement ADD PRIMARY KEY (id);
ALTER TABLE types_parameters ADD PRIMARY KEY (id);
ALTER TABLE logs ADD PRIMARY KEY (id);
ALTER TABLE parameters ADD PRIMARY KEY (id);
ALTER TABLE temperature_calculations ADD PRIMARY KEY (id);

-- уникальность
ALTER TABLE positions ADD UNIQUE (title);
ALTER TABLE equipment_types ADD UNIQUE (short_name);
ALTER TABLE equipment_types ADD UNIQUE (full_name);
ALTER TABLE base_units ADD UNIQUE (name);
ALTER TABLE units_measurement ADD UNIQUE (name);
ALTER TABLE types_parameters ADD UNIQUE (name);
ALTER TABLE temperature_calculations ADD UNIQUE (temperature);

-- проверки
ALTER TABLE temperature_calculations
    ADD CHECK (temperature BETWEEN -58 AND 58),
    ADD CHECK (correction >= 0);

-- внешние ключи - связи
ALTER TABLE users
    ADD FOREIGN KEY (position_id) REFERENCES positions(id);

ALTER TABLE units_measurement
    ADD FOREIGN KEY (base_unit_id) REFERENCES base_units(id);

ALTER TABLE logs
    ADD FOREIGN KEY (user_id) REFERENCES users(id),
    ADD FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(id);

ALTER TABLE parameters
    ADD FOREIGN KEY (log_id) REFERENCES logs(id),
    ADD FOREIGN KEY (param_id) REFERENCES types_parameters(id),
    ADD FOREIGN KEY (units_id) REFERENCES units_measurement(id);
END $$;