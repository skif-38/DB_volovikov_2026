-- Создание справочников
CREATE TABLE base_units (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE units_measurement (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    base_unit_id INT NOT NULL REFERENCES base_units(id)
);

CREATE TABLE types_parameters (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Заполнение данными

INSERT INTO base_units (name) VALUES
    ('Длина'),
    ('Температура'),
    ('Давление'),
    ('Угол'),
    ('Скорость');

INSERT INTO units_measurement (name, base_unit_id) VALUES
    ('Метры', 1),
    ('Миллиметры ртутного столба', 3),
    ('Градусы Цельсия', 2),
    ('Градусы', 4),
    ('Метры в секунду', 5);

INSERT INTO types_parameters (name) VALUES
    ('Высота метеопоста'),
    ('Температура'),
    ('Давление'),
    ('Направление ветра'),
    ('Скорость ветра'),
    ('Дальность сноса пуль');

-- Добавление новые колоноки в parameters
ALTER TABLE parameters ADD COLUMN log_id INT;
ALTER TABLE parameters ADD COLUMN param_id INT;
ALTER TABLE parameters ADD COLUMN units_id INT;
ALTER TABLE parameters ADD COLUMN param_value NUMERIC;

-- чтобы можно было вставить новые строки, убрал NOT NULL

ALTER TABLE parameters DROP CONSTRAINT parameters_wind_xor;

ALTER TABLE parameters ALTER COLUMN station_height DROP NOT NULL;
ALTER TABLE parameters ALTER COLUMN temperature DROP NOT NULL;
ALTER TABLE parameters ALTER COLUMN pressure DROP NOT NULL;
ALTER TABLE parameters ALTER COLUMN wind_direction DROP NOT NULL;

-- Перенос старых данных 
-- Высота метеопоста (param_id = 1, units_id = 1)
INSERT INTO parameters (log_id, param_id, units_id, param_value)
SELECT logs.id, 1, 1, p.station_height
FROM logs
JOIN parameters p ON logs.parameter_id = p.id
WHERE p.station_height IS NOT NULL;

-- Температура (param_id = 2, units_id = 3)
INSERT INTO parameters (log_id, param_id, units_id, param_value)
SELECT logs.id, 2, 3, p.temperature
FROM logs
JOIN parameters p ON logs.parameter_id = p.id
WHERE p.temperature IS NOT NULL;

-- Давление (param_id = 3, units_id = 2)
INSERT INTO parameters (log_id, param_id, units_id, param_value)
SELECT logs.id, 3, 2, p.pressure
FROM logs
JOIN parameters p ON logs.parameter_id = p.id
WHERE p.pressure IS NOT NULL;

-- Направление ветра (param_id = 4, units_id = 4)
INSERT INTO parameters (log_id, param_id, units_id, param_value)
SELECT logs.id, 4, 4, p.wind_direction
FROM logs
JOIN parameters p ON logs.parameter_id = p.id
WHERE p.wind_direction IS NOT NULL;

-- Скорость ветра (param_id = 5, units_id = 5)
INSERT INTO parameters (log_id, param_id, units_id, param_value)
SELECT logs.id, 5, 5, p.wind_speed
FROM logs
JOIN parameters p ON logs.parameter_id = p.id
WHERE p.wind_speed IS NOT NULL;

-- Дальность сноса пуль (param_id = 6, units_id = 1)
INSERT INTO parameters (log_id, param_id, units_id, param_value)
SELECT logs.id, 6, 1, p.bullet_drift
FROM logs
JOIN parameters p ON logs.parameter_id = p.id
WHERE p.bullet_drift IS NOT NULL;

-- Удаление старой связи в logs
ALTER TABLE logs DROP COLUMN parameter_id;

DELETE FROM parameters WHERE station_height IS NOT NULL;

-- Удаление старых колонок
ALTER TABLE parameters DROP COLUMN station_height;
ALTER TABLE parameters DROP COLUMN temperature;
ALTER TABLE parameters DROP COLUMN pressure;
ALTER TABLE parameters DROP COLUMN wind_direction;
ALTER TABLE parameters DROP COLUMN wind_speed;
ALTER TABLE parameters DROP COLUMN bullet_drift;

-- NOT NULL в новые колонки

ALTER TABLE parameters ALTER COLUMN log_id SET NOT NULL;
ALTER TABLE parameters ALTER COLUMN param_id SET NOT NULL;
ALTER TABLE parameters ALTER COLUMN units_id SET NOT NULL;
ALTER TABLE parameters ALTER COLUMN param_value SET NOT NULL;

ALTER TABLE parameters
    ADD CONSTRAINT fk_parameters_logs FOREIGN KEY (log_id) REFERENCES logs(id);
ALTER TABLE parameters
    ADD CONSTRAINT fk_parameters_types FOREIGN KEY (param_id) REFERENCES types_parameters(id);
ALTER TABLE parameters
    ADD CONSTRAINT fk_parameters_units FOREIGN KEY (units_id) REFERENCES units_measurement(id);