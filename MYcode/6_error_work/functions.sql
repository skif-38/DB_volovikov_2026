-- функции проверки и расчета
DO $$
BEGIN
    -- Функция проверки параметров
    CREATE OR REPLACE FUNCTION check_params(p_eq_id int, p_list param_type[])
    RETURNS text AS $func$
    DECLARE
        p_item param_type;
        v_type record;
        err_str text := '';
        v_req int;
    BEGIN
        -- Проверяем переданные параметры
        FOREACH p_item IN ARRAY p_list LOOP
            SELECT * INTO v_type FROM types_parameters WHERE id = p_item.id;
            
            -- Проверка на недопустимый параметр
            IF NOT EXISTS (SELECT 1 FROM equipment_rules WHERE equipment_id = p_eq_id AND param_id = p_item.id) THEN
                err_str := err_str || 'Недопустимый параметр: ' || v_type.name || '; ';
            END IF;

            -- Проверка диапазона
            IF p_item.val < v_type.min_val OR p_item.val > v_type.max_val THEN
                err_str := err_str || 'Вне диапазона: ' || v_type.name || ' = ' || p_item.val || '; ';
            END IF;
        END LOOP;

        -- Проверяем, что все обязательные параметры переданы
        FOR v_req IN SELECT param_id FROM equipment_rules WHERE equipment_id = p_eq_id LOOP
            IF NOT EXISTS (SELECT 1 FROM unnest(p_list) WHERE id = v_req) THEN
                err_str := err_str || 'Отсутствует параметр: ' || (SELECT name FROM types_parameters WHERE id = v_req) || '; ';
            END IF;
        END LOOP;

        IF err_str = '' THEN
            RETURN 'OK';
        ELSE
            RETURN err_str;
        END IF;
    END;
    $func$ LANGUAGE plpgsql;

    -- Функция расчета Метео приближенных
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
        SELECT param_value INTO v_h FROM parameters WHERE log_id = p_log_id AND param_id = 1;
        SELECT param_value INTO v_p FROM parameters WHERE log_id = p_log_id AND param_id = 3;
        SELECT param_value INTO v_t FROM parameters WHERE log_id = p_log_id AND param_id = 2;

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