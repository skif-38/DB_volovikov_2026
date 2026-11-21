-- задание 3 - ресурс веремя
-- мерики - код, дата начала/окончания месяца, 
-- название месяца, год, номер квартала, название квартала

CREATE TABLE IF NOT EXISTS dim_date (
    date_key INTEGER PRIMARY KEY,
    date DATE NOT NULL,
    month_start_date DATE NOT NULL,
    month_end_date DATE NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year INTEGER NOT NULL,
    quarter_number INTEGER NOT NULL,
    quarter_name VARCHAR(20) NOT NULL
);

CREATE OR REPLACE FUNCTION generate_calendar(
    start_date DATE,
    end_date DATE
)
RETURNS VOID AS $$
DECLARE
    current_date DATE := start_date;
    v_date_key INTEGER;
    v_month_start DATE;
    v_month_end DATE;
    v_month_name VARCHAR(20);
    v_year INTEGER;
    v_quarter_number INTEGER;
    v_quarter_name VARCHAR(20);
BEGIN
    WHILE current_date <= end_date LOOP
        v_date_key := EXTRACT(YEAR FROM current_date)::INTEGER * 10000 
                    + EXTRACT(MONTH FROM current_date)::INTEGER * 100 
                    + EXTRACT(DAY FROM current_date)::INTEGER;
        v_month_start := date_trunc('month', current_date)::DATE;
        v_month_end := (date_trunc('month', current_date) + INTERVAL '1 month - 1 day')::DATE;
        v_month_name := TO_CHAR(current_date, 'TMMonth');
        v_year := EXTRACT(YEAR FROM current_date)::INTEGER;
        v_quarter_number := EXTRACT(QUARTER FROM current_date)::INTEGER;
        v_quarter_name := v_quarter_number || ' квартал';
        
        INSERT INTO dim_date (
            date_key, date, month_start_date, month_end_date, 
            month_name, year, quarter_number, quarter_name
        ) VALUES (
            v_date_key, current_date, v_month_start, v_month_end,
            v_month_name, v_year, v_quarter_number, v_quarter_name
        );
        
        current_date := current_date + INTERVAL '1 day';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Очищаем и генерируем календарь с 2012 по 2023 год
TRUNCATE TABLE dim_date;
SELECT generate_calendar('2012-01-01'::DATE, '2023-12-31'::DATE);