# درس‌های تکمیلی SQL Server

[آموزش فارسی](../README.fa.md) · [English](../README.md)

این درس‌ها با داده‌های فروشگاه زنجیره‌ای کار می‌کنند. ابتدا [جداول و داده‌های نمونه](../README.fa.md#شروع-کار) را آماده کنید. برای بخش سطح دسترسی، ویوی `dbo.vwEmployee` را هم از آموزش اصلی بسازید.

```sql
USE SQLServerTutorialDB;
GO
```

## مقادیر خالی و نتیجهٔ JOIN

برای دیدن تعداد کارمندان هر شعبه، از سمت `Store` شروع کنید و با `LEFT JOIN` همهٔ شعبه‌ها را نگه دارید. `COUNT(e.ID)` فقط ردیف‌هایی را می‌شمارد که کارمند دارند. `SUM` در گروهی که هیچ حقوق ثبت‌شده‌ای ندارد مقدار `NULL` برمی‌گرداند و `COALESCE` آن را برای گزارش به صفر تبدیل می‌کند.

```sql
SELECT s.ID, s.Name,
       COUNT(e.ID) AS EmployeeCount,
       COALESCE(SUM(e.Salary), 0) AS TotalSalary
FROM dbo.Store AS s
LEFT JOIN dbo.Employee AS e ON e.S_ID = s.ID
GROUP BY s.ID, s.Name
ORDER BY s.ID;
```

در دادهٔ نمونه، شعبه‌های ۱ و ۲ هر کدام دو کارمند دارند و چهار شعبهٔ دیگر هر کدام یک کارمند. در شرط‌ها برای تشخیص مقدار خالی از `IS NULL` استفاده کنید.

## CTE و تابع پنجره‌ای

ابتدا ارزش موجودی هر شعبه را حساب کنید. سپس در هر زنجیره به شعبه‌ها بر اساس ارزش موجودی شماره بدهید و شعبهٔ اول را نمایش دهید. `PARTITION BY` شماره‌گذاری را برای هر زنجیره از اول شروع می‌کند. از شناسهٔ شعبه برای تعیین ترتیب در صورت تساوی استفاده کنید.

```sql
;WITH Inventory AS
(
    SELECT s.ID AS StoreID, s.C_ID AS ChainID, s.Name AS StoreName,
           COALESCE(SUM(p.Price * sp.Amount), 0) AS InventoryValue
    FROM dbo.Store AS s
    LEFT JOIN dbo.StoreProduct AS sp ON sp.S_ID = s.ID
    LEFT JOIN dbo.Product AS p ON p.ID = sp.P_ID
    GROUP BY s.ID, s.C_ID, s.Name
),
Ranked AS
(
    SELECT ChainID, StoreID, StoreName, InventoryValue,
           ROW_NUMBER() OVER (
               PARTITION BY ChainID ORDER BY InventoryValue DESC, StoreID
           ) AS PositionInChain
    FROM Inventory
)
SELECT cs.Name AS ChainName, r.StoreName, r.InventoryValue
FROM Ranked AS r
INNER JOIN dbo.Chain_Store AS cs ON cs.ID = r.ChainID
WHERE r.PositionInChain = 1
ORDER BY r.ChainID;
```

چهار ردیف برمی‌گردد. بهترین شعبهٔ شهروند، صادقیه با ارزش موجودی **۲۲٬۱۷۵٫۰۰** است. محدودهٔ استفاده از CTE همان یک دستور بعد از تعریف آن است. برای استفاده از نتیجه در چند دستور همان اتصال، می‌توانید از جدول موقت مثل `#Inventory` استفاده کنید.

## مقایسهٔ دو مجموعه

`EXCEPT` ردیف‌های سمت اول را که در نتیجهٔ سمت دوم حضور ندارند برمی‌گرداند. این مثال شناسهٔ محصولاتی را پیدا می‌کند که در شعبهٔ ۱ موجودند ولی در شعبهٔ ۲ نیستند.

```sql
SELECT P_ID AS ProductID
FROM dbo.StoreProduct
WHERE S_ID = 1 AND Amount > 0
EXCEPT
SELECT P_ID
FROM dbo.StoreProduct
WHERE S_ID = 2 AND Amount > 0
ORDER BY ProductID;
```

خروجی شناسه‌های **۲، ۳ و ۴** است. با جایگزین کردن `INTERSECT`، محصول مشترک با شناسهٔ **۱** را پیدا می‌کنید. `UNION` دو نتیجه را با حذف تکرار ترکیب می‌کند و `UNION ALL` ردیف‌های تکراری را هم نگه می‌دارد.

## تغییر داده و بررسی نتیجه

این تمرین را در یک اتصال تازه اجرا کنید. در یک جدول موقت، محصولی اضافه می‌کنید، قیمتش را تغییر می‌دهید و سپس آن را حذف می‌کنید. `OUTPUT` مقادیر هر مرحله را نشان می‌دهد و در پایان با `ROLLBACK` تغییرات تمرینی را برمی‌گردانید.

```sql
DROP TABLE IF EXISTS #PricePractice;
CREATE TABLE #PricePractice
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Price DECIMAL(10, 2) NOT NULL CHECK (Price > 0)
);

SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO #PricePractice (Name, Price)
    OUTPUT inserted.ID, inserted.Price AS InsertedPrice
    VALUES (N'محصول تمرینی تراکنش', 18.00);

    UPDATE #PricePractice
    SET Price = 19.50
    OUTPUT deleted.Price AS OldPrice, inserted.Price AS NewPrice
    WHERE Name = N'محصول تمرینی تراکنش';

    DELETE FROM #PricePractice
    OUTPUT deleted.ID AS RemovedProduct
    WHERE Name = N'محصول تمرینی تراکنش';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

DROP TABLE #PricePractice;
```

در پیام خروجی `UPDATE` قیمت قبلی **۱۸٫۰۰** و قیمت جدید **۱۹٫۵۰** است. برای یک `UPDATE`، ستون‌های `deleted` مقادیر قبلی و ستون‌های `inserted` مقادیر جدید را نشان می‌دهند.

## برنامهٔ اجرا و خواندن صفحات

در SSMS گزینهٔ **Include Actual Execution Plan** را فعال کنید. این آزمایش یک جدول موقت با ۱۰٬۰۰۰ ردیف می‌سازد. هر دو جست‌وجو ۱۰ ردیف برمی‌گردانند. مقدار **logical reads** را در بخش پیام‌ها و عملگر دسترسی به جدول را در برنامهٔ اجرا مقایسه کنید. برای `GENERATE_SERIES` به SQL Server 2022 یا جدیدتر و compatibility level حداقل ۱۶۰ نیاز دارید.

```sql
DROP TABLE IF EXISTS #InventorySearch;

SELECT value AS InventoryID,
       value % 1000 AS ProductID,
       value % 200 AS Amount
INTO #InventorySearch
FROM GENERATE_SERIES(1, 10000);

SET STATISTICS IO ON;

SELECT InventoryID, Amount
FROM #InventorySearch
WHERE ProductID = 42;

CREATE INDEX IX_InventorySearch_Product
ON #InventorySearch (ProductID) INCLUDE (InventoryID, Amount);

SELECT InventoryID, Amount
FROM #InventorySearch
WHERE ProductID = 42;

SET STATISTICS IO OFF;
DROP TABLE #InventorySearch;
```

ستون `ProductID` کلید جست‌وجو است و دو ستون `INCLUDE` داده‌های لازم برای خروجی را در خود ایندکس فراهم می‌کنند. اثر ایندکس را با برنامهٔ اجرا و حجم خواندن داده اندازه‌گیری کنید.

## سطح دسترسی به گزارش

در این مثال به کاربر آزمایشی فقط مجوز خواندن ویوی کارمندان را می‌دهیم. با `EXECUTE AS USER` دسترسی را از دید او بررسی می‌کنیم و با `REVERT` به هویت اولیه برمی‌گردیم.

```sql
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    CREATE ROLE RetailReportReader AUTHORIZATION dbo;
    CREATE USER RetailDemoReader WITHOUT LOGIN;
    ALTER ROLE RetailReportReader ADD MEMBER RetailDemoReader;
    GRANT SELECT ON OBJECT::dbo.vwEmployee TO RetailReportReader;

    EXECUTE AS USER = N'RetailDemoReader';
    BEGIN TRY
        SELECT COUNT(*) AS ReadableEmployeeRows FROM dbo.vwEmployee;
    END TRY
    BEGIN CATCH
        REVERT;
        THROW;
    END CATCH;
    REVERT;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

در دادهٔ نمونه، کاربر **۸** ردیف از ویو می‌خواند. می‌توانید با یک نقش، همین مجوز را به چند کاربر پایگاه داده بدهید.

## نسخهٔ پشتیبان

در نمونهٔ توسعه، مسیر زیر را با یک فایل جدید در پوشه‌ای جایگزین کنید که سرویس SQL Server روی سرور اجازهٔ نوشتن در آن دارد. `COPY_ONLY` یک پشتیبان کامل مستقل می‌سازد و `RESTORE VERIFYONLY` خوانا بودن فایل را بررسی می‌کند. برای تمرین بازیابی کامل، `FILELISTONLY` نام منطقی فایل‌ها را نشان می‌دهد تا با `RESTORE DATABASE ... WITH MOVE` آن‌ها را در یک دیتابیس تازه بازیابی کنید. [راهنمای بازیابی Microsoft Learn](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-to-a-new-location-sql-server)

```sql
DECLARE @BackupFile NVARCHAR(4000) = N'/var/opt/mssql/backup/SQLServerTutorialDB-practice.bak';

BACKUP DATABASE SQLServerTutorialDB TO DISK = @BackupFile WITH COPY_ONLY, CHECKSUM;
RESTORE VERIFYONLY FROM DISK = @BackupFile WITH CHECKSUM;
RESTORE FILELISTONLY FROM DISK = @BackupFile;
```

## تمرین نهایی

یک گزارش بسازید که برای هر شعبه، نام زنجیره، نام شعبه، تعداد کارمندان و ارزش موجودی را نشان دهد. ابتدا موجودی و کارمندان را جداگانه به سطح شعبه جمع بزنید. اتصال مستقیم ردیف‌های موجودی و کارمندان می‌تواند شمارش را چند برابر کند.

گزارش باید **۶** ردیف داشته باشد. جمع ارزش موجودی **۹۸٬۱۶۰٫۰۰** است. شعبهٔ شهروند صادقیه در رتبهٔ اول ارزش موجودی قرار دارد و **۲** کارمند دارد.

<details>
<summary>پاسخ پیشنهادی</summary>

```sql
;WITH Staff AS
(
    SELECT S_ID AS StoreID, COUNT(*) AS EmployeeCount
    FROM dbo.Employee
    GROUP BY S_ID
),
Inventory AS
(
    SELECT sp.S_ID AS StoreID, SUM(p.Price * sp.Amount) AS InventoryValue
    FROM dbo.StoreProduct AS sp
    INNER JOIN dbo.Product AS p ON p.ID = sp.P_ID
    GROUP BY sp.S_ID
)
SELECT cs.Name AS ChainName, s.Name AS StoreName,
       COALESCE(e.EmployeeCount, 0) AS EmployeeCount,
       COALESCE(i.InventoryValue, 0) AS InventoryValue
FROM dbo.Store AS s
INNER JOIN dbo.Chain_Store AS cs ON cs.ID = s.C_ID
LEFT JOIN Staff AS e ON e.StoreID = s.ID
LEFT JOIN Inventory AS i ON i.StoreID = s.ID
ORDER BY InventoryValue DESC, s.ID;
```

</details>

[بازگشت به آموزش فارسی](../README.fa.md)
