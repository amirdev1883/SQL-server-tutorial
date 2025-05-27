# SQL-server-tutorial

# جزوه آموزشی SQL - تحلیل کامل کدهای ارائه شده

## بخش 1: ایجاد جداول (CREATE TABLE)

### 1.1 جدول Product
```sql
CREATE TABLE Product (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);
```
**توضیحات:**
- این جدول برای ذخیره اطلاعات محصولات ایجاد شده است
- `ID` به عنوان کلید اصلی با مقدار خودکار (IDENTITY) تعریف شده که از 1 شروع می‌شود و با قدم 1 افزایش می‌یابد
- `Name` از نوع NVARCHAR با حداکثر 100 کاراکتر و غیرقابل قبول مقدار NULL
- `Price` از نوع DECIMAL با 10 رقم کلی و 2 رقم اعشار

### 1.2 جدول Chain_Store
```sql
CREATE TABLE Chain_Store(
    ID INT PRIMARY KEY IDENTITY(1, 1),
    Name NVARCHAR(100) NOT NULL
);
```
**توضیحات:**
- جدول فروشگاه‌های زنجیره‌ای
- ساختار مشابه جدول Product دارد با این تفاوت که فقط فیلد Name را دارد

### 1.3 جدول Store
```sql
CREATE TABLE Store (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Zone TINYINT NOT NULL,
    City NVARCHAR (100) NOT NULL,
    Address NVARCHAR(100) NOT NULL,
    C_ID INT FOREIGN KEY REFERENCES Chain_Store (ID)
);
```
**توضیحات:**
- جدول فروشگاه‌های انفرادی
- شامل فیلدهای: نام، منطقه (Zone)، شهر، آدرس
- `C_ID` یک کلید خارجی است که به جدول Chain_Store ارتباط برقرار می‌کند

### 1.4 جدول Employee
```sql
CREATE TABLE Employee(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    S_ID INT FOREIGN KEY REFERENCES Store(ID)
);
```
**توضیحات:**
- جدول کارمندان
- شامل نام، حقوق و یک کلید خارجی به جدول Store
- هر کارمند به یک فروشگاه مرتبط است

### 1.5 جدول StoreProduct
```sql
CREATE TABLE StoreProduct(
    ID INT PRIMARY KEY IDENTITY(1,1),
    S_ID INT FOREIGN KEY REFERENCES Store(ID),
    p_ID INT FOREIGN KEY REFERENCES Product(ID),
    amount INT NOT NULL,
);
```
**توضیحات:**
- جدول ارتباطی بین فروشگاه و محصول (رابطه چند به چند)
- شامل کلیدهای خارجی به Store و Product
- فیلد amount تعداد موجودی محصول در هر فروشگاه را نشان می‌دهد

## بخش 2: درج داده‌ها (INSERT)

### 2.1 درج داده در Chain_Store
```sql
INSERT INTO Chain_Store (Name)
VALUES 
    ('فروشگاه‌های شهروند'),
    ('هایپراستار'),
    ('رفاه'),
    ('جانبو');
```
**توضیحات:**
- درج 4 رکورد برای فروشگاه‌های زنجیره‌ای
- مقادیر به زبان فارسی وارد شده‌اند

### 2.2 درج داده در Product
```sql
INSERT INTO Product (Name, Price)
VALUES
    ('لبنیات پرچرب', 45.50),
    ('نوشابه خانواده', 12.75),
    ('روغن نباتی', 32.00),
    ('برنج ایرانی', 120.00),
    ('ماکارونی', 15.25),
    ('شیر کم چرب', 28.50),
    ('تخم مرغ', 35.00),
    ('مرغ بسته‌بندی', 85.00);
```
**توضیحات:**
- درج 8 محصول مختلف با قیمت‌های متفاوت

