-- очистка
DROP TABLE IF EXISTS calc_correction, calc_correction_types, calc_correction_heights, calc_correction_headers CASCADE;
DROP SEQUENCE IF EXISTS calc_correction_height_seq, calc_correction_types_seq, calc_correction_seq CASCADE;

-- Создание базовых структур
CREATE SEQUENCE calc_correction_height_seq;
CREATE TABLE calc_correction_heights (
    id integer primary key not null default nextval('public.calc_correction_height_seq'),
    height integer not null
);
INSERT INTO calc_correction_heights(height) VALUES (200),(400),(800),(1200),(1600),(2000),(2400),(3000),(4000);

CREATE SEQUENCE calc_correction_types_seq;
CREATE TABLE calc_correction_types (
    id integer not null primary key default nextval('public.calc_correction_types_seq'),
    parent_id integer,
    measurment_equipment_id integer,
    description text not null,
    header_values integer[]
);

CREATE SEQUENCE calc_correction_seq;
CREATE TABLE calc_correction (
    id integer not null primary key default nextval('public.calc_correction_seq'),
    height_id integer not null,
    type_id integer not null,
    row_values integer[]
);

-- Исправление и добавление данных
-- были перепутаны id, положительные температуры шли под 8, а отрицательные под 9 надо наоборот и
-- добавил данные для высот от 1600 до 4000, которых не было
INSERT INTO calc_correction_types(id, description, header_values) VALUES 
(1, 'Таблица 2', array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]), 
(2, 'Таблица 3, скорость среднего ветра', null),
(3, 'Таблица 3, направление среднего ветра', null);

