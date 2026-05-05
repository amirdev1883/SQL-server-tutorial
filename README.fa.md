# SQL-server-tutorial

جزوه و آموزش عملی SQL Server با مثال‌های واقعی روی یک سناریوی فروشگاه زنجیره‌ای

> این مخزن برای یادگیری مرحله‌به‌مرحله SQL Server طراحی شده است.  
> از مفاهیم پایه مثل `CREATE TABLE`، `INSERT` و `SELECT` شروع می‌کنیم و به مباحث مهم‌تری مثل `JOIN`، `VIEW`، `Stored Procedure`، `Function`، `Trigger`، `Cursor`، `Transaction`، `Index` و بررسی متادیتای دیتابیس می‌رسیم.

## فهرست مطالب

- [معرفی پروژه](#معرفی-پروژه)
- [SQL چیست و SQL Server چیست](#sql-چیست-و-sql-server-چیست)
- [اهداف آموزشی این مخزن](#اهداف-آموزشی-این-مخزن)
- [مدل داده و روابط بین جداول](#مدل-داده-و-روابط-بین-جداول)
- [اسکریپت کامل ساخت دیتابیس و جداول](#اسکریپت-کامل-ساخت-دیتابیس-و-جداول)
- [درج داده‌های نمونه](#درج-دادههای-نمونه)
- [کوئری‌های پایه](#کوئریهای-پایه)
- [JOIN و تحلیل داده‌ها](#join-و-تحلیل-دادهها)
- [View در SQL Server](#view-در-sql-server)
- [Stored Procedure](#stored-procedure)
- [Function](#function)
- [Trigger](#trigger)
- [Cursor](#cursor)
- [Transaction و کنترل خطا](#transaction-و-کنترل-خطا)
- [Index و کارایی](#index-و-کارایی)
- [بررسی آبجکت‌ها و متادیتا](#بررسی-آبجکتها-و-متادیتا)
- [نکات مهم و بهترین‌عمل‌ها](#نکات-مهم-و-بهترینعملها)
- [جمع‌بندی](#جمع‌بندی)

## معرفی پروژه

در این پروژه یک سناریوی ساده ولی کاربردی از **فروشگاه زنجیره‌ای** پیاده‌سازی شده است.  
هدف این است که با استفاده از چند جدول مرتبط، هم مفاهیم رابطه‌ای پایگاه داده را یاد بگیریم و هم با دستورات پرکاربرد SQL Server کار کنیم.

سناریوی ما شامل این بخش‌هاست:

- **Product**: اطلاعات محصولات
- **Chain_Store**: برند یا مجموعه فروشگاه زنجیره‌ای
- **Store**: شعبه‌های هر فروشگاه زنجیره‌ای
- **Employee**: کارمندان هر شعبه
- **StoreProduct**: موجودی هر محصول در هر شعبه

این ساختار برای آموزش بسیار مناسب است، چون هم رابطه‌ی **یک‌به‌چند** دارد و هم رابطه‌ی **چندبه‌چند**.

## SQL چیست و SQL Server چیست

- **SQL** یک زبان استاندارد برای کار با پایگاه داده‌های رابطه‌ای است.
- **SQL Server** یک سیستم مدیریت پایگاه داده (RDBMS) از مایکروسافت است.
- در SQL Server ما معمولاً از لهجه‌ی مخصوص آن یعنی **T-SQL** استفاده می‌کنیم که امکانات بیشتری مثل:
  - متغیر
  - شرط
  - حلقه
  - Stored Procedure
  - Trigger
  - Function
  - Transaction
  را در اختیار ما قرار می‌دهد.

## اهداف آموزشی این مخزن

بعد از مطالعه این جزوه، باید بتوانید:

- جدول بسازید و بین جدول‌ها رابطه تعریف کنید
- داده درج کنید
- داده‌ها را فیلتر، مرتب و گروه‌بندی کنید
- چند جدول را با `JOIN` به هم متصل کنید
- `VIEW` بسازید و تغییر دهید
- `Stored Procedure` و `Function` بنویسید
- با `Trigger`ها کار کنید
- مفهوم `Cursor` را بفهمید و با جایگزین بهتر آن آشنا شوید
- از `Transaction` و `TRY...CATCH` برای کنترل خطا استفاده کنید
- اهمیت `Index`ها در سرعت کوئری را درک کنید
- آبجکت‌های دیتابیس را از طریق `sys.objects` و `sys.sql_modules` بررسی کنید

## مدل داده و روابط بین جداول

### رابطه‌ها

- هر **Chain_Store** می‌تواند چند **Store** داشته باشد.  
  `Chain_Store (1) ---- (N) Store`

- هر **Store** می‌تواند چند **Employee** داشته باشد.  
  `Store (1) ---- (N) Employee`

- هر **Store** می‌تواند چند **Product** داشته باشد و هر **Product** هم می‌تواند در چند **Store** وجود داشته باشد.  
  بنابراین بین Store و Product یک رابطه‌ی **چندبه‌چند** داریم که با جدول واسط **StoreProduct** پیاده‌سازی می‌شود.  
  `Store (N) ---- (N) Product`

### چرا این مدل خوب است؟

این مدل چند مفهوم مهم دیتابیس را هم‌زمان آموزش می‌دهد:

- کلید اصلی (`PRIMARY KEY`)
- کلید خارجی (`FOREIGN KEY`)
- جدول واسط
- یکپارچگی داده
- کوئری‌نویسی چندجدولی
- گزارش‌گیری روی داده‌های مرتبط

## اسکریپت کامل ساخت دیتابیس و جداول

در این نسخه، ساختار جداول کمی حرفه‌ای‌تر شده است:

- برای ستون‌های مالی از `DECIMAL` استفاده شده
- برای متن فارسی از `NVARCHAR` استفاده شده
- برای جلوگیری از داده‌ی نامعتبر، از `CHECK` استفاده شده
- برای جلوگیری از ثبت تکراری یک محصول در یک فروشگاه، روی `(S_ID, P_ID)` محدودیت `UNIQUE` گذاشته شده
- نام قیدها (`CONSTRAINT`) به‌صورت صریح مشخص شده تا مدیریت دیتابیس راحت‌تر باشد

```sql
IF DB_ID(N'SQLServerTutorialDB') IS NULL
    CREATE DATABASE SQLServerTutorialDB;
GO

USE SQLServerTutorialDB;
GO

-- برای اجرای مجدد اسکریپت
IF OBJECT_ID(N'dbo.StoreProduct', N'U') IS NOT NULL DROP TABLE dbo.StoreProduct;
IF OBJECT_ID(N'dbo.Employee', N'U') IS NOT NULL DROP TABLE dbo.Employee;
IF OBJECT_ID(N'dbo.Store', N'U') IS NOT NULL DROP TABLE dbo.Store;
IF OBJECT_ID(N'dbo.Product', N'U') IS NOT NULL DROP TABLE dbo.Product;
IF OBJECT_ID(N'dbo.Chain_Store', N'U') IS NOT NULL DROP TABLE dbo.Chain_Store;
GO

CREATE TABLE dbo.Chain_Store
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Chain_Store PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL CONSTRAINT UQ_Chain_Store_Name UNIQUE
);
GO

CREATE TABLE dbo.Product
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Product PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT CK_Product_Price CHECK (Price > 0)
);
GO

CREATE TABLE dbo.Store
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Store PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Zone TINYINT NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    C_ID INT NOT NULL,
    CONSTRAINT FK_Store_Chain_Store FOREIGN KEY (C_ID) REFERENCES dbo.Chain_Store(ID),
    CONSTRAINT CK_Store_Zone CHECK (Zone BETWEEN 1 AND 20)
);
GO

CREATE TABLE dbo.Employee
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Employee PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    S_ID INT NOT NULL,
    CONSTRAINT FK_Employee_Store FOREIGN KEY (S_ID) REFERENCES dbo.Store(ID),
    CONSTRAINT CK_Employee_Salary CHECK (Salary > 0)
);
GO

CREATE TABLE dbo.StoreProduct
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_StoreProduct PRIMARY KEY,
    S_ID INT NOT NULL,
    P_ID INT NOT NULL,
    Amount INT NOT NULL,
    CONSTRAINT FK_StoreProduct_Store FOREIGN KEY (S_ID) REFERENCES dbo.Store(ID),
    CONSTRAINT FK_StoreProduct_Product FOREIGN KEY (P_ID) REFERENCES dbo.Product(ID),
    CONSTRAINT CK_StoreProduct_Amount CHECK (Amount >= 0),
    CONSTRAINT UQ_StoreProduct_Store_Product UNIQUE (S_ID, P_ID)
);
GO
```

### توضیح جدول‌ها

#### جدول `Product`

```sql
CREATE TABLE dbo.Product
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Product PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT CK_Product_Price CHECK (Price > 0)
);
```

**توضیح:**

- `ID` کلید اصلی جدول است
- `IDENTITY(1,1)` یعنی مقدار از 1 شروع می‌شود و هر بار 1 واحد بیشتر می‌شود
- `NVARCHAR(100)` برای ذخیره‌ی متن فارسی و انگلیسی مناسب است
- `DECIMAL(10,2)` یعنی عددی با **10 رقم کل** و **2 رقم اعشار**
- `CHECK (Price > 0)` اجازه نمی‌دهد قیمت منفی یا صفر ذخیره شود

#### جدول `Chain_Store`

```sql
CREATE TABLE dbo.Chain_Store
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Chain_Store PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL CONSTRAINT UQ_Chain_Store_Name UNIQUE
);
```

**توضیح:**

- این جدول نام برند یا مجموعه‌ی فروشگاه زنجیره‌ای را نگه می‌دارد
- روی `Name` محدودیت `UNIQUE` گذاشته‌ایم تا نام تکراری ثبت نشود

#### جدول `Store`

```sql
CREATE TABLE dbo.Store
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Store PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Zone TINYINT NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    C_ID INT NOT NULL,
    CONSTRAINT FK_Store_Chain_Store FOREIGN KEY (C_ID) REFERENCES dbo.Chain_Store(ID),
    CONSTRAINT CK_Store_Zone CHECK (Zone BETWEEN 1 AND 20)
);
```

**توضیح:**

- `Zone` از نوع `TINYINT` است و برای مقادیر کوچک عددی مناسب است
- `C_ID` کلید خارجی به جدول `Chain_Store` است
- بنابراین هر Store به یک Chain_Store وابسته است

#### جدول `Employee`

```sql
CREATE TABLE dbo.Employee
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Employee PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    S_ID INT NOT NULL,
    CONSTRAINT FK_Employee_Store FOREIGN KEY (S_ID) REFERENCES dbo.Store(ID),
    CONSTRAINT CK_Employee_Salary CHECK (Salary > 0)
);
```

**توضیح:**

- هر کارمند متعلق به یک فروشگاه است
- `Salary` از نوع `DECIMAL` است چون برای اعداد مالی مناسب‌تر از `FLOAT` است

#### جدول `StoreProduct`

```sql
CREATE TABLE dbo.StoreProduct
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_StoreProduct PRIMARY KEY,
    S_ID INT NOT NULL,
    P_ID INT NOT NULL,
    Amount INT NOT NULL,
    CONSTRAINT FK_StoreProduct_Store FOREIGN KEY (S_ID) REFERENCES dbo.Store(ID),
    CONSTRAINT FK_StoreProduct_Product FOREIGN KEY (P_ID) REFERENCES dbo.Product(ID),
    CONSTRAINT CK_StoreProduct_Amount CHECK (Amount >= 0),
    CONSTRAINT UQ_StoreProduct_Store_Product UNIQUE (S_ID, P_ID)
);
```

**توضیح:**

- این جدول **جدول واسط** بین Store و Product است
- `Amount` مقدار موجودی هر محصول در هر شعبه را نشان می‌دهد
- محدودیت `UNIQUE (S_ID, P_ID)` باعث می‌شود یک محصول برای یک فروشگاه دوبار ثبت نشود

## درج داده‌های نمونه

### نکته مهم درباره متن فارسی

برای درج متن فارسی در SQL Server بهتر است قبل از رشته‌ها از `N` استفاده کنیم:

- درست: `N'تهران'`
- نادرست: `'تهران'`

این کار باعث می‌شود رشته به‌صورت Unicode تفسیر شود.

### درج داده در جدول Chain_Store

```sql
INSERT INTO dbo.Chain_Store (Name)
VALUES
    (N'فروشگاه‌های شهروند'),
    (N'هایپراستار'),
    (N'رفاه'),
    (N'جانبو');
GO
```

### درج داده در جدول Product

```sql
INSERT INTO dbo.Product (Name, Price)
VALUES
    (N'لبنیات پرچرب', 45.50),
    (N'نوشابه خانواده', 12.75),
    (N'روغن نباتی', 32.00),
    (N'برنج ایرانی', 120.00),
    (N'ماکارونی', 15.25),
    (N'شیر کم چرب', 28.50),
    (N'تخم مرغ', 35.00),
    (N'مرغ بسته‌بندی', 85.00);
GO
```

### درج داده در جدول Store

```sql
INSERT INTO dbo.Store (Name, Zone, City, Address, C_ID)
VALUES
    (N'شهروند صادقیه', 1, N'تهران', N'میدان صادقیه، بلوار آیت‌الله کاشانی', 1),
    (N'شهروند ونک', 2, N'تهران', N'میدان ونک، خیابان ملاصدرا', 1),
    (N'هایپراستار اصفهان', 3, N'اصفهان', N'چهارباغ بالا، مجتمع پارک', 2),
    (N'رفاه شیراز', 4, N'شیراز', N'بلوار زند، جنب بازار وکیل', 3),
    (N'جانبو مشهد', 5, N'مشهد', N'بلوار وکیل‌آباد، مجتمع الماس شرق', 4),
    (N'هایپراستار کرج', 1, N'کرج', N'میدان شهدا، بلوار موذن', 2);
GO
```

### درج داده در جدول Employee

```sql
INSERT INTO dbo.Employee (Name, Salary, S_ID)
VALUES
    (N'محمد حسینی', 8500000.00, 1),
    (N'فاطمه محمدی', 7800000.00, 1),
    (N'رضا کریمی', 9200000.00, 2),
    (N'زهرا احمدی', 8100000.00, 3),
    (N'علی رضایی', 9500000.00, 4),
    (N'نازنین نوروزی', 8800000.00, 5),
    (N'امیر عباسی', 9000000.00, 6),
    (N'سمیه غفاری', 8300000.00, 2);
GO
```

### درج داده در جدول StoreProduct

```sql
INSERT INTO dbo.StoreProduct (S_ID, P_ID, Amount)
VALUES
    -- شهروند صادقیه
    (1, 1, 150), (1, 2, 200), (1, 3, 100), (1, 4, 80),

    -- شهروند ونک
    (2, 1, 120), (2, 5, 180), (2, 6, 90), (2, 7, 110),

    -- هایپراستار اصفهان
    (3, 2, 160), (3, 3, 70), (3, 4, 60), (3, 8, 50),

    -- رفاه شیراز
    (4, 1, 90), (4, 6, 120), (4, 7, 80), (4, 5, 150),

    -- جانبو مشهد
    (5, 3, 110), (5, 4, 70), (5, 8, 60), (5, 2, 180),

    -- هایپراستار کرج
    (6, 1, 130), (6, 2, 170), (6, 5, 140), (6, 7, 100);
GO
```

## کوئری‌های پایه

## نمایش همه داده‌ها

```sql
SELECT * FROM dbo.Chain_Store;
SELECT * FROM dbo.Store;
SELECT * FROM dbo.Employee;
SELECT * FROM dbo.Product;
SELECT * FROM dbo.StoreProduct;
```

**توضیح:**  
`SELECT *` تمام ستون‌های جدول را برمی‌گرداند.  
در پروژه‌های واقعی بهتر است فقط ستون‌های موردنیاز را انتخاب کنید.

## انتخاب ستون‌های خاص

```sql
SELECT Name, Price
FROM dbo.Product;
```

**توضیح:**  
در اینجا فقط نام و قیمت محصول‌ها نمایش داده می‌شود.

## فیلتر کردن با WHERE

### حقوق بیشتر از مقدار مشخص

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary > 8500000;
```

### حقوق بین دو مقدار

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary BETWEEN 8500000 AND 9000000;
```

### جستجو با LIKE

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Name LIKE N'%ر%';
```

**توضیح:**

- `WHERE` برای فیلتر کردن ردیف‌ها استفاده می‌شود
- `BETWEEN` بازه را شامل ابتدا و انتها در نظر می‌گیرد
- `LIKE` برای جستجوی الگو است
- `%` یعنی هر تعداد کاراکتر

## DISTINCT

```sql
SELECT DISTINCT City
FROM dbo.Store;
```

**توضیح:**  
`DISTINCT` داده‌های تکراری را حذف می‌کند.

## مرتب‌سازی با ORDER BY

```sql
SELECT Name, Price
FROM dbo.Product
ORDER BY Price DESC;
```

**توضیح:**

- `ASC` = صعودی
- `DESC` = نزولی

## توابع تجمیعی

```sql
SELECT
    COUNT(*) AS TotalProducts,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice,
    AVG(Price) AS AvgPrice,
    SUM(Price) AS SumPrice
FROM dbo.Product;
```

**توضیح:**  
توابع تجمیعی روی مجموعه‌ای از سطرها کار می‌کنند و یک مقدار نهایی می‌دهند.

## GROUP BY

```sql
SELECT
    S_ID,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AvgSalary,
    SUM(Salary) AS TotalSalary
FROM dbo.Employee
GROUP BY S_ID;
```

**توضیح:**  
`GROUP BY` داده‌ها را بر اساس یک یا چند ستون گروه‌بندی می‌کند.

## HAVING

```sql
SELECT
    S_ID,
    COUNT(*) AS EmployeeCount
FROM dbo.Employee
GROUP BY S_ID
HAVING COUNT(*) > 1;
```

**توضیح:**  
اگر `WHERE` برای ردیف‌ها باشد، `HAVING` برای **گروه‌ها** است.

## Subquery

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary > (
    SELECT AVG(Salary)
    FROM dbo.Employee
);
```

**توضیح:**  
در این مثال کارمندانی نمایش داده می‌شوند که حقوقشان از میانگین کل بیشتر است.

## Window Function

```sql
SELECT
    Name,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM dbo.Employee;
```

**توضیح:**  
این کوئری بدون گروه‌بندی داده‌ها، به هر کارمند یک رتبه بر اساس حقوق می‌دهد.

## JOIN و تحلیل داده‌ها

`JOIN` یکی از مهم‌ترین بخش‌های SQL است، چون در دیتابیس‌های رابطه‌ای معمولاً اطلاعات بین چند جدول پخش شده‌اند.

## INNER JOIN ساده

```sql
SELECT
    s.Name AS StoreName,
    COUNT(e.ID) AS EmployeeCount
FROM dbo.Store AS s
INNER JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
GROUP BY s.Name
ORDER BY s.Name;
```

**توضیح:**  
این کوئری نام هر فروشگاه و تعداد کارمندان آن را نمایش می‌دهد.

## LEFT JOIN

```sql
SELECT
    s.Name AS StoreName,
    e.Name AS EmployeeName
FROM dbo.Store AS s
LEFT JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
ORDER BY s.Name;
```

**توضیح:**  
اگر فروشگاهی کارمند نداشته باشد، باز هم نمایش داده می‌شود؛ فقط ستون کارمند `NULL` خواهد بود.

## JOIN چندجدولی صحیح

```sql
SELECT
    cs.Name AS ChainName,
    s.Name AS StoreName,
    e.Name AS EmployeeName
FROM dbo.Chain_Store AS cs
INNER JOIN dbo.Store AS s
    ON cs.ID = s.C_ID
INNER JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
ORDER BY ChainName, StoreName DESC, EmployeeName;
```

**توضیح:**  
این نسخه‌ی درست JOIN سه‌جدولی است:

- `Chain_Store` به `Store` از طریق `C_ID`
- `Store` به `Employee` از طریق `S_ID`

## گزارش موجودی هر فروشگاه

```sql
SELECT
    s.Name AS StoreName,
    p.Name AS ProductName,
    sp.Amount
FROM dbo.StoreProduct AS sp
INNER JOIN dbo.Store AS s
    ON sp.S_ID = s.ID
INNER JOIN dbo.Product AS p
    ON sp.P_ID = p.ID
ORDER BY s.Name, p.Name;
```

## ارزش تقریبی موجودی هر فروشگاه

```sql
SELECT
    s.Name AS StoreName,
    SUM(p.Price * sp.Amount) AS InventoryValue
FROM dbo.StoreProduct AS sp
INNER JOIN dbo.Store AS s
    ON sp.S_ID = s.ID
INNER JOIN dbo.Product AS p
    ON sp.P_ID = p.ID
GROUP BY s.Name
ORDER BY InventoryValue DESC;
```

**توضیح:**  
در اینجا قیمت هر محصول در تعداد موجودی آن ضرب شده و مجموع آن برای هر فروشگاه محاسبه می‌شود.

## View در SQL Server

`VIEW` یک جدول مجازی است که نتیجه‌ی یک کوئری را نگه می‌دارد.  
از Viewها برای این کارها استفاده می‌کنیم:

- ساده‌تر کردن کوئری‌های پیچیده
- بالا بردن خوانایی
- محدود کردن دسترسی مستقیم به جداول اصلی
- ایجاد یک لایه‌ی منطقی روی داده‌ها

## ساخت View ساده

```sql
CREATE VIEW dbo.vwEmployee
AS
SELECT
    cs.Name AS ChainName,
    s.Name AS StoreName,
    e.Name AS EmployeeName,
    e.Salary
FROM dbo.Chain_Store AS cs
INNER JOIN dbo.Store AS s
    ON cs.ID = s.C_ID
INNER JOIN dbo.Employee AS e
    ON s.ID = e.S_ID;
GO
```

## استفاده از View

```sql
SELECT * FROM dbo.vwEmployee;
SELECT DISTINCT EmployeeName FROM dbo.vwEmployee;
```

## View با محاسبات

```sql
CREATE VIEW dbo.vwStoreEmployeeCount
AS
SELECT
    s.Name AS StoreName,
    COUNT(e.ID) AS EmployeeCount
FROM dbo.Store AS s
LEFT JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
GROUP BY s.Name;
GO
```

## تغییر View

```sql
ALTER VIEW dbo.vwStoreEmployeeCount
AS
SELECT
    s.Name AS StoreName,
    COUNT(e.ID) AS EmployeeCount
FROM dbo.Store AS s
LEFT JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
GROUP BY s.Name
HAVING COUNT(e.ID) > 1;
GO
```

## View با ENCRYPTION

```sql
CREATE VIEW dbo.vwStoreName
WITH ENCRYPTION
AS
SELECT DISTINCT Name
FROM dbo.Store;
GO
```

**نکته:**  
`WITH ENCRYPTION` باعث می‌شود متن تعریف View به‌صورت معمولی قابل مشاهده نباشد.

## Stored Procedure

Stored Procedure مجموعه‌ای از دستورات SQL است که با یک نام ذخیره می‌شود و می‌توان آن را بارها اجرا کرد.

مزایای آن:

- استفاده‌ی مجدد از منطق
- خوانایی بیشتر
- مدیریت بهتر خطا
- امکان ورودی و خروجی
- مناسب برای منطق تجاری

## رویه ساده

```sql
CREATE OR ALTER PROCEDURE dbo.GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ID, Name, Price
    FROM dbo.Product
    ORDER BY Name;
END;
GO
```

### اجرا

```sql
EXEC dbo.GetAllProducts;
```

## رویه با پارامتر ورودی

```sql
CREATE OR ALTER PROCEDURE dbo.GetProductsByPriceRange
    @MinPrice DECIMAL(10,2),
    @MaxPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ID, Name, Price
    FROM dbo.Product
    WHERE Price BETWEEN @MinPrice AND @MaxPrice
    ORDER BY Price;
END;
GO
```

### اجرا

```sql
EXEC dbo.GetProductsByPriceRange @MinPrice = 20, @MaxPrice = 50;
```

## رویه با پارامتر خروجی

```sql
CREATE OR ALTER PROCEDURE dbo.GetProductCount
    @Count INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @Count = COUNT(*)
    FROM dbo.Product;
END;
GO
```

### اجرا

```sql
DECLARE @ProductCount INT;

EXEC dbo.GetProductCount @Count = @ProductCount OUTPUT;

SELECT @ProductCount AS ProductCount;
```

## رویه سازگار با ساختار فعلی پروژه

در نسخه‌ی اولیه، مثالی با `CategoryID` وجود داشت؛ اما چون جدول Product فعلی چنین ستونی ندارد، این نسخه با ساختار واقعی پروژه هماهنگ شده است.

```sql
CREATE OR ALTER PROCEDURE dbo.GetProductsByStore
    @StoreID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ID,
        p.Name,
        p.Price,
        sp.Amount
    FROM dbo.StoreProduct AS sp
    INNER JOIN dbo.Product AS p
        ON sp.P_ID = p.ID
    WHERE sp.S_ID = @StoreID
    ORDER BY p.Name;
END;
GO
```

### اجرا

```sql
EXEC dbo.GetProductsByStore @StoreID = 1;
```

## رویه با کنترل خطا و بررسی ردیف‌های تغییرکرده

```sql
CREATE OR ALTER PROCEDURE dbo.UpdateProductPrice
    @ProductID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @NewPrice <= 0
            THROW 50001, N'قیمت محصول باید بیشتر از صفر باشد.', 1;

        UPDATE dbo.Product
        SET Price = @NewPrice
        WHERE ID = @ProductID;

        IF @@ROWCOUNT = 0
            THROW 50002, N'محصولی با این شناسه پیدا نشد.', 1;

        SELECT N'Price updated successfully' AS Result;
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH
END;
GO
```

### اجرا

```sql
EXEC dbo.UpdateProductPrice @ProductID = 1, @NewPrice = 49.90;
```

## Function

Function در SQL Server برای کپسوله کردن منطق محاسباتی استفاده می‌شود.

### انواع رایج Function

- **Scalar Function**: یک مقدار برمی‌گرداند
- **Inline Table-Valued Function**: یک جدول برمی‌گرداند
- **Multi-Statement Table-Valued Function**: یک جدول برمی‌گرداند اما با چند دستور

## Scalar Function

### محاسبه مالیات

```sql
CREATE OR ALTER FUNCTION dbo.CalculateTax(@Price DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Tax DECIMAL(10,2);

    SET @Tax = @Price * 0.09;

    RETURN @Tax;
END;
GO
```

### استفاده

```sql
SELECT
    Name,
    Price,
    dbo.CalculateTax(Price) AS Tax,
    Price + dbo.CalculateTax(Price) AS TotalPrice
FROM dbo.Product;
```

## Scalar Function دیگر

### تعداد کارمندان یک فروشگاه

```sql
CREATE OR ALTER FUNCTION dbo.GetEmployeeCount(@StoreID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;

    SELECT @Count = COUNT(*)
    FROM dbo.Employee
    WHERE S_ID = @StoreID;

    RETURN @Count;
END;
GO
```

### استفاده

```sql
SELECT
    Name,
    dbo.GetEmployeeCount(ID) AS EmployeeCount
FROM dbo.Store;
```

## Inline Table-Valued Function

### محصولات یک فروشگاه

```sql
CREATE OR ALTER FUNCTION dbo.GetStoreProducts(@StoreID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.Name AS ProductName,
        p.Price,
        sp.Amount AS Inventory
    FROM dbo.StoreProduct AS sp
    INNER JOIN dbo.Product AS p
        ON sp.P_ID = p.ID
    WHERE sp.S_ID = @StoreID
);
GO
```

### استفاده

```sql
SELECT *
FROM dbo.GetStoreProducts(1);
```

## Inline Table-Valued Function دیگر

### محصولات با موجودی کم

```sql
CREATE OR ALTER FUNCTION dbo.GetLowStockProducts(@Threshold INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        s.Name AS StoreName,
        p.Name AS ProductName,
        sp.Amount AS CurrentStock
    FROM dbo.StoreProduct AS sp
    INNER JOIN dbo.Store AS s
        ON sp.S_ID = s.ID
    INNER JOIN dbo.Product AS p
        ON sp.P_ID = p.ID
    WHERE sp.Amount < @Threshold
);
GO
```

### استفاده

```sql
SELECT *
FROM dbo.GetLowStockProducts(100);
```

## Multi-Statement Table-Valued Function

### خلاصه اطلاعات فروشگاه‌های یک زنجیره

```sql
CREATE OR ALTER FUNCTION dbo.GetStoreSummary(@ChainID INT)
RETURNS @Result TABLE
(
    StoreName NVARCHAR(100),
    City NVARCHAR(100),
    EmployeeCount INT,
    ProductCount INT,
    TotalInventoryValue DECIMAL(18,2)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT
        s.Name AS StoreName,
        s.City,
        (
            SELECT COUNT(*)
            FROM dbo.Employee AS e
            WHERE e.S_ID = s.ID
        ) AS EmployeeCount,
        (
            SELECT COUNT(*)
            FROM dbo.StoreProduct AS sp
            WHERE sp.S_ID = s.ID
        ) AS ProductCount,
        (
            SELECT SUM(p.Price * sp.Amount)
            FROM dbo.StoreProduct AS sp
            INNER JOIN dbo.Product AS p
                ON sp.P_ID = p.ID
            WHERE sp.S_ID = s.ID
        ) AS TotalInventoryValue
    FROM dbo.Store AS s
    WHERE s.C_ID = @ChainID;

    RETURN;
END;
GO
```

### استفاده

```sql
SELECT *
FROM dbo.GetStoreSummary(1);
```

## نکات مهم درباره Function

- Function برای محاسبه و بازگرداندن نتیجه مناسب است
- Function نباید منطق سنگین و غیرضروری داشته باشد
- در SQL Server بهتر است همیشه Function را با نام کامل اسکیمای آن صدا بزنید، مثل:
  - `dbo.CalculateTax(...)`
  - `dbo.GetStoreProducts(...)`

## Trigger

Trigger نوعی Stored Procedure ویژه است که به‌صورت خودکار در پاسخ به یک رویداد اجرا می‌شود.

### انواع Trigger

- **DML Trigger**: روی `INSERT`، `UPDATE`، `DELETE`
- **DDL Trigger**: روی `CREATE`، `ALTER`، `DROP`
- **Logon Trigger**: هنگام ورود کاربر

## DML Trigger برای اعتبارسنجی قیمت

به‌جای اینکه فقط جلوی INSERT را با `PRINT` بگیریم، بهتر است مثال واقعی‌تری بزنیم.

```sql
CREATE OR ALTER TRIGGER dbo.trg_Product_ValidatePrice
ON dbo.Product
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Price <= 0
    )
    BEGIN
        THROW 50010, N'قیمت محصول باید بیشتر از صفر باشد.', 1;
    END
END;
GO
```

### تست Trigger

```sql
INSERT INTO dbo.Product (Name, Price)
VALUES (N'محصول تستی', -10);
```

**رفتار مورد انتظار:**  
این دستور با خطا متوقف می‌شود، چون قیمت منفی مجاز نیست.

## Trigger از نوع INSTEAD OF

این نوع Trigger قبل از اجرای عملیات اصلی، جای آن را می‌گیرد.

```sql
CREATE OR ALTER TRIGGER dbo.trg_Product_InsteadOfInsert
ON dbo.Product
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Price <= 0
    )
    BEGIN
        THROW 50011, N'درج محصول با قیمت نامعتبر مجاز نیست.', 1;
    END;

    INSERT INTO dbo.Product (Name, Price)
    SELECT Name, Price
    FROM inserted;
END;
GO
```

### غیرفعال و فعال کردن Trigger

```sql
DISABLE TRIGGER dbo.trg_Product_InsteadOfInsert ON dbo.Product;
ENABLE TRIGGER dbo.trg_Product_InsteadOfInsert ON dbo.Product;
```

## DDL Trigger در سطح دیتابیس

```sql
CREATE OR ALTER TRIGGER trg_BlockTableChanges
ON DATABASE
FOR CREATE_TABLE, DROP_TABLE, ALTER_TABLE
AS
BEGIN
    RAISERROR(N'ایجاد، حذف یا تغییر جدول در این دیتابیس مجاز نیست.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO
```

**توضیح:**

- این Trigger در سطح دیتابیس تعریف شده
- اگر کسی بخواهد جدول بسازد، حذف کند یا تغییر دهد، خطا رخ می‌دهد
- `ROLLBACK` تغییر را برمی‌گرداند

## Cursor

Cursor یک ابزار برای پیمایش رکوردها **به‌صورت ردیف‌به‌ردیف** است.

به‌طور کلی در SQL بهتر است تا جای ممکن از عملیات **مجموعه‌ای (set-based)** استفاده شود، چون معمولاً هم ساده‌تر است و هم سریع‌تر.  
اما برای آموزش، دانستن Cursor مهم است.

## مثال Cursor

```sql
DECLARE @ID INT;
DECLARE @Salary DECIMAL(10,2);
DECLARE @SumSalary DECIMAL(18,2) = 0;

DECLARE emp_cur CURSOR FAST_FORWARD
FOR
SELECT ID, Salary
FROM dbo.Employee;

OPEN emp_cur;

FETCH NEXT FROM emp_cur
INTO @ID, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SumSalary = @SumSalary + @Salary;

    FETCH NEXT FROM emp_cur
    INTO @ID, @Salary;
END;

CLOSE emp_cur;
DEALLOCATE emp_cur;

PRINT @SumSalary;
```

### توضیح خط‌به‌خط

- `DECLARE emp_cur CURSOR` یک Cursor تعریف می‌کند
- `OPEN` آن را باز می‌کند
- `FETCH NEXT` رکورد بعدی را می‌خواند
- `@@FETCH_STATUS = 0` یعنی عملیات دریافت موفق بوده
- `CLOSE` Cursor را می‌بندد
- `DEALLOCATE` منابع آن را آزاد می‌کند

## جایگزین بهتر Cursor

همین کار را می‌توان بسیار ساده‌تر با یک کوئری set-based انجام داد:

```sql
SELECT SUM(Salary) AS TotalSalary
FROM dbo.Employee;
```

### نتیجه‌گیری درباره Cursor

- برای آموزش مهم است
- برای پردازش ردیفی کاربرد دارد
- ولی در اکثر سناریوها، روش set-based بهتر است

## Transaction و کنترل خطا

Transaction برای این است که چند عملیات را به‌صورت **یک واحد atomic** اجرا کنیم.  
اگر همه عملیات موفق بودند `COMMIT` می‌کنیم و اگر هرکدام شکست خورد `ROLLBACK`.

## مثال تراکنش

```sql
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Product
    SET Price = Price + 5
    WHERE ID = 1;

    UPDATE dbo.StoreProduct
    SET Amount = Amount - 10
    WHERE S_ID = 1 AND P_ID = 1;

    IF @@ROWCOUNT = 0
        THROW 50020, N'موجودی موردنظر برای به‌روزرسانی پیدا نشد.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH;
```

### چرا این مثال مهم است؟

در سیستم‌های واقعی، معمولاً چند دستور باید با هم موفق شوند.  
مثلاً اگر قیمت محصول تغییر کرد ولی موجودی کم نشد، داده‌ها ناسازگار می‌شوند.  
Transaction جلوی این مشکل را می‌گیرد.

## Index و کارایی

Indexها برای بالا بردن سرعت جستجو و JOIN بسیار مهم‌اند.

### چند ایندکس پیشنهادی برای این پروژه

```sql
CREATE NONCLUSTERED INDEX IX_Employee_S_ID
ON dbo.Employee (S_ID);
GO

CREATE NONCLUSTERED INDEX IX_Store_C_ID
ON dbo.Store (C_ID);
GO

CREATE NONCLUSTERED INDEX IX_StoreProduct_SID_PID
ON dbo.StoreProduct (S_ID, P_ID);
GO

CREATE NONCLUSTERED INDEX IX_Product_Name
ON dbo.Product (Name);
GO
```

### توضیح

- اگر زیاد روی `Employee.S_ID` JOIN می‌زنیم، ایندکس روی این ستون کمک می‌کند
- اگر زیاد روی `Store.C_ID` فیلتر یا JOIN داریم، ایندکس مفید است
- ایندکس ترکیبی روی `StoreProduct(S_ID, P_ID)` برای گزارش‌های موجودی مناسب است
- جستجو روی نام محصول هم با ایندکس بهینه‌تر می‌شود

### نکته مهم

- `PRIMARY KEY` و `UNIQUE` معمولاً خودشان ایندکس ایجاد می‌کنند
- اما روی کلیدهای خارجی هم معمولاً ساخت ایندکس مفید است

## بررسی آبجکت‌ها و متادیتا

یکی از قابلیت‌های مهم SQL Server این است که می‌توانید ساختار دیتابیس را از طریق catalog viewها بررسی کنید.

## مشاهده آبجکت‌ها

```sql
SELECT name, type, type_desc
FROM sys.objects
ORDER BY type, name;
```

## فقط جدول‌ها

```sql
SELECT name, type_desc
FROM sys.objects
WHERE type = 'U';
```

## فقط Viewها

```sql
SELECT name, type_desc
FROM sys.objects
WHERE type = 'V';
```

## فقط Triggerها

```sql
SELECT name, parent_class_desc, is_disabled
FROM sys.triggers;
```

## مشاهده تعریف یک View با OBJECT_DEFINITION

```sql
SELECT OBJECT_DEFINITION(OBJECT_ID(N'dbo.vwEmployee')) AS ViewDefinition;
```

## مشاهده تعریف آبجکت از طریق sys.sql_modules

```sql
SELECT sm.definition
FROM sys.sql_modules AS sm
WHERE sm.object_id = OBJECT_ID(N'dbo.vwEmployee');
```

## روش کلاسیک با sp_helptext

```sql
EXEC sp_helptext N'dbo.vwEmployee';
```

## توابع و متغیرهای سیستمی

### @@ROWCOUNT

```sql
UPDATE dbo.Product
SET Price = Price + 1
WHERE ID = 1;

SELECT @@ROWCOUNT AS AffectedRows;
```

**توضیح:**  
`@@ROWCOUNT` تعداد ردیف‌های تحت‌تأثیر آخرین دستور را برمی‌گرداند.

## نکات مهم و بهترین‌عمل‌ها

### 1) برای متن فارسی از `NVARCHAR` و پیشوند `N` استفاده کنید

```sql
INSERT INTO dbo.Store (Name, Zone, City, Address, C_ID)
VALUES (N'شعبه نمونه', 1, N'تهران', N'خیابان نمونه', 1);
```

### 2) برای داده‌های مالی از `DECIMAL` استفاده کنید

`FLOAT` برای داده‌های مالی مناسب نیست، چون ممکن است خطای تقریبی ایجاد کند.

### 3) همیشه نام Constraintها را خودتان تعیین کنید

مثال:

```sql
CONSTRAINT CK_Product_Price CHECK (Price > 0)
```

این کار در مدیریت و عیب‌یابی خیلی کمک می‌کند.

### 4) فقط در آموزش از `SELECT *` زیاد استفاده کنید

در پروژه‌ی واقعی، بهتر است ستون‌های موردنیاز را صریح بنویسید.

### 5) قبل از استفاده از Cursor فکر کنید که آیا با یک کوئری عادی هم می‌شود؟

در اکثر مواقع پاسخ **بله** است.

### 6) در Triggerها به‌صورت set-based فکر کنید

Trigger ممکن است روی چند ردیف به‌صورت هم‌زمان اجرا شود.  
پس نباید فرض کنید همیشه فقط یک سطر در `inserted` یا `deleted` وجود دارد.

### 7) از `TRY...CATCH` برای منطق حساس استفاده کنید

به‌خصوص در:

- Stored Procedure
- Transaction
- عملیات مالی یا چندمرحله‌ای

### 8) از اسکیمای `dbo` در نام آبجکت‌ها استفاده کنید

مثال:

- `dbo.Product`
- `dbo.GetAllProducts`
- `dbo.vwEmployee`

این کار هم خوانایی را بهتر می‌کند و هم اجرای آبجکت‌ها را واضح‌تر می‌سازد.

### 9) روی ستون‌های پرتکرار در JOIN و WHERE ایندکس مناسب بسازید

خصوصاً:

- کلیدهای خارجی
- ستون‌های جستجوی پرتکرار
- ستون‌های مرتب‌سازی پرتکرار

### 10) CHECK به‌تنهایی جای NOT NULL را نمی‌گیرد

اگر ستونی نباید خالی باشد، حتماً `NOT NULL` هم بگذارید.

## جمع‌بندی

این پروژه یک مسیر آموزشی خوب برای یادگیری SQL Server است، چون هم مفاهیم پایه را پوشش می‌دهد و هم شما را با مباحث مهم‌تر آشنا می‌کند:

- طراحی جدول و رابطه
- درج و بازیابی داده
- فیلتر، مرتب‌سازی و گروه‌بندی
- JOINهای چندجدولی
- View
- Stored Procedure
- Function
- Trigger
- Cursor
- Transaction
- Index
- متادیتا و catalog viewها

اگر این مفاهیم را خوب یاد بگیرید، پایه‌ی بسیار مناسبی برای ورود به مباحث حرفه‌ای‌تر خواهید داشت؛ مثل:

- Normalization
- Security
- Query Optimization
- Execution Plan
- Advanced Indexing
- Backup / Restore
- SQL Server Agent
- Partitioning
- Performance Tuning