### 2.3 درج داده در Store
```sql
INSERT INTO Store (Name, Zone, City, Address, C_ID)
VALUES
    ('شهروند صادقیه', 1, 'تهران', 'میدان صادقیه، بلوار آیت‌الله کاشانی', 1),
    ('شهروند ونک', 2, 'تهران', 'میدان ونک، خیابان ملاصدرا', 1),
    ('هایپراستار اصفهان', 3, 'اصفهان', 'چهارباغ بالا، مجتمع پارک', 2),
    ('رفاه شیراز', 4, 'شیراز', 'بلوار زند، جنب بازار وکیل', 3),
    ('جانبو مشهد', 5, 'مشهد', 'بلوار وکیل‌آباد، مجتمع الماس شرق', 4),
    ('هایپراستار کرج', 1, 'کرج', 'میدان شهدا، بلوار موذن', 2);
```
**توضیحات:**
- درج 6 فروشگاه در شهرهای مختلف
- هر فروشگاه به یک فروشگاه زنجیره‌ای مرتبط است

### 2.4 درج داده در Employee
```sql
INSERT INTO Employee (Name, Salary, S_ID)
VALUES
    ('محمد حسینی', 8500000.00, 1),
    ('فاطمه محمدی', 7800000.00, 1),
    ('رضا کریمی', 9200000.00, 2),
    ('زهرا احمدی', 8100000.00, 3),
    ('علی رضایی', 9500000.00, 4),
    ('نازنین نوروزی', 8800000.00, 5),
    ('امیر عباسی', 9000000.00, 6),
    ('سمیه غفاری', 8300000.00, 2);
```
**توضیحات:**
- درج 8 کارمند با حقوق‌های مختلف
- هر کارمند به یک فروشگاه مرتبط است

### 2.5 درج داده در StoreProduct
```sql
INSERT INTO StoreProduct (S_ID, p_ID, amount)
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
```
**توضیحات:**
- درج موجودی محصولات در هر فروشگاه
- هر فروشگاه چندین محصول با مقادیر مختلف دارد

## بخش 3: کوئری‌های پایه (SELECT)

### 3.1 نمایش تمام داده‌های جدول
```sql
SELECT * FROM Chain_Store;
SELECT * FROM Store;
SELECT * FROM Employee;
SELECT * FROM Product;
```
**توضیحات:**
- نمایش تمام رکوردها و ستون‌های هر جدول

### 3.2 فیلتر کردن با WHERE
```sql
SELECT Name, Salary FROM Employee
WHERE Salary > 8500000;
```
**توضیحات:**
- نمایش نام و حقوق کارمندانی که حقوقشان بیشتر از 8,500,000 است

```sql
SELECT Name, Salary FROM Employee
WHERE Salary BETWEEN 8500000 AND 9000000;
```
**توضیحات:**
- نمایش کارمندانی با حقوق بین 8,500,000 تا 9,000,000

```sql
SELECT Name, Salary FROM Employee
WHERE Name LIKE '%ر%';
```
**توضیحات:**
- نمایش کارمندانی که در نامشان حرف "ر" وجود دارد

### 3.3 گروه‌بندی با GROUP BY
```sql
SELECT S_ID, COUNT(*) AS EmployeeCount
FROM Employee
GROUP BY S_ID;
```
**توضیحات:**
- شمارش تعداد کارمندان هر فروشگاه

```sql
SELECT S_ID, Name, COUNT(*) AS EmployeeCount
FROM Employee
GROUP BY S_ID, Name;
```
**توضیحات:**
- گروه‌بندی بر اساس S_ID و Name

## بخش 4: کوئری‌های پیچیده (JOIN)

### 4.1 JOIN ساده
```sql
SELECT s.Name, COUNT(*) AS EmployeeCount
FROM Store s
INNER JOIN Employee e ON s.ID = e.S_ID
GROUP BY s.Name;
```
**توضیحات:**
- نمایش نام هر فروشگاه و تعداد کارمندان آن

