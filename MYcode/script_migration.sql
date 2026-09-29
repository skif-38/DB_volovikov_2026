-- удаление таблиц, на тот случай если мы их уже создавали
DROP TABLE IF EXISTS logs, parameters, users, equipment_types, positions CASCADE;

-- Должности
CREATE TABLE positions (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL UNIQUE
);

-- Типы оборудования
CREATE TABLE equipment_types (
    id SERIAL PRIMARY KEY,
    short_name CHAR(3) NOT NULL UNIQUE,
    full_name TEXT NOT NULL UNIQUE
);

-- Пользователи
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    patronymic TEXT NOT NULL,
    position_id INT NOT NULL REFERENCES positions(id)
);

-- Параметры измерений
CREATE TABLE parameters (
    id SERIAL PRIMARY KEY,
    station_height INT NOT NULL,
    temperature NUMERIC(4,1) NOT NULL CHECK (temperature BETWEEN -60 AND 60),
    pressure INT NOT NULL CHECK (pressure BETWEEN 500 AND 1000),
    wind_direction INT NOT NULL CHECK (wind_direction BETWEEN 0 AND 360),
    wind_speed INT CHECK (wind_speed BETWEEN 0 AND 100),
    bullet_drift INT CHECK (bullet_drift BETWEEN 0 AND 300),
    CONSTRAINT parameters_wind_xor CHECK (
        (wind_speed IS NULL) <> (bullet_drift IS NULL)
    )
);

-- Пачки измерений (логи всех участников)
CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    parameter_id INT NOT NULL REFERENCES parameters(id),
    equipment_type_id INT NOT NULL REFERENCES equipment_types(id),
    measured_at TIMESTAMP NOT NULL
);

-- названия столбцов
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

COMMENT ON TABLE parameters IS 'Параметры измерений';
COMMENT ON COLUMN parameters.id IS 'Код параметров';
COMMENT ON COLUMN parameters.station_height IS 'Высота метеопоста, м';
COMMENT ON COLUMN parameters.temperature IS 'Температура воздуха, °C';
COMMENT ON COLUMN parameters.pressure IS 'Давление, мм рт. ст.';
COMMENT ON COLUMN parameters.wind_direction IS 'Направление ветра';
COMMENT ON COLUMN parameters.wind_speed IS 'Скорость ветра, м/с';
COMMENT ON COLUMN parameters.bullet_drift IS 'Снос пуль, м';

COMMENT ON TABLE logs IS 'Пачки измерений';
COMMENT ON COLUMN logs.id IS 'Код пачки';
COMMENT ON COLUMN logs.user_id IS 'Код пользователя';
COMMENT ON COLUMN logs.parameter_id IS 'Код параметров';
COMMENT ON COLUMN logs.equipment_type_id IS 'Код типа оборудования';
COMMENT ON COLUMN logs.measured_at IS 'Дата и время измерения';

-- заполнение бд данными
INSERT INTO positions (title) VALUES
    ('Наблюдатель'),
    ('Старший наблюдатель'),
    ('Командир метеостанции');

INSERT INTO equipment_types (short_name, full_name) VALUES
    ('ДМК', 'Десантный метеорологический комплект'),
    ('ВР', 'Ветровое ружьё');

INSERT INTO users (last_name, name, patronymic, position_id) VALUES
    ('Петров', 'Иван', 'Петрович', 1),
    ('Кузнецов', 'Сергей', 'Сергеевич', 2),
    ('Смирнов', 'Алексей', 'Алексеевич', 3),
    ('Сидоров', 'Сидор', 'Сидорович', 1),
    ('Морозов', 'Дмитрий', 'Андреевич', 3);

INSERT INTO parameters
    (station_height, temperature, pressure, wind_direction, wind_speed, bullet_drift) VALUES
    (100, 25.0, 765, 15, 6, NULL),
    (60, -5.0, 743, 30, NULL, 85),
    (100, 17.0, 750, 9, 4, NULL);

INSERT INTO logs (user_id, parameter_id, equipment_type_id, measured_at) VALUES
    (1, 1, 1, '2026-09-21 09:30'),
    (2, 2, 2, '2026-09-21 14:05'),
    (4, 3, 1, '2026-09-22 07:15'),
    (5, 1, 1, '2026-09-22 08:40');

