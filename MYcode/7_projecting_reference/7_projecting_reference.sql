-- Сносим всё старое
DROP TABLE IF EXISTS ref_data, ref_rows, ref_tables CASCADE;
DROP INDEX IF EXISTS idx_ref_data_row;
DROP INDEX IF EXISTS idx_ref_data_height;

-- таблицы 
-- Хранит какие справочные таблицы есть в системе.
CREATE TABLE ref_tables (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE, --'ВР Таблица 1', 'ДМК Таблица 2'
    description TEXT,
    equipment_type_id INT REFERENCES equipment_types(id), -- к какому оборудованию относится (ВР/ДМК)
    input_param_id INT REFERENCES types_parameters(id) -- ID параметра, который откладывается по оси X
);

-- заголовки строк для каждой таблицы
CREATE TABLE ref_rows (
    id SERIAL PRIMARY KEY,
    table_id INT NOT NULL REFERENCES ref_tables(id) ON DELETE CASCADE,
    input_value NUMERIC(10,2) NOT NULL,
    unit_id INT REFERENCES units_measurement(id) -- Связь для единицы измерения для этой строки
);


-- Данные справочника ячеек
CREATE TABLE ref_data (
    id SERIAL PRIMARY KEY,
    row_id INT NOT NULL REFERENCES ref_rows(id) ON DELETE CASCADE,
    height INT NOT NULL, 
    output_value NUMERIC(10,4) NOT NULL, 
    UNIQUE (row_id, height) 
);

-- Создаем индексы
CREATE INDEX idx_ref_data_row ON ref_data(row_id);
CREATE INDEX idx_ref_data_height ON ref_data(height);

-- Тестовое заполнение
INSERT INTO ref_tables (id, name, equipment_type_id, input_param_id) 
VALUES (
    1, 
    'ВР Таблица 1', 
    (SELECT id FROM equipment_types WHERE short_name = 'ВР' LIMIT 1),
    (SELECT id FROM types_parameters WHERE name = 'Температура' LIMIT 1)
);

INSERT INTO ref_rows (id, table_id, input_value, unit_id) 
VALUES (
    1, 
    1, 
    3, 
    (SELECT id FROM units_measurement WHERE name = 'Градусы Цельсия' LIMIT 1)
);

INSERT INTO ref_data (row_id, height, output_value) VALUES
(1, 200, -1.0),
(1, 400, -1.0),
(1, 800, -1.0),
(1, 1200, -1.0),
(1, 1600, -1.0),
(1, 2000, -1.0),
(1, 2400, -0.6667),
(1, 3000, -0.6667),
(1, 4000, -0.6667);


-- проверка таблицы
SELECT 
    t.name AS "Справочник",
    r.input_value AS "Отклонение",
    d.height AS "Высота в метрах",
    d.output_value AS "Значение"
FROM ref_tables t
JOIN ref_rows r ON r.table_id = t.id
JOIN ref_data d ON d.row_id = r.id
ORDER BY d.height;