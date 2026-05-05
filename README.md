# Production-ready English conversion for SQL-server-tutorial

## Executive Summary

This conversion rebuilds the tutorial into an English-first, production-oriented SQL Server learning repository while preserving the original teaching path: schema design, sample data, `SELECT`, `JOIN`, `VIEW`, stored procedures, functions, triggers, cursors, transactions, indexes, and metadata inspection. For repeatable scripts, I favored the more conservative `DROP ... IF EXISTS` plus `CREATE ...` pattern because Microsoft documents `IF EXISTS` support for `DROP VIEW`, `DROP PROCEDURE`, `DROP FUNCTION`, and `DROP TRIGGER` in SQL Server 2016+, while `CREATE OR ALTER` for views, procedures, functions, and triggers begins in SQL Server 2016 SP1+. citeturn7search0turn14view0turn7search2turn17view0turn6search0turn6search1turn8search1turn8search2

The revised material also corrects the structural and pedagogical issues in the source tutorial: the trailing comma in `StoreProduct`, the invalid chain-to-employee join, the non-runnable `CategoryID` procedure example, and the legacy `sys.syscomments` metadata example. It keeps `NVARCHAR` and `N'...'` literals so the tutorial remains Unicode-safe, because Microsoft specifically documents that Unicode string constants should be prefixed with `N` when used with `nchar`/`nvarchar`, and it replaces compatibility-view guidance with `sys.sql_modules`, `OBJECT_DEFINITION`, and `sp_helptext`, which are the documented modern ways to inspect module definitions. citeturn2search1turn2search13turn15search1turn4search1turn2search2turn2search10turn2search6

The technical guidance below is aligned primarily with official documentation from entity["company","Microsoft","software company"], and the repository structure is designed for clean navigation on entity["company","GitHub","developer platform"]. Assumption: the target platform is SQL Server 2016 SP1 or later unless otherwise noted. I did not execute these scripts against a live SQL Server instance in this environment, so the validation here is a static, syntax- and semantics-focused review against documented T-SQL behavior rather than a live engine test. citeturn11search0turn11search2turn6search4turn8search3

## Source Audit and Conversion Decisions

The source Persian tutorial is educationally strong but needed several corrections before it could serve as a reliable English README for beginners. The most important fixes were straightforward. The `StoreProduct` table definition had a trailing comma before the closing parenthesis, which would cause a syntax error. The three-table join and `vwEmployee` view joined `Chain_Store` directly to `Employee` on matching `ID` values, even though the schema clearly models the relationship as `Chain_Store -> Store -> Employee`. The original optional-parameter procedure targeted a `CategoryID` column that does not exist in the actual `Product` table. In the English conversion, that concept is preserved, but the example is rewritten around an existing relationship so it is runnable.

The naming strategy stays intentionally close to the original schema so the repository remains easy to compare across languages. That means objects like `Chain_Store` and `StoreProduct` are preserved instead of being renamed to more idiomatic alternatives such as `RetailChain` or `InventoryItem`. This choice reduces migration friction between the Persian and English versions, which is usually more important in a bilingual tutorial repository than aggressive refactoring.

The mapping below preserves the original learning structure while making the English repository easier to maintain as the primary root README, with Persian kept as the translated companion. GitHub’s documentation recommends relative links for repository files, which supports a simple language switcher at the top of both READMEs. citeturn11search0turn11search2

| Original Persian file or section | New English file or section |
|---|---|
| `README.fa.md` | `README.fa.md` |
| `README.md` Persian tutorial content | `README.md` English primary tutorial |
| `بخش 1: ایجاد جداول` | `Creating Tables` |
| `بخش 2: درج داده‌ها` | `Inserting Sample Data` |
| `بخش 3: کوئری‌های پایه` | `Basic Queries` |
| `بخش 4: کوئری‌های پیچیده` | `JOINs and Analysis` |
| `بخش 5: ویوها` | `Views` |
| `بخش 6: رویه‌های ذخیره شده` | `Stored Procedures` |
| `آموزش Functions` | `Functions` |
| `توضیح Triggerها` | `Triggers` |
| `توضیح Cursor` | `Cursor and Set-Based Alternative` |

## Recommended Repository Layout

A production-friendly tutorial repository should separate schema creation, seeding, read-only examples, metadata exploration, and demo-only behaviors. That separation matters in SQL Server because `CREATE VIEW`, `CREATE PROCEDURE`, and `CREATE TRIGGER` must begin their own batches, and `GO` is a batch separator used by tools like SSMS and sqlcmd rather than a T-SQL statement itself. GitHub also recommends relative links between repository files, so the layout below works well both in the web UI and in local clones. citeturn9search0turn9search1turn9search2turn9search3turn9search9turn11search0turn11search2

| Suggested file | Purpose | Safe to run normally |
|---|---|---|
| `README.md` | English primary tutorial | Yes |
| `README.fa.md` | Persian companion tutorial | Yes |
| `scripts/00-create-database.sql` | Creates the demo database if missing | Yes |
| `scripts/01-create-tables.sql` | Creates tables and constraints | Yes |
| `scripts/02-seed-data.sql` | Loads English sample data | Yes |
| `scripts/03-basic-selects.sql` | Read-only `SELECT`, `WHERE`, `GROUP BY`, `HAVING` examples | Yes |
| `scripts/04-joins.sql` | Read-only join examples | Yes |
| `scripts/05-views.sql` | View creation and usage | Yes, with caution on `WITH ENCRYPTION` |
| `scripts/06-stored-procedures.sql` | Procedure examples | Yes |
| `scripts/07-functions.sql` | UDF examples | Yes |
| `scripts/08-metadata.sql` | Catalog and definition inspection | Yes |
| `scripts/09-triggers-demo.sql` | DML and DDL trigger demos | Demo only |
| `scripts/10-cursors-demo.sql` | Cursor demo and set-based comparison | Yes |
| `scripts/11-transactions-demo.sql` | Transaction and error-handling demo | Yes, preview-safe because it rolls back |
| `scripts/12-indexes.sql` | Recommended nonclustered indexes | Yes |

