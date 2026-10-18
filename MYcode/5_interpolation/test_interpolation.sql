DO $$
BEGIN
    BEGIN
        CREATE TYPE test_result AS (x decimal(7,2), calced_y decimal(7,2), target_y decimal(7,2), is_pass bool);
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END;
END $$;

CREATE OR REPLACE FUNCTION tests()
RETURNS SETOF test_result AS $$
DECLARE
    result_val decimal(7,2);
BEGIN
    -- Точные значения из таблицы temperature_calculation
    result_val := interpolation(0, find_value(0));
    RETURN NEXT ROW(0, result_val, 0.5, result_val = 0.5)::test_result;
    result_val := interpolation(10, find_value(10));
    RETURN NEXT ROW(10, result_val, 1.0, result_val = 1.0)::test_result;
    result_val := interpolation(25, find_value(25));
    RETURN NEXT ROW(25, result_val, 2.0, result_val = 2.0)::test_result;
    result_val := interpolation(40, find_value(40));
    RETURN NEXT ROW(40, result_val, 4.5, result_val = 4.5)::test_result;

    -- Интерполяция между соседними точками
    result_val := interpolation(2.5, find_value(2.5));
    RETURN NEXT ROW(2.5, result_val, 0.5, result_val = 0.5)::test_result;
    result_val := interpolation(7.5, find_value(7.5));
    RETURN NEXT ROW(7.5, result_val, 0.75, result_val = 0.75)::test_result;
    result_val := interpolation(12.5, find_value(12.5));
    RETURN NEXT ROW(12.5, result_val, 1.0, result_val = 1.0)::test_result;
    result_val := interpolation(22.5, find_value(22.5));
    RETURN NEXT ROW(22.5, result_val, 1.75, result_val = 1.75)::test_result;
    result_val := interpolation(27.5, find_value(27.5));
    RETURN NEXT ROW(27.5, result_val, 2.75, result_val = 2.75)::test_result;

    -- за границами таблицы
    result_val := interpolation(-10, find_value(-10));
    RETURN NEXT ROW(-10, result_val, 0.5, result_val = 0.5)::test_result;
    result_val := interpolation(50, find_value(50));
    RETURN NEXT ROW(50, result_val, 4.5, result_val = 4.5)::test_result;

    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM tests();