### 4.2 JOIN با شرایط
```sql
SELECT COUNT(*) AS count, s.Name AS storeName
FROM Employee AS e 
INNER JOIN Store AS s ON e.S_ID = s.ID
WHERE Salary > 10000
GROUP BY s.Name
HAVING SUM(Salary) > 2000;
```
**توضیحات:**
- شمارش کارمندان هر فروشگاه که حقوقشان بیشتر از 10,000 است
- فقط فروشگاه‌هایی که مجموع حقوق کارمندانشان بیش از 2,000 است نمایش داده می‌شوند

### 4.3 JOIN چندگانه
```sql
SELECT Chain_Store.Name AS chain, Store.Name AS store, Employee.Name AS emp
FROM Chain_Store 
INNER JOIN Employee ON Chain_Store.ID = Employee.ID 
INNER JOIN Store ON Chain_Store.ID = Store.C_ID AND Employee.S_ID = Store.ID
ORDER BY chain, store DESC;
```
**توضیحات:**
- ارتباط سه جدول Chain_Store، Store و Employee
- نمایش نام زنجیره، نام فروشگاه و نام کارمند
- مرتب‌سازی بر اساس نام زنجیره و نام فروشگاه (نزولی)

## بخش 5: ویوها (VIEW)

### 5.1 ایجاد ویو ساده
```sql
CREATE VIEW vwEmployee AS 
SELECT Chain_Store.Name AS chain, Store.Name AS store, Employee.Name AS emp
FROM Chain_Store 
INNER JOIN Employee ON Chain_Store.ID = Employee.ID 
INNER JOIN Store ON Chain_Store.ID = Store.C_ID AND Employee.S_ID = Store.ID;
```
**توضیحات:**
- ایجاد یک ویو برای نمایش اطلاعات کارمندان همراه با فروشگاه و زنجیره مربوطه

### 5.2 استفاده از ویو
```sql
SELECT * FROM vwEmployee;
SELECT DISTINCT emp FROM vwEmployee;
```
**توضیحات:**
- نمایش تمام داده‌های ویو
- نمایش نام منحصر به فرد کارمندان

### 5.3 ویو با محاسبات
```sql
CREATE VIEW vw_storeEmployeeCount(storeName, employeeCount) AS
SELECT s.Name, e.c 
FROM (SELECT S_ID, COUNT(*) AS c FROM Employee GROUP BY S_ID) AS e 
INNER JOIN Store AS s ON e.S_ID = s.ID;
```
**توضیحات:**
- ویوی نمایش تعداد کارمندان هر فروشگاه

### 5.4 تغییر ویو
```sql
ALTER VIEW vw_storeEmployeeCount AS 
SELECT s.Name, e.c 
FROM (SELECT S_ID, COUNT(*) AS c FROM Employee GROUP BY S_ID HAVING COUNT(*)>1) AS e 
INNER JOIN Store AS s ON e.S_ID = s.ID;
```
**توضیحات:**
- تغییر ویو برای نمایش فقط فروشگاه‌هایی که بیش از یک کارمند دارند

### 5.5 ویو با رمزنگاری
```sql
CREATE VIEW vwStoreName WITH ENCRYPTION AS 
SELECT DISTINCT Name FROM Store;
```
**توضیحات:**
- ایجاد ویو با تعریف رمزنگاری شده

## بخش 6: رویه‌های ذخیره شده (Stored Procedures)

### 6.1 رویه ساده
```sql
CREATE PROCEDURE GetAllProducts
AS
BEGIN
    SELECT * FROM Product;
END;
```
**توضیحات:**
- رویه برای نمایش تمام محصولات

### 6.2 رویه با پارامتر ورودی
```sql
CREATE PROCEDURE GetProductsByPriceRange
    @MinPrice DECIMAL(10,2),
    @MaxPrice DECIMAL(10,2)
AS
BEGIN
    SELECT * 
    FROM Product
    WHERE Price BETWEEN @MinPrice AND @MaxPrice;
END;
```
**توضیحات:**
- نمایش محصولات در محدوده قیمتی مشخص

