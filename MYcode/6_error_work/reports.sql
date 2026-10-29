-- Отчеты
-- Список параметров с ошибками
WITH batch_data AS (
    SELECT 
        l.id AS log_id,
        l.equipment_id,
        e.short_name AS eq_name,
        MAX(CASE WHEN p.param_id = 1 THEN p.param_value END) AS height,
        MAX(CASE WHEN p.param_id = 2 THEN p.param_value END) AS temp,
        MAX(CASE WHEN p.param_id = 3 THEN p.param_value END) AS press,
        MAX(CASE WHEN p.param_id = 4 THEN p.param_value END) AS wind_dir,
        MAX(CASE WHEN p.param_id = 5 THEN p.param_value END) AS wind_speed,
        MAX(CASE WHEN p.param_id = 6 THEN p.param_value END) AS drift,
        array_agg(ROW(p.param_id, p.param_value)::param_type) AS p_array
    FROM logs l
    JOIN equipment_types e ON e.id = l.equipment_id
    LEFT JOIN parameters p ON p.log_id = l.id
    GROUP BY l.id, l.equipment_id, e.short_name
),
-- Вызываем функцию один раз для пачки
batch_checked AS (
    SELECT 
        log_id,
        equipment_id,
        eq_name,
        height, temp, press, wind_dir, wind_speed, drift,
        check_params(equipment_id, p_array) AS err_desc
    FROM batch_data
)
SELECT 
    log_id AS "№",
    eq_name AS "Тип оборудования",
    height AS "Высота метеопоста",
    temp AS "Температура",
    press AS "Давление",
    wind_dir AS "Направление ветра",
    wind_speed AS "Скорость ветра",
    drift AS "Дальность сноса пуль",
    (err_desc != 'OK') AS "Флаг: Есть ошибка",
    err_desc AS "Описание ошибки"
FROM batch_checked
ORDER BY log_id;

-- "Лучший стрелок"
WITH grouped_logs AS (
    SELECT 
        l.user_id,
        l.id AS log_id,
        l.equipment_id,
        array_agg(ROW(p.param_id, p.param_value)::param_type) AS p_array
    FROM logs l
    LEFT JOIN parameters p ON p.log_id = l.id
    GROUP BY l.id, l.user_id, l.equipment_id
),
-- Вызываем функцию
checked_logs AS (
    SELECT 
        user_id,
        log_id,
        check_params(equipment_id, p_array) AS err_desc
    FROM grouped_logs
),
user_stats AS (
    SELECT 
        u.last_name || ' ' || u.name AS fio,
        count(cl.log_id) AS total_batches,
        count(*) FILTER (WHERE cl.err_desc != 'OK') AS bad_batches
    FROM users u
    LEFT JOIN checked_logs cl ON u.id = cl.user_id
    GROUP BY u.id, u.last_name, u.name
)
SELECT 
    fio AS "Пользователь",
    bad_batches AS "Количество ошибок",
    total_batches AS "Всего пачек",
    RANK() OVER (ORDER BY bad_batches ASC, total_batches DESC) AS "Место",
    CASE WHEN RANK() OVER (ORDER BY bad_batches ASC, total_batches DESC) = 1 THEN 'ДА' ELSE 'НЕТ' END AS "Лучший стрелок"
FROM user_stats
ORDER BY "Место";