## Ready-to-use README.md

The README below keeps the original educational scope, but rewrites the language for English-speaking readers, replaces the invalid examples with runnable ones, uses Unicode-safe literals, and clearly labels demo-only features such as blocking DDL triggers and `WITH ENCRYPTION`. Those choices reflect documented SQL Server behavior for Unicode literals, compatibility views, DDL triggers, and encrypted view definitions. citeturn2search1turn2search13turn15search1turn10search0turn4search3

````md
# SQL Server Tutorial

<p align="right">
  <a href="./README.md">English</a> |
  <a href="./README.fa.md">فارسی</a>
</p>

> **Primary README note**  
> This English file should be the primary maintained README for this repository.  
> The Persian file should be kept as a translated companion.

A practical SQL Server tutorial built around a small retail-chain database.

This repository starts with core SQL Server concepts such as `CREATE TABLE`, `INSERT`, and `SELECT`, then moves into more advanced topics including `JOIN`, `VIEW`, stored procedures, functions, triggers, cursors, transactions, indexes, and metadata inspection.

## Executive Summary

This tutorial uses a small but realistic retail-chain schema to teach SQL Server step by step.

You will learn how to:

- create related tables with primary and foreign keys
- insert clean sample data
- write basic and intermediate queries
- join multiple tables correctly
- build views, stored procedures, and functions
- understand trigger behavior and its risks
- compare cursor-based logic to set-based SQL
- use transactions and error handling
- create indexes for faster queries
- inspect database objects using system catalog views

The English version also corrects several problems from the original notes so the examples are runnable on modern SQL Server.

## Table of Contents