### 6.3 رویه با پارامتر خروجی
```sql
CREATE PROCEDURE GetProductCount
    @Count INT OUTPUT
AS
BEGIN
    SELECT @Count = COUNT(*) FROM Product;
END;
```
**توضیحات:**
- بازگرداندن تعداد کل محصولات از طریق پارامتر خروجی

### 6.4 رویه با پارامتر اختیاری
```sql
CREATE PROCEDURE GetProductsByCategory
    @CategoryID INT = NULL
AS
BEGIN
    IF @CategoryID IS NULL
        SELECT * FROM Product;
    ELSE
        SELECT * FROM Product WHERE CategoryID = @CategoryID;
END;
```
**توضیحات:**
- نمایش محصولات یک دسته‌بندی خاص یا همه محصولات اگر دسته‌بندی مشخص نشده باشد

### 6.5 رویه با کنترل خطا
```sql
CREATE PROCEDURE UpdateProductPrice
    @ProductID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    IF @NewPrice > 0
    BEGIN
        UPDATE Product 
        SET Price = @NewPrice
        WHERE ID = @ProductID;
        SELECT 'Price updated successfully' AS Result;
    END
    ELSE    
    BEGIN
        SELECT 'Price must be greater than 0' AS Result;
    END
END;
```
**توضیحات:**
- به‌روزرسانی قیمت محصول با بررسی اعتبار قیمت جدید

## بخش 7: توابع و متغیرهای سیستمی

### 7.1 @@ROWCOUNT
```sql
SELECT @@ROWCOUNT;
PRINT @@ROWCOUNT;
```
**توضیحات:**
- نمایش تعداد رکوردهای تأثیرگرفته از آخرین دستور

### 7.2 مشاهده اشیاء پایگاه داده
```sql
SELECT * FROM sys.objects;
SELECT DISTINCT type, type_desc FROM sys.objects;
SELECT * FROM sys.objects WHERE type='U'; -- Tables
SELECT * FROM sys.objects WHERE type='V'; -- Views
```
**توضیحات:**
- نمایش اطلاعات اشیاء پایگاه داده
- فیلتر کردن بر اساس نوع (جدول، ویو و ...)

### 7.3 مشاهده کد ویوها
```sql
SELECT text FROM sys.syscomments
WHERE id=OBJECT_ID('vwEmployee');
```
**توضیحات:**
- نمایش کد SQL تعریف کننده یک ویو

# آموزش توابع (Functions) در SQL Server بر اساس جداول شما

در SQL Server، توابع (Functions) امکان encapsulate کردن منطق محاسباتی و بازگرداندن نتایج را فراهم می‌کنند. بیایید بر اساس جداولی که ایجاد کردید، چند نوع تابع مختلف را بررسی کنیم.

## 1. توابع Scalar (مقدار تک)

این توابع یک مقدار واحد برمی‌گردانند.

### مثال 1: محاسبه مالیات بر محصول

```sql
CREATE FUNCTION CalculateTax(@price DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @tax DECIMAL(10,2)
    SET @tax = @price * 0.09 -- فرض کنید مالیات 9% باشد
    RETURN @tax
END
```

**استفاده از تابع:**

```sql
SELECT 
    Name, 
    Price, 
    dbo.CalculateTax(Price) AS Tax,
    Price + dbo.CalculateTax(Price) AS TotalPrice
FROM Product
```

### مثال 2: تعداد کارمندان یک فروشگاه

```sql
CREATE FUNCTION GetEmployeeCount(@storeID INT)
RETURNS INT
AS
BEGIN
    DECLARE @count INT
    SELECT @count = COUNT(*) FROM Employee WHERE S_ID = @storeID
    RETURN @count
END
```

**استفاده از تابع:**

```sql
SELECT 
    Name, 
    dbo.GetEmployeeCount(ID) AS EmployeeCount
FROM Store
```

