DO $$
BEGIN 
    BEGIN
        CREATE TYPE calc_point AS (x0 decimal(7,2), y0 decimal(7,2), x1 decimal(7,2), y1 decimal(7,2));
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END;


    CREATE OR REPLACE FUNCTION find_value(
        p_temperature decimal(7,2)
    )
    RETURNS calc_point AS $func$
    DECLARE 
        low_x  decimal(7,2);
        low_y  decimal(7,2);
        high_x decimal(7,2);
        high_y decimal(7,2);
    BEGIN
        -- Нижня точка - температура <= искомой
        SELECT tc.temperature, tc.correction
        INTO low_x, low_y
        FROM temperature_calculations tc
        WHERE tc.temperature <= p_temperature
        ORDER BY tc.temperature DESC
        LIMIT 1;

        -- Верхняя точка - температура >= искомой
        SELECT tc.temperature, tc.correction
        INTO high_x, high_y
        FROM temperature_calculations tc
        WHERE tc.temperature >= p_temperature
        ORDER BY tc.temperature ASC
        LIMIT 1;

        -- Значение ниже минимального в таблице 
        IF low_x IS NULL THEN
            low_x := p_temperature;
            low_y := high_y;
        END IF;

        -- Значение выше максимального в таблице 
        IF high_x IS NULL THEN
            high_x := p_temperature;
            high_y := low_y;
        END IF;

        RETURN ROW(low_x, low_y, high_x, high_y)::calc_point;
    END;
    $func$ LANGUAGE plpgsql;


    CREATE OR REPLACE FUNCTION interpolation(x decimal(7,2), interpol_vals calc_point)
    RETURNS decimal(7,2) AS $func$
    DECLARE 
        dx decimal(7,2);
        dy decimal(7,2);
    BEGIN 
        dx := interpol_vals.x1 - interpol_vals.x0;
        dy := interpol_vals.y1 - interpol_vals.y0;

        -- Знаменатель нулевой или NULL — возвращаем известное значение
        IF dx = 0 OR dx IS NULL THEN
            RETURN COALESCE(interpol_vals.y0, interpol_vals.y1);
        END IF;

        RETURN (interpol_vals.y0 + ((x - interpol_vals.x0) * dy) / dx)::decimal(7,2);
    END;
    $func$ LANGUAGE plpgsql;
END $$;