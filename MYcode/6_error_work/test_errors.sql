-- Добавление пачек с ошибками для проверки валидации
DO $$
BEGIN
    -- Добавляем новые пачки
    INSERT INTO logs (user_id, equipment_id, measured_at) VALUES
        (1, 1, TIMESTAMP '2026-10-20 08:00:00'), 
        (2, 2, TIMESTAMP '2026-10-20 09:00:00'), 
        (3, 1, TIMESTAMP '2026-10-20 10:00:00'); 
    -- Температура, давление и высота
    INSERT INTO parameters (log_id, param_id, units_id, param_value) VALUES
        (25, 1, 1, 100),
        (25, 2, 3, 120),
        (25, 3, 2, 765),
        (25, 4, 4, 15),
        (25, 5, 5, 6);

    -- ВР, но передан param_id=5 скорость ветра вместо сноса пуль
    INSERT INTO parameters (log_id, param_id, units_id, param_value) VALUES
        (26, 1, 1, 100),
        (26, 2, 3, 15),
        (26, 3, 2, 750),
        (26, 4, 4, 10),
        (26, 5, 5, 5); -- Ошибка: для ВР это недопустимый параметр

    -- ДМК, но забыли передать скорость ветра (param_id=5)
    INSERT INTO parameters (log_id, param_id, units_id, param_value) VALUES
        (27, 1, 1, 100),
        (27, 2, 3, 20),
        (27, 3, 2, 740),
        (27, 4, 4, 12);
END $$;