## 2. توابع جدولی (Table-Valued)

این توابع یک جدول برمی‌گردانند.

### مثال 3: لیست محصولات یک فروشگاه خاص

```sql
CREATE FUNCTION GetStoreProducts(@storeID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.Name AS ProductName, 
        p.Price, 
        sp.amount AS Inventory
    FROM StoreProduct sp
    JOIN Product p ON sp.p_ID = p.ID
    WHERE sp.S_ID = @storeID
)
```

**استفاده از تابع:**

```sql
SELECT * FROM dbo.GetStoreProducts(1) -- لیست محصولات فروشگاه با ID=1
```

### مثال 4: محصولات با موجودی کم (کمتر از مقدار مشخص)

```sql
CREATE FUNCTION GetLowStockProducts(@threshold INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.Name AS StoreName,
        p.Name AS ProductName,
        sp.amount AS CurrentStock
    FROM StoreProduct sp
    JOIN Store s ON sp.S_ID = s.ID
    JOIN Product p ON sp.p_ID = p.ID
    WHERE sp.amount < @threshold
)
```

**استفاده از تابع:**

```sql
SELECT * FROM dbo.GetLowStockProducts(10) -- محصولاتی که موجودی آنها کمتر از 10 است
```

## 3. توابع چندبیانی (Multi-Statement Table-Valued)

این توابع پیچیده‌تر هستند و می‌توانند چندین عبارت SQL داشته باشند.

### مثال 5: خلاصه اطلاعات فروشگاه

```sql
CREATE FUNCTION GetStoreSummary(@chainID INT)
RETURNS @result TABLE (
    StoreName NVARCHAR(100),
    City NVARCHAR(100),
    EmployeeCount INT,
    ProductCount INT,
    TotalInventoryValue DECIMAL(18,2)
)
AS
BEGIN
    INSERT INTO @result
    SELECT 
        s.Name AS StoreName,
        s.City,
        (SELECT COUNT(*) FROM Employee e WHERE e.S_ID = s.ID) AS EmployeeCount,
        (SELECT COUNT(*) FROM StoreProduct sp WHERE sp.S_ID = s.ID) AS ProductCount,
        (SELECT SUM(p.Price * sp.amount) 
         FROM StoreProduct sp 
         JOIN Product p ON sp.p_ID = p.ID 
         WHERE sp.S_ID = s.ID) AS TotalInventoryValue
    FROM Store s
    WHERE s.C_ID = @chainID
    
    RETURN
END
```

**استفاده از تابع:**

```sql
SELECT * FROM dbo.GetStoreSummary(1) -- خلاصه اطلاعات برای فروشگاه‌های زنجیره‌ای با ID=1
```

## 4. توابع سیستمی (System Functions)

SQL Server توابع سیستمی زیادی دارد که می‌توانید در کوئری‌های خود استفاده کنید:

```sql
-- محاسبه میانگین حقوق کارمندان یک فروشگاه خاص
SELECT AVG(Salary) AS AvgSalary FROM Employee WHERE S_ID = 1

-- تبدیل نام محصول به حروف بزرگ
SELECT UPPER(Name) FROM Product

-- محاسبه طول نام فروشگاه
SELECT Name, LEN(Name) AS NameLength FROM Store
```

## نکات مهم:

1. همیشه قبل از ایجاد تابع جدید، بررسی کنید که آیا از قبل وجود دارد یا نه:

```sql
IF OBJECT_ID('dbo.CalculateTax', 'FN') IS NOT NULL
    DROP FUNCTION dbo.CalculateTax
GO
```

2. از schema (معمولاً dbo) قبل از نام تابع استفاده کنید.

3. توابع می‌توانند در JOINها، WHERE clauses و تقریباً هر جای دیگر استفاده شوند.


# توضیح کامل Triggerهای ایجاد شده در SQL Server

