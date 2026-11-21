-- Примечание: Я не придумал, как по другому перенести таблицы напрямую из MSSQL в PostgreSQL 
-- без настройки сложных серверных расширений. В интернете есть способ сс промежуточными таблицами, 
-- для переноса данных, использовал промежуточные staging-таблицы: 
-- выгрузил данные из MSSQL в CSV и загрузил их сюда, а уже из них перенес в OLAP-структуру.


-- staging-таблицы для приема данных из MSSQL

CREATE TABLE IF NOT EXISTS staging_product (
    id BIGINT PRIMARY KEY,
    productid VARCHAR(16),
    description VARCHAR(255),
    CategoryID BIGINT,
    vendorid BIGINT,
    cost NUMERIC(9,2),
    price1 NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS staging_vendors (
    id BIGINT PRIMARY KEY,
    clientid VARCHAR(24),
    lastname VARCHAR(100),
    firstname VARCHAR(100),
    INN VARCHAR(50),
    country VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS staging_personnel (
    personid INTEGER PRIMARY KEY,
    lastname VARCHAR(45),
    firstname VARCHAR(25),
    middlename VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS staging_storages (
    id BIGINT PRIMARY KEY,
    CompanyID INTEGER,
    description VARCHAR(255),
    CityID INTEGER
);

CREATE TABLE IF NOT EXISTS staging_category (
    id BIGINT PRIMARY KEY,
    categoryid VARCHAR(50),
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging_bm_StorageOperations (
    ID BIGINT PRIMARY KEY,
    DocumentID BIGINT,
    ProductID BIGINT,
    VendorID BIGINT,
    StorageID BIGINT,
    Count NUMERIC(18,4),
    Price NUMERIC(18,2),
    Amount NUMERIC(18,2),
    Rest NUMERIC(18,4)
);

CREATE TABLE IF NOT EXISTS staging_bm_JournalBarnetDocs (
    ID BIGINT PRIMARY KEY,
    Period TIMESTAMP,
    DocumentTypeID BIGINT
);

CREATE TABLE IF NOT EXISTS staging_journal (
    transnumber BIGINT PRIMARY KEY,
    id VARCHAR(16),
    dater TIMESTAMP,
    transtype INTEGER,
    loginid VARCHAR(13),
    categoryid VARCHAR(50),
    quantity NUMERIC(15,3),
    price NUMERIC(15,2),
    amount NUMERIC(15,2)
);

CREATE TABLE IF NOT EXISTS staging_bm_WorkHours (
    ID BIGINT PRIMARY KEY,
    DateR TIMESTAMP,
    PersonID INTEGER,
    SystemPeriod DOUBLE PRECISION,
    ManualPeriod DOUBLE PRECISION
);


-- загруузка данных из staging в OLAP

CREATE OR REPLACE FUNCTION load_olap_data()
RETURNS VOID AS $$
BEGIN
    -- загрузка справочников

    INSERT INTO dim_product (product_key, id, description, category_id, vendor_id, cost, price1)
    SELECT productid, id, description, CategoryID, vendorid, cost, price1
    FROM staging_product;

    INSERT INTO dim_vendor (vendor_key, clientid, lastname, firstname, inn, country)
    SELECT id, clientid, lastname, firstname, INN, country
    FROM staging_vendors;

    INSERT INTO dim_staff (staff_key, lastname, firstname, middlename)
    SELECT personid, lastname, firstname, middlename
    FROM staging_personnel;

    INSERT INTO dim_storage (storage_key, companyid, description, cityid)
    SELECT id, CompanyID, description, CityID
    FROM staging_storages;

    INSERT INTO dim_category (category_key, id, description)
    SELECT categoryid, id, description
    FROM staging_category;

    -- Загрузка фактолв

    -- Закупки
    INSERT INTO fact_purchase (purchase_id, date_key, product_key, vendor_key, storage_key, operation_type_id, count, price, amount)
    SELECT
        so.ID,
        EXTRACT(YEAR FROM jbd.Period)::INTEGER * 10000 + EXTRACT(MONTH FROM jbd.Period)::INTEGER * 100 + EXTRACT(DAY FROM jbd.Period)::INTEGER,
        p.productid,
        so.VendorID,
        so.StorageID,
        jbd.DocumentTypeID,
        so.Count,
        so.Price,
        so.Amount
    FROM staging_bm_StorageOperations so
    INNER JOIN staging_bm_JournalBarnetDocs jbd ON so.DocumentID = jbd.ID
    LEFT JOIN staging_product p ON so.ProductID = p.id
    WHERE jbd.DocumentTypeID = 4;

    -- продажи
    INSERT INTO fact_sale (sale_id, date_key, product_key, staff_key, category_key, quantity, price, amount)
    SELECT
        j.transnumber,
        EXTRACT(YEAR FROM j.dater)::INTEGER * 10000 + EXTRACT(MONTH FROM j.dater)::INTEGER * 100 + EXTRACT(DAY FROM j.dater)::INTEGER,
        j.id,
        CAST(j.loginid AS INTEGER),
        j.categoryid,
        j.quantity,
        j.price,
        j.amount
    FROM staging_journal j
    WHERE j.transtype = 101;

    -- рабочее время
    INSERT INTO fact_work_hours (work_hours_id, date_key, staff_key, system_period, manual_period)
    SELECT
        wh.ID,
        EXTRACT(YEAR FROM wh.DateR)::INTEGER * 10000 + EXTRACT(MONTH FROM wh.DateR)::INTEGER * 100 + EXTRACT(DAY FROM wh.DateR)::INTEGER,
        wh.PersonID,
        wh.SystemPeriod,
        wh.ManualPeriod
    FROM staging_bm_WorkHours wh;

    -- движение по складам
    INSERT INTO fact_stock_movement (movement_id, date_key, product_key, storage_key, count, rest)
    SELECT
        so.ID,
        EXTRACT(YEAR FROM jbd.Period)::INTEGER * 10000 + EXTRACT(MONTH FROM jbd.Period)::INTEGER * 100 + EXTRACT(DAY FROM jbd.Period)::INTEGER,
        p.productid,
        so.StorageID,
        so.Count,
        so.Rest
    FROM staging_bm_StorageOperations so
    INNER JOIN staging_bm_JournalBarnetDocs jbd ON so.DocumentID = jbd.ID
    LEFT JOIN staging_product p ON so.ProductID = p.id;

END;
$$ LANGUAGE plpgsql;

-- Запуск функции
SELECT load_olap_data();