- [Version and Safety Notes](#version-and-safety-notes)
- [Recommended Repository Layout](#recommended-repository-layout)
- [Scenario and Data Model](#scenario-and-data-model)
- [Creating the Database and Tables](#creating-the-database-and-tables)
- [Inserting Sample Data](#inserting-sample-data)
- [Basic Queries](#basic-queries)
- [JOINs and Analysis](#joins-and-analysis)
- [Views](#views)
- [Stored Procedures](#stored-procedures)
- [Functions](#functions)
- [Triggers](#triggers)
- [Cursor](#cursor)
- [Transactions and Error Handling](#transactions-and-error-handling)
- [Indexes](#indexes)
- [Metadata and Object Inspection](#metadata-and-object-inspection)
- [Testing Checklist](#testing-checklist)
- [Best Practices](#best-practices)

## Version and Safety Notes

### Target version

This tutorial assumes **SQL Server 2016 SP1 or later** for the documentation as a whole.

The standalone scripts in the `scripts/` folder are intentionally written with a conservative `DROP ... IF EXISTS` plus `CREATE ...` style so they remain broadly compatible with **SQL Server 2016 and later**.

### Important warnings

- The **DDL trigger** example is **demo-only** and can block schema changes such as `CREATE TABLE`, `ALTER TABLE`, and `DROP TABLE`.
- The **INSTEAD OF INSERT** trigger example is **demo-only** and intentionally changes normal insert behavior.
- The view example that uses `WITH ENCRYPTION` is included for education, but it should not be treated as a real security boundary or as a substitute for access control or data encryption.
- Even though the sample strings below are English, the examples still use `N'...'` because the schema uses `NVARCHAR`, and this keeps the tutorial Unicode-safe.

## Recommended Repository Layout

```text
SQL-server-tutorial/
│
├── README.md
├── README.fa.md
└── scripts/
    ├── 00-create-database.sql
    ├── 01-create-tables.sql
    ├── 02-seed-data.sql
    ├── 03-basic-selects.sql
    ├── 04-joins.sql
    ├── 05-views.sql
    ├── 06-stored-procedures.sql
    ├── 07-functions.sql
    ├── 08-metadata.sql
    ├── 09-triggers-demo.sql
    ├── 10-cursors-demo.sql
    ├── 11-transactions-demo.sql
    └── 12-indexes.sql
```

## Scenario and Data Model

The tutorial models a small retail-chain system.

### Tables

- `Chain_Store` stores chain or brand names
- `Store` stores physical branches
- `Employee` stores store employees
- `Product` stores products and prices
- `StoreProduct` is a bridge table that stores inventory by store and product

### Relationships

- one `Chain_Store` can have many `Store` rows
- one `Store` can have many `Employee` rows
- `Store` and `Product` have a many-to-many relationship through `StoreProduct`

### Why this schema is useful for learning

This design teaches several important database concepts at the same time:

- primary keys
- foreign keys
- one-to-many relationships
- many-to-many relationships
- bridge tables
- grouped reporting
- multi-table joins

## Creating the Database and Tables

```sql
USE master;
GO

IF DB_ID(N'SQLServerTutorialDB') IS NULL
BEGIN
    CREATE DATABASE SQLServerTutorialDB;
END;
GO

USE SQLServerTutorialDB;
GO

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

### Table notes

#### `dbo.Product`

- `ID` is an identity primary key
- `Name` is `NVARCHAR(100)` so the table remains friendly to multilingual content
- `Price` uses `DECIMAL(10,2)` because monetary values should not use floating-point types
- `CHECK (Price > 0)` prevents invalid prices

#### `dbo.Chain_Store`

- Stores the retail chain or parent brand
- `Name` is unique so duplicate chain names are not allowed

#### `dbo.Store`

- Stores branch data
- `C_ID` is a foreign key to `Chain_Store`
- `Zone` has a range constraint to prevent obviously invalid values

#### `dbo.Employee`

- Each employee belongs to exactly one store through `S_ID`
- `Salary` must be greater than zero

#### `dbo.StoreProduct`

- This is the bridge table between stores and products
- `Amount` stores inventory quantity
- `UNIQUE (S_ID, P_ID)` prevents the same product from being inserted twice for the same store

## Inserting Sample Data

### Seed chain stores

```sql
INSERT INTO dbo.Chain_Store (Name)
VALUES
    (N'NorthMart'),
    (N'HyperStar'),
    (N'FreshChoice'),
    (N'JumboMart');
GO
```

### Seed products

```sql
INSERT INTO dbo.Product (Name, Price)
VALUES
    (N'Whole Milk', 4.50),
    (N'Family Soda', 1.75),
    (N'Vegetable Oil', 8.90),
    (N'Basmati Rice', 18.50),
    (N'Pasta', 2.40),
    (N'Low-Fat Milk', 4.20),
    (N'Eggs', 5.10),
    (N'Packaged Chicken', 12.75);
GO
```

### Seed store branches

```sql
INSERT INTO dbo.Store (Name, Zone, City, Address, C_ID)
VALUES
    (N'NorthMart Downtown', 1, N'Toronto', N'100 King St W', 1),
    (N'NorthMart North York', 2, N'Toronto', N'5000 Yonge St', 1),
    (N'HyperStar Ottawa East', 3, N'Ottawa', N'200 Rideau St', 2),
    (N'FreshChoice Vancouver Central', 4, N'Vancouver', N'880 Granville St', 3),
    (N'JumboMart Calgary West', 5, N'Calgary', N'350 8 Ave SW', 4),
    (N'HyperStar Montreal Laval', 1, N'Montreal', N'1200 Saint-Martin Blvd W', 2);
GO
```

### Seed employees

```sql
INSERT INTO dbo.Employee (Name, Salary, S_ID)
VALUES
    (N'Olivia Carter', 52000.00, 1),
    (N'Ethan Brooks', 48000.00, 1),
    (N'Liam Turner', 56000.00, 2),
    (N'Emma Collins', 49500.00, 3),
    (N'Noah Bennett', 61000.00, 4),
    (N'Ava Mitchell', 53000.00, 5),
    (N'Mason Reed', 57500.00, 6),
    (N'Sophia Parker', 50500.00, 2);
GO
```

### Seed inventory

```sql
INSERT INTO dbo.StoreProduct (S_ID, P_ID, Amount)
VALUES
    -- NorthMart Downtown
    (1, 1, 150), (1, 2, 200), (1, 3, 100), (1, 4, 80),

    -- NorthMart North York
    (2, 1, 120), (2, 5, 180), (2, 6, 90), (2, 7, 110),

    -- HyperStar Ottawa East
    (3, 2, 160), (3, 3, 70), (3, 4, 60), (3, 8, 50),

    -- FreshChoice Vancouver Central
    (4, 1, 90), (4, 6, 120), (4, 7, 80), (4, 5, 150),

    -- JumboMart Calgary West
    (5, 3, 110), (5, 4, 70), (5, 8, 60), (5, 2, 180),

    -- HyperStar Montreal Laval
    (6, 1, 130), (6, 2, 170), (6, 5, 140), (6, 7, 100);
GO
```

## Basic Queries

### Show all rows

```sql
SELECT * FROM dbo.Chain_Store;
SELECT * FROM dbo.Store;
SELECT * FROM dbo.Employee;
SELECT * FROM dbo.Product;
SELECT * FROM dbo.StoreProduct;
```

### Select specific columns

```sql
SELECT Name, Price
FROM dbo.Product;
```

### Filter with `WHERE`

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary > 50000;
```

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary BETWEEN 50000 AND 55000;
```

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Name LIKE N'%a%';
```

### `DISTINCT`

```sql
SELECT DISTINCT City
FROM dbo.Store;
```

### `ORDER BY`

```sql
SELECT Name, Price
FROM dbo.Product
ORDER BY Price DESC;
```

### Aggregate functions

```sql
SELECT
    COUNT(*) AS TotalProducts,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice,
    AVG(Price) AS AvgPrice,
    SUM(Price) AS SumPrice
FROM dbo.Product;
```

### `GROUP BY`

```sql
SELECT
    S_ID,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AvgSalary,
    SUM(Salary) AS TotalSalary
FROM dbo.Employee
GROUP BY S_ID;
```

### `HAVING`

```sql
SELECT
    S_ID,
    COUNT(*) AS EmployeeCount
FROM dbo.Employee
GROUP BY S_ID
HAVING COUNT(*) > 1;
```

### Subquery example

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary > (
    SELECT AVG(Salary)
    FROM dbo.Employee
);
```

### Window function example

```sql
SELECT
    Name,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM dbo.Employee;
```

## JOINs and Analysis

### Simple inner join

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

### Join with filtering and `HAVING`

```sql
SELECT
    s.Name AS StoreName,
    COUNT(*) AS EmployeeCount,
    SUM(e.Salary) AS TotalPayroll
FROM dbo.Employee AS e
INNER JOIN dbo.Store AS s
    ON e.S_ID = s.ID
WHERE e.Salary > 50000
GROUP BY s.Name
HAVING SUM(e.Salary) > 100000
ORDER BY TotalPayroll DESC;
```

### Correct three-table join

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

### Inventory report by store

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

### Inventory value by store

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

## Views

Views help simplify repeated queries and present result sets like virtual tables.

### Employee reporting view

```sql
DROP VIEW IF EXISTS dbo.vwEmployee;
GO

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

### Use the view

```sql
SELECT * FROM dbo.vwEmployee;
SELECT DISTINCT EmployeeName FROM dbo.vwEmployee;
```

### Aggregate view

```sql
DROP VIEW IF EXISTS dbo.vwStoreEmployeeCount;
GO

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

### Altered view with `HAVING`

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

### View with `WITH ENCRYPTION`

```sql
DROP VIEW IF EXISTS dbo.vwStoreName;
GO

CREATE VIEW dbo.vwStoreName
WITH ENCRYPTION
AS
SELECT DISTINCT Name
FROM dbo.Store;
GO
```

## Stored Procedures

Stored procedures package reusable logic and can accept input parameters, output parameters, and error-handling logic.

### Simple procedure

```sql
DROP PROCEDURE IF EXISTS dbo.GetAllProducts;
GO

CREATE PROCEDURE dbo.GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ID, Name, Price
    FROM dbo.Product
    ORDER BY Name;
END;
GO
```

### Procedure with input parameters

```sql
DROP PROCEDURE IF EXISTS dbo.GetProductsByPriceRange;
GO

CREATE PROCEDURE dbo.GetProductsByPriceRange
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

### Procedure with output parameter

```sql
DROP PROCEDURE IF EXISTS dbo.GetProductCount;
GO

CREATE PROCEDURE dbo.GetProductCount
    @Count INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @Count = COUNT(*)
    FROM dbo.Product;
END;
GO
```

Usage:

```sql
DECLARE @ProductCount INT;

EXEC dbo.GetProductCount @Count = @ProductCount OUTPUT;

SELECT @ProductCount AS ProductCount;
```

### Optional-parameter procedure

The original Persian tutorial used `CategoryID`, but the current schema does not define that column.  
This runnable version preserves the optional-parameter idea while matching the actual schema.

```sql
DROP PROCEDURE IF EXISTS dbo.GetProductsByStoreOptional;
GO

CREATE PROCEDURE dbo.GetProductsByStoreOptional
    @StoreID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StoreID IS NULL
    BEGIN
        SELECT
            s.Name AS StoreName,
            p.Name AS ProductName,
            p.Price,
            sp.Amount
        FROM dbo.StoreProduct AS sp
        INNER JOIN dbo.Store AS s
            ON sp.S_ID = s.ID
        INNER JOIN dbo.Product AS p
            ON sp.P_ID = p.ID
        ORDER BY s.Name, p.Name;
    END
    ELSE
    BEGIN
        SELECT
            s.Name AS StoreName,
            p.Name AS ProductName,
            p.Price,
            sp.Amount
        FROM dbo.StoreProduct AS sp
        INNER JOIN dbo.Store AS s
            ON sp.S_ID = s.ID
        INNER JOIN dbo.Product AS p
            ON sp.P_ID = p.ID
        WHERE sp.S_ID = @StoreID
        ORDER BY p.Name;
    END
END;
GO
```

### Procedure with guarded error handling

```sql
DROP PROCEDURE IF EXISTS dbo.UpdateProductPrice;
GO

CREATE PROCEDURE dbo.UpdateProductPrice
    @ProductID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @NewPrice <= 0
        BEGIN
            THROW 50001, N'Price must be greater than 0.', 1;
        END;

        UPDATE dbo.Product
        SET Price = @NewPrice
        WHERE ID = @ProductID;

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50002, N'No product was updated. Check ProductID.', 1;
        END;

        SELECT N'Price updated successfully.' AS Result;
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH
END;
GO
```

## Functions

Functions let you encapsulate reusable logic that returns either a scalar value or a rowset.

### Scalar function: calculate tax

```sql
DROP FUNCTION IF EXISTS dbo.CalculateTax;
GO

CREATE FUNCTION dbo.CalculateTax(@Price DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Tax DECIMAL(10,2);

    SET @Tax = @Price * 0.09;

    RETURN @Tax;
END;
GO
```

Usage:

```sql
SELECT
    Name,
    Price,
    dbo.CalculateTax(Price) AS Tax,
    Price + dbo.CalculateTax(Price) AS TotalPrice
FROM dbo.Product;
```

### Scalar function: employee count by store

```sql
DROP FUNCTION IF EXISTS dbo.GetEmployeeCount;
GO

CREATE FUNCTION dbo.GetEmployeeCount(@StoreID INT)
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

Usage:

```sql
SELECT
    Name,
    dbo.GetEmployeeCount(ID) AS EmployeeCount
FROM dbo.Store;
```

### Inline table-valued function: store products

```sql
DROP FUNCTION IF EXISTS dbo.GetStoreProducts;
GO

CREATE FUNCTION dbo.GetStoreProducts(@StoreID INT)
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

Usage:

```sql
SELECT *
FROM dbo.GetStoreProducts(1);
```

### Inline table-valued function: low stock products

```sql
DROP FUNCTION IF EXISTS dbo.GetLowStockProducts;
GO

CREATE FUNCTION dbo.GetLowStockProducts(@Threshold INT)
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

Usage:

```sql
SELECT *
FROM dbo.GetLowStockProducts(100);
```

### Multi-statement table-valued function: store summary by chain

```sql
DROP FUNCTION IF EXISTS dbo.GetStoreSummary;
GO

CREATE FUNCTION dbo.GetStoreSummary(@ChainID INT)
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

Usage:

```sql
SELECT *
FROM dbo.GetStoreSummary(1);
```

## Triggers

Triggers are special stored procedures that run automatically in response to events.

### Warning

The trigger examples below are included for education, not as general recommendations.

### DDL trigger at database scope

```sql
DROP TRIGGER IF EXISTS trg_BlockTableChanges ON DATABASE;
GO

CREATE TRIGGER trg_BlockTableChanges
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    SET NOCOUNT ON;

    PRINT N'Schema changes are blocked by trg_BlockTableChanges.';
    ROLLBACK TRANSACTION;
END;
GO
```

### DML trigger: block direct inserts into `Product`

```sql
DROP TRIGGER IF EXISTS dbo.trg_Product_NoDirectInsert;
GO

CREATE TRIGGER dbo.trg_Product_NoDirectInsert
ON dbo.Product
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    THROW 50020, N'Direct inserts into dbo.Product are blocked by the demo trigger.', 1;
END;
GO
```

### Disable and enable triggers

```sql
DISABLE TRIGGER dbo.trg_Product_NoDirectInsert ON dbo.Product;
ENABLE TRIGGER dbo.trg_Product_NoDirectInsert ON dbo.Product;

DISABLE TRIGGER trg_BlockTableChanges ON DATABASE;
ENABLE TRIGGER trg_BlockTableChanges ON DATABASE;
```

### Trigger test

```sql
INSERT INTO dbo.Product (Name, Price)
VALUES (N'Test Product', 9.99);
```

If the demo insert trigger is enabled, this insert will fail intentionally.

## Cursor

A cursor processes rows one at a time.  
That can be useful for some procedural tasks, but in most reporting and data-processing scenarios, a set-based query is simpler and faster.

### Cursor example

```sql
DECLARE @ID INT;
DECLARE @Salary DECIMAL(10,2);
DECLARE @TotalSalary DECIMAL(18,2);

SET @TotalSalary = 0;

DECLARE emp_cur CURSOR FAST_FORWARD
FOR
SELECT ID, Salary
FROM dbo.Employee
ORDER BY ID;

OPEN emp_cur;

FETCH NEXT FROM emp_cur
INTO @ID, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TotalSalary = @TotalSalary + @Salary;

    FETCH NEXT FROM emp_cur
    INTO @ID, @Salary;
END;

CLOSE emp_cur;
DEALLOCATE emp_cur;

SELECT @TotalSalary AS CursorTotalSalary;
```

### Set-based alternative

```sql
SELECT SUM(Salary) AS SetBasedTotalSalary
FROM dbo.Employee;
```

## Transactions and Error Handling

Transactions group multiple changes into one logical unit.

If every statement succeeds, you can commit the transaction.  
If something fails, you can roll it back.

### Preview-safe transaction example

This version rolls back intentionally, so it is safe to run as a demo.

```sql
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Product
    SET Price = Price + 0.25
    WHERE ID = 1;

    UPDATE dbo.StoreProduct
    SET Amount = Amount - 5
    WHERE S_ID = 1
      AND P_ID = 1
      AND Amount >= 5;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50030, N'Inventory row was not updated. Check stock or keys.', 1;
    END;

    SELECT
        p.Name,
        p.Price,
        sp.Amount
    FROM dbo.Product AS p
    INNER JOIN dbo.StoreProduct AS sp
        ON p.ID = sp.P_ID
    WHERE p.ID = 1
      AND sp.S_ID = 1;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH;
```

## Indexes

Indexes can speed up joins, filters, and sorts.

### Recommended nonclustered indexes

```sql
CREATE NONCLUSTERED INDEX IX_Employee_S_ID
ON dbo.Employee (S_ID)
INCLUDE (Salary, Name);
GO

CREATE NONCLUSTERED INDEX IX_Store_C_ID
ON dbo.Store (C_ID)
INCLUDE (Name, City);
GO

CREATE NONCLUSTERED INDEX IX_StoreProduct_SID_PID
ON dbo.StoreProduct (S_ID, P_ID)
INCLUDE (Amount);
GO

CREATE NONCLUSTERED INDEX IX_Product_Name
ON dbo.Product (Name);
GO
```

## Metadata and Object Inspection

System catalog views help you understand what exists in the database and how objects were defined.

### List objects

```sql
SELECT name, type, type_desc
FROM sys.objects
ORDER BY type, name;
```

### Filter tables and views

```sql
SELECT name, type_desc
FROM sys.objects
WHERE type = 'U';

SELECT name, type_desc
FROM sys.objects
WHERE type = 'V';
```

### Triggers

```sql
SELECT name, parent_class_desc, is_disabled
FROM sys.triggers;
```

### Module definitions

```sql
SELECT sm.definition
FROM sys.sql_modules AS sm
WHERE sm.object_id = OBJECT_ID(N'dbo.vwEmployee');

SELECT OBJECT_DEFINITION(OBJECT_ID(N'dbo.vwEmployee')) AS ObjectDefinition;

EXEC sp_helptext N'dbo.vwEmployee';
```

### `@@ROWCOUNT`

`@@ROWCOUNT` changes as subsequent statements run, so capture it immediately after the statement you care about.

```sql
UPDATE dbo.Product
SET Price = Price + 1
WHERE ID = 1;

SELECT @@ROWCOUNT AS AffectedRows;
```

## Testing Checklist

| Step | Script | Safe by default | Notes |
|---|---|---:|---|
| 1 | `scripts/00-create-database.sql` | Yes | Creates database if missing |
| 2 | `scripts/01-create-tables.sql` | Yes | Rebuilds schema cleanly |
| 3 | `scripts/02-seed-data.sql` | Yes | Loads sample data |
| 4 | `scripts/03-basic-selects.sql` | Yes | Read-only |
| 5 | `scripts/04-joins.sql` | Yes | Read-only |
| 6 | `scripts/05-views.sql` | Yes | `WITH ENCRYPTION` is optional |
| 7 | `scripts/06-stored-procedures.sql` | Yes | Runnable examples |
| 8 | `scripts/07-functions.sql` | Yes | Runnable examples |
| 9 | `scripts/08-metadata.sql` | Yes | Read-only inspection |
| 10 | `scripts/09-triggers-demo.sql` | No | Demo only; leaves triggers disabled by default |
| 11 | `scripts/10-cursors-demo.sql` | Yes | Educational only |
| 12 | `scripts/11-transactions-demo.sql` | Yes | Rolls back intentionally |
| 13 | `scripts/12-indexes.sql` | Yes | Adds supporting indexes |

## Best Practices

- Use schema-qualified names such as `dbo.Product`
- Prefer `DECIMAL` for financial values
- Use `NVARCHAR` for text when multilingual support matters
- Prefix Unicode string literals with `N`
- Name your constraints explicitly
- Add `CHECK` constraints for obvious business rules
- Use `UNIQUE` constraints where duplicate values are invalid
- Prefer set-based SQL over cursors when possible
- Keep dangerous trigger examples clearly isolated from safe scripts
- Use `sys.sql_modules` and `OBJECT_DEFINITION` instead of legacy compatibility views for new development
````

## Execution-ready SQL Scripts

The standalone scripts below are designed to be executed in order. They use documented SQL Server 2016+ `DROP ... IF EXISTS` patterns where available, and they are split into separate batches so that module-creation statements satisfy SQL Server’s batch rules. Microsoft’s documentation also confirms that `WITH ENCRYPTION` on views only obscures the stored definition metadata, that DDL triggers can roll back DDL operations, and that trigger logic should be written with rowset-based thinking rather than cursor assumptions. citeturn14view0turn7search0turn7search2turn17view0turn9search1turn9search2turn9search3turn9search9turn4search3turn10search0turn16search2

### `scripts/00-create-database.sql`

```sql
USE master;
GO

IF DB_ID(N'SQLServerTutorialDB') IS NULL
BEGIN
    CREATE DATABASE SQLServerTutorialDB;
END;
GO
```

### `scripts/01-create-tables.sql`

```sql
USE SQLServerTutorialDB;
GO

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

### `scripts/02-seed-data.sql`

```sql
USE SQLServerTutorialDB;
GO

DELETE FROM dbo.StoreProduct;
DELETE FROM dbo.Employee;
DELETE FROM dbo.Store;
DELETE FROM dbo.Product;
DELETE FROM dbo.Chain_Store;
GO

DBCC CHECKIDENT ('dbo.StoreProduct', RESEED, 0);
DBCC CHECKIDENT ('dbo.Employee', RESEED, 0);
DBCC CHECKIDENT ('dbo.Store', RESEED, 0);
DBCC CHECKIDENT ('dbo.Product', RESEED, 0);
DBCC CHECKIDENT ('dbo.Chain_Store', RESEED, 0);
GO

INSERT INTO dbo.Chain_Store (Name)
VALUES
    (N'NorthMart'),
    (N'HyperStar'),
    (N'FreshChoice'),
    (N'JumboMart');
GO

INSERT INTO dbo.Product (Name, Price)
VALUES
    (N'Whole Milk', 4.50),
    (N'Family Soda', 1.75),
    (N'Vegetable Oil', 8.90),
    (N'Basmati Rice', 18.50),
    (N'Pasta', 2.40),
    (N'Low-Fat Milk', 4.20),
    (N'Eggs', 5.10),
    (N'Packaged Chicken', 12.75);
GO

INSERT INTO dbo.Store (Name, Zone, City, Address, C_ID)
VALUES
    (N'NorthMart Downtown', 1, N'Toronto', N'100 King St W', 1),
    (N'NorthMart North York', 2, N'Toronto', N'5000 Yonge St', 1),
    (N'HyperStar Ottawa East', 3, N'Ottawa', N'200 Rideau St', 2),
    (N'FreshChoice Vancouver Central', 4, N'Vancouver', N'880 Granville St', 3),
    (N'JumboMart Calgary West', 5, N'Calgary', N'350 8 Ave SW', 4),
    (N'HyperStar Montreal Laval', 1, N'Montreal', N'1200 Saint-Martin Blvd W', 2);
GO

INSERT INTO dbo.Employee (Name, Salary, S_ID)
VALUES
    (N'Olivia Carter', 52000.00, 1),
    (N'Ethan Brooks', 48000.00, 1),
    (N'Liam Turner', 56000.00, 2),
    (N'Emma Collins', 49500.00, 3),
    (N'Noah Bennett', 61000.00, 4),
    (N'Ava Mitchell', 53000.00, 5),
    (N'Mason Reed', 57500.00, 6),
    (N'Sophia Parker', 50500.00, 2);
GO

INSERT INTO dbo.StoreProduct (S_ID, P_ID, Amount)
VALUES
    (1, 1, 150), (1, 2, 200), (1, 3, 100), (1, 4, 80),
    (2, 1, 120), (2, 5, 180), (2, 6, 90), (2, 7, 110),
    (3, 2, 160), (3, 3, 70), (3, 4, 60), (3, 8, 50),
    (4, 1, 90),  (4, 6, 120), (4, 7, 80),  (4, 5, 150),
    (5, 3, 110), (5, 4, 70),  (5, 8, 60),  (5, 2, 180),
    (6, 1, 130), (6, 2, 170), (6, 5, 140), (6, 7, 100);
GO
```

### `scripts/03-basic-selects.sql`

```sql
USE SQLServerTutorialDB;
GO

SELECT * FROM dbo.Chain_Store;
SELECT * FROM dbo.Store;
SELECT * FROM dbo.Employee;
SELECT * FROM dbo.Product;
SELECT * FROM dbo.StoreProduct;
GO

SELECT Name, Price
FROM dbo.Product;
GO

SELECT Name, Salary
FROM dbo.Employee
WHERE Salary > 50000;
GO

SELECT Name, Salary
FROM dbo.Employee
WHERE Salary BETWEEN 50000 AND 55000;
GO

SELECT Name, Salary
FROM dbo.Employee
WHERE Name LIKE N'%a%';
GO

SELECT DISTINCT City
FROM dbo.Store;
GO

SELECT Name, Price
FROM dbo.Product
ORDER BY Price DESC;
GO

SELECT
    COUNT(*) AS TotalProducts,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice,
    AVG(Price) AS AvgPrice,
    SUM(Price) AS SumPrice
FROM dbo.Product;
GO

SELECT
    S_ID,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AvgSalary,
    SUM(Salary) AS TotalSalary
FROM dbo.Employee
GROUP BY S_ID;
GO

SELECT
    S_ID,
    COUNT(*) AS EmployeeCount
FROM dbo.Employee
GROUP BY S_ID
HAVING COUNT(*) > 1;
GO

SELECT Name, Salary
FROM dbo.Employee
WHERE Salary > (
    SELECT AVG(Salary)
    FROM dbo.Employee
);
GO

SELECT
    Name,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM dbo.Employee;
GO
```

### `scripts/04-joins.sql`

```sql
USE SQLServerTutorialDB;
GO

SELECT
    s.Name AS StoreName,
    COUNT(e.ID) AS EmployeeCount
FROM dbo.Store AS s
INNER JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
GROUP BY s.Name
ORDER BY s.Name;
GO

SELECT
    s.Name AS StoreName,
    COUNT(*) AS EmployeeCount,
    SUM(e.Salary) AS TotalPayroll
FROM dbo.Employee AS e
INNER JOIN dbo.Store AS s
    ON e.S_ID = s.ID
WHERE e.Salary > 50000
GROUP BY s.Name
HAVING SUM(e.Salary) > 100000
ORDER BY TotalPayroll DESC;
GO

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
GO

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
GO

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
GO
```

### `scripts/05-views.sql`

```sql
USE SQLServerTutorialDB;
GO

DROP VIEW IF EXISTS dbo.vwEmployee;
GO

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

DROP VIEW IF EXISTS dbo.vwStoreEmployeeCount;
GO

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

DROP VIEW IF EXISTS dbo.vwStoreName;
GO

CREATE VIEW dbo.vwStoreName
WITH ENCRYPTION
AS
SELECT DISTINCT Name
FROM dbo.Store;
GO

SELECT * FROM dbo.vwEmployee;
SELECT DISTINCT EmployeeName FROM dbo.vwEmployee;
SELECT * FROM dbo.vwStoreEmployeeCount;
GO
```

### `scripts/06-stored-procedures.sql`

```sql
USE SQLServerTutorialDB;
GO

DROP PROCEDURE IF EXISTS dbo.GetAllProducts;
GO

CREATE PROCEDURE dbo.GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ID, Name, Price
    FROM dbo.Product
    ORDER BY Name;
END;
GO

DROP PROCEDURE IF EXISTS dbo.GetProductsByPriceRange;
GO

CREATE PROCEDURE dbo.GetProductsByPriceRange
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

DROP PROCEDURE IF EXISTS dbo.GetProductCount;
GO

CREATE PROCEDURE dbo.GetProductCount
    @Count INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @Count = COUNT(*)
    FROM dbo.Product;
END;
GO

DROP PROCEDURE IF EXISTS dbo.GetProductsByStoreOptional;
GO

CREATE PROCEDURE dbo.GetProductsByStoreOptional
    @StoreID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StoreID IS NULL
    BEGIN
        SELECT
            s.Name AS StoreName,
            p.Name AS ProductName,
            p.Price,
            sp.Amount
        FROM dbo.StoreProduct AS sp
        INNER JOIN dbo.Store AS s
            ON sp.S_ID = s.ID
        INNER JOIN dbo.Product AS p
            ON sp.P_ID = p.ID
        ORDER BY s.Name, p.Name;
    END
    ELSE
    BEGIN
        SELECT
            s.Name AS StoreName,
            p.Name AS ProductName,
            p.Price,
            sp.Amount
        FROM dbo.StoreProduct AS sp
        INNER JOIN dbo.Store AS s
            ON sp.S_ID = s.ID
        INNER JOIN dbo.Product AS p
            ON sp.P_ID = p.ID
        WHERE sp.S_ID = @StoreID
        ORDER BY p.Name;
    END
END;
GO

DROP PROCEDURE IF EXISTS dbo.UpdateProductPrice;
GO

CREATE PROCEDURE dbo.UpdateProductPrice
    @ProductID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @NewPrice <= 0
        BEGIN
            THROW 50001, N'Price must be greater than 0.', 1;
        END;

        UPDATE dbo.Product
        SET Price = @NewPrice
        WHERE ID = @ProductID;

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50002, N'No product was updated. Check ProductID.', 1;
        END;

        SELECT N'Price updated successfully.' AS Result;
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH
END;
GO
```

### `scripts/07-functions.sql`

```sql
USE SQLServerTutorialDB;
GO

DROP FUNCTION IF EXISTS dbo.CalculateTax;
GO

CREATE FUNCTION dbo.CalculateTax(@Price DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Tax DECIMAL(10,2);

    SET @Tax = @Price * 0.09;

    RETURN @Tax;
END;
GO

DROP FUNCTION IF EXISTS dbo.GetEmployeeCount;
GO

CREATE FUNCTION dbo.GetEmployeeCount(@StoreID INT)
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

DROP FUNCTION IF EXISTS dbo.GetStoreProducts;
GO

CREATE FUNCTION dbo.GetStoreProducts(@StoreID INT)
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

DROP FUNCTION IF EXISTS dbo.GetLowStockProducts;
GO

CREATE FUNCTION dbo.GetLowStockProducts(@Threshold INT)
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

DROP FUNCTION IF EXISTS dbo.GetStoreSummary;
GO

CREATE FUNCTION dbo.GetStoreSummary(@ChainID INT)
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

### `scripts/08-metadata.sql`

```sql
USE SQLServerTutorialDB;
GO

SELECT name, type, type_desc
FROM sys.objects
ORDER BY type, name;
GO

SELECT name, type_desc
FROM sys.objects
WHERE type = 'U';
GO

SELECT name, type_desc
FROM sys.objects
WHERE type = 'V';
GO

SELECT name, parent_class_desc, is_disabled
FROM sys.triggers;
GO

SELECT sm.definition
FROM sys.sql_modules AS sm
WHERE sm.object_id = OBJECT_ID(N'dbo.vwEmployee');
GO

SELECT OBJECT_DEFINITION(OBJECT_ID(N'dbo.vwEmployee')) AS ObjectDefinition;
GO

EXEC sp_helptext N'dbo.vwEmployee';
GO

UPDATE dbo.Product
SET Price = Price
WHERE ID = 1;

SELECT @@ROWCOUNT AS AffectedRows;
GO
```

### `scripts/09-triggers-demo.sql`

```sql
USE SQLServerTutorialDB;
GO

-- Demo-only DML trigger
DROP TRIGGER IF EXISTS dbo.trg_Product_NoDirectInsert;
GO

CREATE TRIGGER dbo.trg_Product_NoDirectInsert
ON dbo.Product
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    THROW 50020, N'Direct inserts into dbo.Product are blocked by the demo trigger.', 1;
END;
GO

-- Leave disabled by default so the demo script is safer to run.
DISABLE TRIGGER dbo.trg_Product_NoDirectInsert ON dbo.Product;
GO

-- Demo-only DDL trigger
DROP TRIGGER IF EXISTS trg_BlockTableChanges ON DATABASE;
GO

CREATE TRIGGER trg_BlockTableChanges
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    SET NOCOUNT ON;

    PRINT N'Schema changes are blocked by trg_BlockTableChanges.';
    ROLLBACK TRANSACTION;
END;
GO

-- Leave disabled by default so future schema work is not blocked.
DISABLE TRIGGER trg_BlockTableChanges ON DATABASE;
GO

-- Demo commands:
-- ENABLE TRIGGER dbo.trg_Product_NoDirectInsert ON dbo.Product;
-- INSERT INTO dbo.Product (Name, Price) VALUES (N'Test Product', 9.99);
-- DISABLE TRIGGER dbo.trg_Product_NoDirectInsert ON dbo.Product;

-- ENABLE TRIGGER trg_BlockTableChanges ON DATABASE;
-- CREATE TABLE dbo.DemoBlock (ID INT);
-- DISABLE TRIGGER trg_BlockTableChanges ON DATABASE;
GO
```

### `scripts/10-cursors-demo.sql`

```sql
USE SQLServerTutorialDB;
GO

DECLARE @ID INT;
DECLARE @Salary DECIMAL(10,2);
DECLARE @TotalSalary DECIMAL(18,2);

SET @TotalSalary = 0;

DECLARE emp_cur CURSOR FAST_FORWARD
FOR
SELECT ID, Salary
FROM dbo.Employee
ORDER BY ID;

OPEN emp_cur;

FETCH NEXT FROM emp_cur
INTO @ID, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TotalSalary = @TotalSalary + @Salary;

    FETCH NEXT FROM emp_cur
    INTO @ID, @Salary;
END;

CLOSE emp_cur;
DEALLOCATE emp_cur;

SELECT @TotalSalary AS CursorTotalSalary;
GO

SELECT SUM(Salary) AS SetBasedTotalSalary
FROM dbo.Employee;
GO
```

### `scripts/11-transactions-demo.sql`

```sql
USE SQLServerTutorialDB;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Product
    SET Price = Price + 0.25
    WHERE ID = 1;

    UPDATE dbo.StoreProduct
    SET Amount = Amount - 5
    WHERE S_ID = 1
      AND P_ID = 1
      AND Amount >= 5;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50030, N'Inventory row was not updated. Check stock or keys.', 1;
    END;

    SELECT
        p.Name,
        p.Price,
        sp.Amount
    FROM dbo.Product AS p
    INNER JOIN dbo.StoreProduct AS sp
        ON p.ID = sp.P_ID
    WHERE p.ID = 1
      AND sp.S_ID = 1;

    -- Preview-safe demo: undo the transaction intentionally.
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH;
GO
```

### `scripts/12-indexes.sql`

```sql
USE SQLServerTutorialDB;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Employee_S_ID'
      AND object_id = OBJECT_ID(N'dbo.Employee')
)
    DROP INDEX IX_Employee_S_ID ON dbo.Employee;
GO

CREATE NONCLUSTERED INDEX IX_Employee_S_ID
ON dbo.Employee (S_ID)
INCLUDE (Salary, Name);
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Store_C_ID'
      AND object_id = OBJECT_ID(N'dbo.Store')
)
    DROP INDEX IX_Store_C_ID ON dbo.Store;
GO

CREATE NONCLUSTERED INDEX IX_Store_C_ID
ON dbo.Store (C_ID)
INCLUDE (Name, City);
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_StoreProduct_SID_PID'
      AND object_id = OBJECT_ID(N'dbo.StoreProduct')
)
    DROP INDEX IX_StoreProduct_SID_PID ON dbo.StoreProduct;
GO

CREATE NONCLUSTERED INDEX IX_StoreProduct_SID_PID
ON dbo.StoreProduct (S_ID, P_ID)
INCLUDE (Amount);
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Product_Name'
      AND object_id = OBJECT_ID(N'dbo.Product')
)
    DROP INDEX IX_Product_Name ON dbo.Product;
GO

CREATE NONCLUSTERED INDEX IX_Product_Name
ON dbo.Product (Name);
GO
```

## Testing Checklist and Limitations

For actual use, the safest execution order is: create database, create tables, seed data, run read-only query scripts, then create views, procedures, functions, and metadata examples. The transaction demo is safe because it rolls back intentionally, but the trigger script should still be treated as demonstration-only. Microsoft documents that DDL triggers can intercept and roll back table DDL, that `CREATE VIEW`/`CREATE PROCEDURE`/`CREATE TRIGGER` must be batched correctly, that `WITH ENCRYPTION` on views hides stored definition text rather than encrypting table data, and that `PRIMARY KEY` and `UNIQUE` constraints automatically create supporting indexes. citeturn10search0turn9search1turn9search2turn9search3turn4search3turn3search14

The main limitation of this deliverable is environmental: I statically audited and rewrote the scripts against the documented SQL Server syntax and catalog behavior, but I did not execute them against a live SQL Server 2016/2019/2022 instance from this environment. The biggest practical version boundary is optional use of `CREATE OR ALTER`: if you later refactor the repository to use it in executable scripts, views, procedures, functions, and triggers require SQL Server 2016 SP1 or later. If you need stricter backward compatibility, keep the `DROP ... IF EXISTS` plus `CREATE ...` pattern used above. citeturn6search0turn6search1turn8search1turn8search2turn14view0turn7search0turn7search2turn17view0
