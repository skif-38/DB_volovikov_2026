-- Скрипт для хранения констант и правил
DO $$
BEGIN
    -- Таблица констант
    DROP TABLE IF EXISTS constants CASCADE;
    CREATE TABLE constants (name text PRIMARY KEY, val numeric NOT NULL);

    INSERT INTO constants (name, val) VALUES
        ('PRESS_BASE', 750), 
        ('TEMP_BASE', 15.9),
        ('PRESS_NEG', 500), 
        ('TEMP_NEG', 50), 
        ('HEIGHT_NEG', 5000);

    -- параметры разрешены для оборудования
    DROP TABLE IF EXISTS equipment_rules CASCADE;
    CREATE TABLE equipment_rules (equipment_id int, param_id int, PRIMARY KEY (equipment_id, param_id));

    -- 1 ДМК 2 ВР
    INSERT INTO equipment_rules (equipment_id, param_id) VALUES
        (1,1), (1,2), (1,3), (1,4), (1,5),
        (2,1), (2,2), (2,3), (2,4), (2,6);

    -- Новый список параметров из второго
    DROP TYPE IF EXISTS param_type CASCADE;
    CREATE TYPE param_type AS (id int, val numeric);
END $$;