## 1. تریگر سطح دیتابیس `[tr_blickcreate]`

```sql
CREATE TRIGGER [tr_blickcreate]
ON DATABASE
FOR CREATE_TABLE, DROP_TABLE, ALTER_TABLE
AS
RAISERROR('sorry', 16, 1)
ROLLBACK TRAN
GO

ENABLE TRIGGER [tr_blickcreate] ON DATABASE
GO
```

### توضیحات:
- این یک **DDL Trigger** است که در سطح دیتابیس عمل می‌کند (نه روی یک جدول خاص).
- برای رویدادهای `CREATE_TABLE`, `DROP_TABLE`, `ALTER_TABLE` فعال می‌شود.
- هنگام اجرای هر یک از این دستورات:
  - پیام خطای 'sorry' با سطح شدت 16 نمایش داده می‌شود.
  - تغییرات با `ROLLBACK TRAN` برگردانده می‌شود.
- `ENABLE TRIGGER` آن را فعال می‌کند.

### کاربرد:
- جلوگیری از تغییرات ساختاری در دیتابیس
- امنیت: ممانعت از ایجاد، حذف یا تغییر جداول

## 2. تریگر سطح جدول `[tr_notInsert]`

```sql
CREATE TRIGGER tr_notInsert
ON [dbo].[Product]
INSTEAD OF INSERT
AS
BEGIN
    PRINT 'test1'
END
```

### توضیحات:
- این یک **DML Trigger** از نوع `INSTEAD OF` است.
- روی جدول `Product` تعریف شده است.
- به جای عملیات INSERT اصلی اجرا می‌شود.
- هنگام تلاش برای درج رکورد جدید:
  - پیام 'test1' نمایش داده می‌شود.
  - عملیات INSERT واقعی انجام نمی‌شود.

### کاربرد:
- جلوگیری از درج داده‌های جدید به جدول
- می‌تواند برای بررسی شرایط خاص قبل از درج استفاده شود

## 3. غیرفعال و فعال کردن تریگر

```sql
ALTER TABLE [dbo].[Product] DISABLE TRIGGER [tr_notInsert]
ALTER TABLE [dbo].[Product] ENABLE TRIGGER [tr_notInsert]
```

### توضیحات:
- `DISABLE TRIGGER`: تریگر را موقتاً غیرفعال می‌کند.
- `ENABLE TRIGGER`: تریگر غیرفعال شده را دوباره فعال می‌کند.
- این دستورات برای مدیریت موقت تریگرها بدون حذف آنها مفیدند.

## 4. تست تریگر با دستور INSERT

```sql
INSERT INTO [dbo].[Product]
VALUES('test', 60000)
```

### رفتار مورد انتظار:
- اگر تریگر `tr_notInsert` فعال باشد:
  - هیچ داده‌ای درج نمی‌شود.
  - فقط پیام 'arrrr...' نمایش داده می‌شود.
- اگر تریگر غیرفعال باشد:
  - رکورد جدید با نام 'test' و قیمت 60000 درج می‌شود.

## نکات مهم:
1. **تفاوت DDL و DML Triggers**:
   - DDL برای عملیات ساختاری (CREATE, ALTER, DROP)
   - DML برای عملیات داده (INSERT, UPDATE, DELETE)

2. **INSTEAD OF vs AFTER**:
   - `INSTEAD OF`: جایگزین عملیات اصلی می‌شود
   - `AFTER`: بعد از عملیات اصلی اجرا می‌شود

3. **مدیریت تریگرها**:
   - همیشه قبل از ایجاد تریگر جدید بررسی کنید وجود ندارد
   - از اسکیمای مناسب (مثل dbo) استفاده کنید
   - تریگرهای غیرضروری را غیرفعال کنید تا عملکرد بهبود یابد

آیا می‌خواهید روی بخش خاصی از این توضیحات تمرکز بیشتری داشته باشید یا مثال‌های دیگری نیاز دارید؟
