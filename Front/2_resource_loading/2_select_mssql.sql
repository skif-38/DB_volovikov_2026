-- Закупка продукции
-- Берем операции поступления DocumentTypeID = 4
SELECT 
    jbd.Period AS PurchaseDate,
    p.productid AS ProductCode,
    p.description AS ProductName,
    v.lastname AS VendorName,
    so.Count AS Quantity,
    so.Price AS Price,
    so.Amount AS TotalAmount
FROM bm_StorageOperations so
INNER JOIN bm_JournalBarnetDocs jbd ON so.DocumentID = jbd.ID
LEFT JOIN product p ON so.ProductID = p.id
LEFT JOIN vendors v ON so.VendorID = v.id
WHERE jbd.DocumentTypeID = 4;


-- Продажа товара
-- Используем только journal transtype = 101
-- Товар ищем по journal.id = product.productid
-- Сотрудника ищем через CAST, так как loginid это varchar, а personid это int
SELECT 
    j.dater AS SaleDate,
    p.productid AS ProductCode,
    p.description AS ProductName,
    c.description AS CategoryName,
    per.lastname + ' ' + per.firstname AS StaffName,
    j.quantity AS Quantity,
    j.price AS Price,
    j.amount AS TotalAmount
FROM journal j
INNER JOIN product p ON j.id = p.productid
LEFT JOIN category c ON p.CategoryID = c.id
LEFT JOIN personnel per ON j.loginid = CAST(per.personid AS VARCHAR(13))
WHERE j.transtype = 101;


-- Работа персонала
SELECT 
    wh.DateR AS WorkDate,
    per.lastname + ' ' + per.firstname AS StaffName,
    wh.SystemPeriod,
    wh.ManualPeriod
FROM bm_WorkHours wh
LEFT JOIN personnel per ON wh.PersonID = per.personid;


-- Остатки и вижение по складам
-- Берем все складские операции без фильтра по типу
-- Count > 0 это приход, Count < 0 это расход
SELECT 
    jbd.Period AS MovementDate,
    s.description AS StorageName,
    p.productid AS ProductCode,
    p.description AS ProductName,
    so.Count AS Quantity, 
    so.Rest AS CurrentRest
FROM bm_StorageOperations so
INNER JOIN bm_JournalBarnetDocs jbd ON so.DocumentID = jbd.ID
LEFT JOIN product p ON so.ProductID = p.id
LEFT JOIN storages s ON so.StorageID = s.id;