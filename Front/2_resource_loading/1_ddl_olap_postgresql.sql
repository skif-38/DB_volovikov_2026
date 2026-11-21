-- измерения
-- Товары
-- product_key это productid varchar,  связь идёт через journal.id
CREATE TABLE dim_product (
    product_key VARCHAR(16) PRIMARY KEY,
    id BIGINT,
    description VARCHAR(255),
    category_id BIGINT,
    vendor_id BIGINT,
    cost NUMERIC(9,2),
    price1 NUMERIC(10,2)
);

-- Поставщики
CREATE TABLE dim_vendor (
    vendor_key BIGINT PRIMARY KEY,
    clientid VARCHAR(24),
    lastname VARCHAR(100),
    firstname VARCHAR(100),
    inn VARCHAR(50),
    country VARCHAR(20)
);

-- Сотрудники
CREATE TABLE dim_staff (
    staff_key INTEGER PRIMARY KEY,
    lastname VARCHAR(45),
    firstname VARCHAR(25),
    middlename VARCHAR(50)
);

-- Склады
CREATE TABLE dim_storage (
    storage_key BIGINT PRIMARY KEY,
    companyid INTEGER,
    description VARCHAR(255),
    cityid INTEGER
);

-- Категории
-- category_key это categoryid varchar, в journal это varchar
CREATE TABLE dim_category (
    category_key VARCHAR(50) PRIMARY KEY,
    id BIGINT,
    description VARCHAR(255)
);

-- Единицы измерения
CREATE TABLE dim_size (
    size_key BIGINT PRIMARY KEY,
    sizeid VARCHAR(50),
    description VARCHAR(255)
);


-- события

-- Закупки 
CREATE TABLE fact_purchase (
    purchase_id BIGINT PRIMARY KEY,
    date_key INTEGER,
    product_key VARCHAR(16),
    vendor_key BIGINT,
    storage_key BIGINT,
    operation_type_id BIGINT,
    count NUMERIC(18,4),
    price NUMERIC(18,2),
    amount NUMERIC(18,2)
);

-- Продажи из journal, transtype 101
-- bm_Journal_Details не используем 
CREATE TABLE fact_sale (
    sale_id BIGINT PRIMARY KEY,
    date_key INTEGER,
    product_key VARCHAR(16),
    staff_key INTEGER,
    category_key VARCHAR(50),
    quantity NUMERIC(15,3),
    price NUMERIC(15,2),
    amount NUMERIC(15,2)
);

-- Рабочее время bm_WorkHours
CREATE TABLE fact_work_hours (
    work_hours_id BIGINT PRIMARY KEY,
    date_key INTEGER,
    staff_key INTEGER,
    system_period DOUBLE PRECISION,
    manual_period DOUBLE PRECISION
);

-- Движение по складам - остатки
CREATE TABLE fact_stock_movement (
    movement_id BIGINT PRIMARY KEY,
    date_key INTEGER,
    product_key VARCHAR(16),
    storage_key BIGINT,
    count NUMERIC(18,4),
    rest NUMERIC(18,4)
);