INSERT INTO calc_correction_types(id, description, parent_id, measurment_equipment_id, header_values) VALUES
(4, 'Таблица 3, Скорость среднего ветра (ВР)', 2, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]),
(5, 'Таблица 3, Направление среднего ветра (ВР)', 3, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]),
(6, 'Таблица 3, Скорость среднего ветра (ДМК)', 2, 1, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
(7, 'Таблица 3, Направление среднего ветра (ДМК)', 3, 1, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

INSERT INTO calc_correction_types(id, description, parent_id) VALUES
(8, 'Таблица 2, Положительные температуры', 1),
(9, 'Таблица 2, Отрицательные температуры', 1);

-- Заполнение таблицы поправок
INSERT INTO calc_correction(height_id, type_id, row_values) VALUES
-- отрицательные температуры тип 9
(1, 9, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]),
(2, 9, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -39, -48]),
(3, 9, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]),
(4, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]),
(5, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -25, -34, -42]),
(6, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -7, -16, -24, -32, -40]),
(7, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -6, -7, -15, -23, -31, -38]),
(8, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -6, -7, -15, -22, -30, -37]),
(9, 9, array[-1, -2, -3, -4, -4, -4, -5, -5, -6, -6, -14, -20, -27, -34]),
-- положительные температуры тип 8
(1, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
(2, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
(3, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
(4, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
(5, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
(6, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
(7, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
(8, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
(9, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
-- ветер ВР тиип 4
(1, 4, array[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]), 
(2, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
(3, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16]), 
(4, 4, array[4, 5, 7, 8, 8, 9, 11, 12, 13, 15, 15, 16]),
(5, 4, array[5, 6, 7, 9, 9, 10, 12, 13, 14, 16, 16, 17]), 
(6, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 17, 18]),
(7, 4, array[5, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17, 18]), 
(8, 4, array[6, 7, 9, 10, 11, 12, 14, 15, 16, 18, 18, 19]),
(9, 4, array[6, 8, 10, 11, 12, 13, 15, 16, 17, 19, 19, 20]),
-- Ветер ДМК тип 6
(1, 6, array[4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22]), 
(2, 6, array[5, 7, 10, 11, 12, 14, 17, 18, 20, 22, 23, 25, 27]),
(3, 6, array[5, 8, 10, 11, 13, 15, 18, 19, 21, 23, 25, 27, 28]), 
(4, 6, array[5, 8, 11, 12, 13, 16, 19, 20, 23, 24, 26, 28, 30]),
(5, 6, array[6, 9, 12, 13, 14, 17, 20, 22, 25, 26, 28, 30, 32]), 
(6, 6, array[6, 9, 12, 13, 15, 18, 21, 23, 26, 27, 29, 31, 33]),
(7, 6, array[7, 10, 13, 14, 16, 19, 22, 24, 27, 28, 30, 32, 34]), 
(8, 6, array[7, 10, 14, 15, 17, 20, 23, 25, 28, 29, 31, 33, 35]),
(9, 6, array[8, 11, 15, 16, 18, 21, 24, 26, 29, 30, 32, 34, 36]);

-- Вынос заголовков в отдельную таблицу
CREATE TABLE calc_correction_headers (
    id SERIAL PRIMARY KEY,
    type_id INT REFERENCES calc_correction_types(id) ON DELETE CASCADE,
    col_index INT NOT NULL,
    header_value INT NOT NULL
);

-- Переносим массивы в новую таблицу с сохранением индексов
INSERT INTO calc_correction_headers (type_id, col_index, header_value)
SELECT t.id, u.rn, u.val
FROM calc_correction_types t,
LATERAL unnest(t.header_values) WITH ORDINALITY AS u(val, rn)
WHERE t.header_values IS NOT NULL;

-- Удаляем старый массив, он не нужен
ALTER TABLE calc_correction_types DROP COLUMN header_values;

--   разработка хранимой процедуры
DROP TYPE IF EXISTS calc_input_params CASCADE;
CREATE TYPE calc_input_params AS (
    temperature NUMERIC,
    wind_speed NUMERIC
);

CREATE OR REPLACE FUNCTION calculate_corrections(
    p_eq_id INT,
    p_params calc_input_params
) RETURNS TABLE (
    height INT,
    temp_correction NUMERIC,
    wind_speed_correction NUMERIC
) AS $$
DECLARE
    v_temp_type INT;
    v_wind_type INT;
    v_temp_idx INT;
    v_wind_idx INT;
BEGIN
    -- определяем айди типа таблицы в зависимости от оборудования
    IF p_eq_id = 1 THEN 
        v_temp_type := CASE WHEN p_params.temperature < 0 THEN 9 ELSE 8 END; 
        v_wind_type := 6;
    ELSIF p_eq_id = 2 THEN 
        v_temp_type := CASE WHEN p_params.temperature < 0 THEN 9 ELSE 8 END; 
        v_wind_type := 4;
    ELSE 
        RAISE EXCEPTION 'Неизвестный тип оборудования: %', p_eq_id; 
    END IF;


    -- поиск заголовков для температуры
    SELECT array_position(array_agg(header_value ORDER BY col_index), ABS(p_params.temperature)::int)
    INTO v_temp_idx FROM calc_correction_headers WHERE type_id = 1;

    SELECT array_position(array_agg(header_value ORDER BY col_index), p_params.wind_speed::int)
    INTO v_wind_idx FROM calc_correction_headers WHERE type_id = v_wind_type;

    --  результат по каждой высоте
    RETURN QUERY
    SELECT h.height,
        COALESCE((c_t.row_values)[v_temp_idx], 0)::numeric,
        COALESCE((c_w.row_values)[v_wind_idx], 0)::numeric
    FROM calc_correction_heights h
    LEFT JOIN calc_correction c_t ON c_t.height_id = h.id AND c_t.type_id = v_temp_type
    LEFT JOIN calc_correction c_w ON c_w.height_id = h.id AND c_w.type_id = v_wind_type
    ORDER BY h.height;
END;
$$ LANGUAGE plpgsql;

-- ДМК id=1, температура -5, ветер 7
SELECT * FROM calculate_corrections(1, ROW(-5, 7)::calc_input_params);