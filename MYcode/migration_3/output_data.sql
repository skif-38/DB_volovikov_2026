-- Вывод данных
SELECT
    ROW_NUMBER() OVER (ORDER BY type, name) AS "№",
    name AS "Наименование",
    type AS "Тип"
FROM (
    -- Таблицы
    SELECT table_name AS name, 'Таблица' AS type
    FROM information_schema.tables
    WHERE table_catalog = current_database()
      AND table_schema = 'public'
      AND table_type = 'BASE TABLE'

    UNION ALL

    -- Счётчики
    SELECT sequence_name AS name, 'Счётчик (sequence)' AS type
    FROM information_schema.sequences
    WHERE sequence_catalog = current_database()
      AND sequence_schema = 'public'

    UNION ALL

    -- Ограничения
    SELECT
        constraint_name AS name,
        'Ограничение (' || constraint_type || ')' AS type
    FROM information_schema.table_constraints
    WHERE constraint_catalog = current_database()
      AND constraint_schema = 'public'
) AS meta
ORDER BY type, name;