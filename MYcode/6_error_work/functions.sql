-- функции проверки и расчета
DO $$
BEGIN
    -- Функция проверки параметров
    CREATE OR REPLACE FUNCTION check_params(p_eq_id int, p_list param_type[])
    RETURNS text AS $func$
    DECLARE
        err_str text;
        err_invalid text;
        err_missing text;
    BEGIN
        -- проверка переданных параметров
        SELECT string_agg(
            CASE 
                WHEN er.param_id IS NULL THEN 'Недопустимый параметр: ' || tp.name || '; '
                WHEN it.val < tp.min_val OR it.val > tp.max_val THEN 'Вне диапазона: ' || tp.name || ' = ' || it.val || '; '
            END, '')
        INTO err_invalid
        FROM unnest(p_list) AS it(id, val)
        JOIN types_parameters tp ON tp.id = it.id
        LEFT JOIN equipment_rules er ON er.equipment_id = p_eq_id AND er.param_id = it.id
        WHERE er.param_id IS NULL OR (it.val < tp.min_val OR it.val > tp.max_val);

        -- Проверяем, что все обязательные параметры переданы, реализовал без циклов
        SELECT string_agg('Отсутствует параметр: ' || tp.name || '; ', '')
        INTO err_missing
        FROM equipment_rules er
        JOIN types_parameters tp ON tp.id = er.param_id
        WHERE er.equipment_id = p_eq_id
          AND NOT EXISTS (
              SELECT 1 FROM unnest(p_list) AS it(id, val) WHERE it.id = er.param_id
          );

        err_str := COALESCE(err_invalid, '') || COALESCE(err_missing, '');

        IF err_str = '' THEN
            RETURN 'OK';
        ELSE
            RETURN err_str;
        END IF;
    END;
    $func$ LANGUAGE plpgsql;

    -- Функция расчета
    CREATE OR REPLACE FUNCTION get_meteo(p_log_id int)
    RETURNS text AS $func2$
    DECLARE
        v_time timestamp;
        v_h numeric; v_p numeric; v_t numeric;
        v_p_base numeric; v_t_base numeric;
        v_p_neg numeric; v_t_neg numeric; v_h_neg numeric;
        v_ddchhmm text; v_vvvv text; v_bbbtt text;
    BEGIN
        -- Получаем константы
        SELECT val INTO v_p_base FROM constants WHERE name = 'PRESS_BASE';
        SELECT val INTO v_t_base FROM constants WHERE name = 'TEMP_BASE';
        SELECT val INTO v_p_neg FROM constants WHERE name = 'PRESS_NEG';
        SELECT val INTO v_t_neg FROM constants WHERE name = 'TEMP_NEG';
        SELECT val INTO v_h_neg FROM constants WHERE name = 'HEIGHT_NEG';

        -- Получаем данные пачки
        SELECT measured_at INTO v_time FROM logs WHERE id = p_log_id;
        
        -- Получаем параметры по названию, а не по ID
        SELECT 
            MAX(CASE WHEN tp.name = 'Высота метеопоста' THEN p.param_value END),
            MAX(CASE WHEN tp.name = 'Давление' THEN p.param_value END),
            MAX(CASE WHEN tp.name = 'Температура' THEN p.param_value END)
        INTO v_h, v_p, v_t
        FROM parameters p
        JOIN types_parameters tp ON p.param_id = tp.id
        WHERE p.log_id = p_log_id;

        -- ДДЧЧММ
        v_ddchhmm := to_char(v_time, 'DDHH24') || floor(extract(minute from v_time) / 10)::int;
        
        -- ВВВВ
        IF v_h < 0 THEN
            v_vvvv := lpad((v_h_neg + abs(v_h))::int::text, 4, '0');
        ELSE
            v_vvvv := lpad(v_h::int::text, 4, '0');
        END IF;
        
        -- БББТТ (давление)
        IF (v_p - v_p_base) < 0 THEN
            v_bbbtt := lpad((v_p_neg + abs(v_p - v_p_base))::int::text, 3, '0');
        ELSE
            v_bbbtt := lpad((v_p - v_p_base)::int::text, 3, '0');
        END IF;

        -- БББТТ (температура)
        IF round(v_t - v_t_base) < 0 THEN
            v_bbbtt := v_bbbtt || lpad((v_t_neg + abs(round(v_t - v_t_base)))::int::text, 2, '0');
        ELSE
            v_bbbtt := v_bbbtt || lpad(round(v_t - v_t_base)::int::text, 2, '0');
        END IF;

        RETURN v_ddchhmm || '-' || v_vvvv || '-' || v_bbbtt;
    END;
    $func2$ LANGUAGE plpgsql;
END $$;