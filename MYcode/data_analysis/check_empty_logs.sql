SELECT CASE
    WHEN COUNT(*) = 1 THEN 'Да'
    ELSE 'Нет'
END AS "У всех пользователей одинаковое количество измерений?"
FROM (
    SELECT l.user_id, COUNT(*) AS cnt
    FROM logs l
    GROUP BY l.user_id
) t;

SELECT CASE
    WHEN COUNT(*) = 0 THEN 'Да'
    ELSE 'Нет'
END AS "Нет пустых пачек измерения?"
FROM logs l
LEFT JOIN parameters p ON p.log_id = l.id
WHERE p.id IS NULL;

SELECT CASE
    WHEN COUNT(*) = 0 THEN 'Да'
    ELSE 'Нет'
END AS "Каждая пачка содержит 5 параметров?"
FROM (
    SELECT p.log_id
    FROM parameters p
    GROUP BY p.log_id
    HAVING COUNT(*) <> 5
        OR COUNT(DISTINCT p.param_id) <> 5
) t;


SELECT CASE
    WHEN COUNT(*) = 0 THEN 'Да'
    ELSE 'Нет'
END AS "Все значения корректны и в рамках диапазонов?"
FROM parameters p
JOIN logs l ON l.id = p.log_id
WHERE
    (p.param_id = 2 AND (p.param_value < -58 OR p.param_value > 58))
 OR (p.param_id = 3 AND (p.param_value < 500 OR p.param_value > 900))
 OR (p.param_id = 4 AND (p.param_value < 0   OR p.param_value > 59))
 OR (p.param_id = 5 AND (p.param_value < 0   OR p.param_value > 15))
 OR (p.param_id = 6 AND (p.param_value < 0   OR p.param_value > 150))
 OR (l.equipment_type_id = 1 AND p.param_id NOT IN (1,2,3,4,5))
 OR (l.equipment_type_id = 2 AND p.param_id NOT IN (1,2,3,4,6));

-- Все единицы измерения верны и корректны по отношению к параметрам?
--    units_id: 1-м, 2-мм рт.ст., 3-°C, 4-градусы, 5-м/с
SELECT CASE
    WHEN COUNT(*) = 0 THEN 'Да'
    ELSE 'Нет'
END AS "Все единицы измерения верны?"
FROM parameters p
WHERE
    (p.param_id = 1 AND p.units_id <> 1)
 OR (p.param_id = 2 AND p.units_id <> 3)
 OR (p.param_id = 3 AND p.units_id <> 2)
 OR (p.param_id = 4 AND p.units_id <> 4)
 OR (p.param_id = 5 AND p.units_id <> 5)
 OR (p.param_id = 6 AND p.units_id <> 1);