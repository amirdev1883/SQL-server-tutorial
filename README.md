# SQL Server Tutorial

**English** · [Persian](README.fa.md)

A hands-on SQL Server tutorial based on a U.S. grocery chain. The sample stores, employees, and amounts are fictional. Prices and annual salaries are in U.S. dollars.

> Start with `CREATE TABLE`, `INSERT`, and `SELECT`. Then use the same retail database to practice joins, views, stored procedures, functions, triggers, cursors, transactions, indexing, and metadata.

## Table of contents

- [Getting started](#getting-started)
- [Project overview](#project-overview)
- [What are SQL and SQL Server?](#what-are-sql-and-sql-server)
- [Learning objectives](#learning-objectives)
- [Data model and relationships](#data-model-and-relationships)
- [Creating the database and tables](#creating-the-database-and-tables)
- [Inserting sample data](#inserting-sample-data)
- [Basic queries](#basic-queries)
- [JOINs and data analysis](#joins-and-data-analysis)
- [Views in SQL Server](#views-in-sql-server)
- [Stored procedures](#stored-procedures)
- [Functions](#functions)
- [Triggers](#triggers)
- [Cursors](#cursors)
- [Transactions and error handling](#transactions-and-error-handling)
- [Indexes and performance](#indexes-and-performance)
- [Objects and metadata](#objects-and-metadata)
- [Best practices](#best-practices)
- [Summary](#summary)
- [Advanced lessons and exercises](english/advanced.md)

## Getting started

1. Connect to a SQL Server 2022 or later development instance. See [SQL Server setup](english/01-setup-and-design.md#connect-to-sql-server) for SSMS, VS Code, and Docker instructions.
2. Run the complete script under [Creating the database and tables](#creating-the-database-and-tables). The English edition uses `SQLServerTutorialENDB`. The individual table definitions below that script explain its parts.
3. Run the five [sample data blocks](#inserting-sample-data) once, in order, on the newly created tables. The examples expect IDs to start at 1. You should have 4 chains, 6 stores, 8 products, 8 employees, and 24 inventory rows.
4. Keep the connection in `SQLServerTutorialENDB` while running the examples. `GO` is a batch separator recognized by clients such as SSMS and `sqlcmd`. Start each transaction exercise in a fresh query window and run `USE SQLServerTutorialENDB;` to select the right database.

After the basic queries, you can also try the [advanced lessons and exercises](english/advanced.md) on CTEs, inventory analysis, execution plans, and permissions.

## Project overview

The database represents four grocery chains with stores in Seattle, Chicago, Austin, Minneapolis, and Milwaukee. Use it to answer questions such as which products each store carries and which branch has the most valuable inventory.

- **Product** stores product names and prices.
- **Chain_Store** stores the name of each grocery chain.
- **Store** stores the locations operated by each chain.
- **Employee** stores the employees assigned to each store.
- **StoreProduct** stores each product's quantity at each store.

## What are SQL and SQL Server?

- **SQL** is a language for querying and changing relational data.
- **SQL Server** is Microsoft's relational database management system.
- **Transact-SQL (T-SQL)** is SQL Server's dialect. It provides variables, conditions, loops, stored procedures, functions, triggers, and transactions.

## Learning objectives

By the end of the tutorial, you should be able to:

- Create and populate tables with primary keys, foreign keys, and constraints.
- Filter, sort, group, and join data for retail reports.
- Create views, stored procedures, and user-defined functions.
- Write a trigger that handles changes to multiple rows and compare a cursor with set-based SQL.
- Use transactions and error handling to keep related changes consistent.
- Create indexes and inspect database objects in the system catalog.

## Data model and relationships

### Relationships

- One chain can operate many stores. `Store.C_ID` references `Chain_Store.ID`.
- One store can employ many people. `Employee.S_ID` references `Store.ID`.
- A store can carry many products, and a product can be carried by many stores. `StoreProduct` holds this many-to-many relationship. Its `S_ID` and `P_ID` reference a store and a product.

### Why this model works

A product's name and price are stored once. Each location records only the quantity it has in stock. That keeps a price change in one place while letting every store track its inventory independently.

## Creating the database and tables

The setup creates five tables in one transaction. It uses named constraints, exact decimals for money, and Unicode text for names. It checks for existing practice tables before creating anything.

```sql
IF DB_ID(N'SQLServerTutorialENDB') IS NULL
    CREATE DATABASE SQLServerTutorialENDB;
GO

USE SQLServerTutorialENDB;
GO

IF EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE schema_id = SCHEMA_ID(N'dbo')
      AND name IN (N'Chain_Store', N'Product', N'Store', N'Employee', N'StoreProduct')
)
    THROW 50000, N'The practice tables already exist. Use an empty tutorial database.', 1;

SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    CREATE TABLE dbo.Chain_Store
    (
        ID INT IDENTITY(1,1) CONSTRAINT PK_Chain_Store PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL CONSTRAINT UQ_Chain_Store_Name UNIQUE
    );

    CREATE TABLE dbo.Product
    (
        ID INT IDENTITY(1,1) CONSTRAINT PK_Product PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Price DECIMAL(10,2) NOT NULL,
        CONSTRAINT CK_Product_Price CHECK (Price > 0)
    );

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

    CREATE TABLE dbo.Employee
    (
        ID INT IDENTITY(1,1) CONSTRAINT PK_Employee PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Salary DECIMAL(10,2) NOT NULL,
        S_ID INT NOT NULL,
        CONSTRAINT FK_Employee_Store FOREIGN KEY (S_ID) REFERENCES dbo.Store(ID),
        CONSTRAINT CK_Employee_Salary CHECK (Salary > 0)
    );

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

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
```

### Table definitions

#### The `Product` table

```sql
CREATE TABLE dbo.Product
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Product PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT CK_Product_Price CHECK (Price > 0)
);
```

`ID` is the primary key. `IDENTITY(1,1)` generates IDs starting at 1 with an increment of 1. `DECIMAL(10,2)` allows ten total digits, including two decimal places. The price check requires a positive amount.

#### The `Chain_Store` table

```sql
CREATE TABLE dbo.Chain_Store
(
    ID INT IDENTITY(1,1) CONSTRAINT PK_Chain_Store PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL CONSTRAINT UQ_Chain_Store_Name UNIQUE
);
```

The unique constraint on `Name` gives each chain a distinct name.

#### The `Store` table

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

`Zone` uses `TINYINT`, with a check restricting it to 1–20. `C_ID` is the foreign key to the chain that operates the store.

#### The `Employee` table

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

`S_ID` assigns each employee to one store. `Salary` stores an annual amount as an exact decimal.

#### The `StoreProduct` table

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

The combination of `S_ID` and `P_ID` is unique, so each product has one inventory row per store. `Amount` records the number of units on hand and allows zero.

## Inserting sample data

### Using Unicode text

Prefix string literals assigned to Unicode columns with `N`, as in `N'Capitol Hill'`. This keeps the same syntax usable for a name such as `N'Café Corner'`.

### Insert grocery chains

```sql
INSERT INTO dbo.Chain_Store (Name)
VALUES
    (N'Maple Street Market'),
    (N'Heartland Fresh Market'),
    (N'Riverbend Foods'),
    (N'Prairie Pantry');
GO
```

### Insert products

```sql
INSERT INTO dbo.Product (Name, Price)
VALUES
    (N'Whole Milk, 1 gal', 4.49),
    (N'Cola, 2 L', 2.29),
    (N'Vegetable Oil, 48 fl oz', 5.99),
    (N'Long-Grain White Rice, 5 lb', 7.49),
    (N'Spaghetti, 1 lb', 1.79),
    (N'2% Milk, 1 gal', 3.99),
    (N'Large Eggs, 1 dozen', 4.29),
    (N'Boneless Chicken Breasts, 3 lb', 12.99);
GO
```

### Insert store locations

```sql
INSERT INTO dbo.Store (Name, Zone, City, Address, C_ID)
VALUES
    (N'Maple Street Market - Capitol Hill', 1, N'Seattle, WA', N'1200 E Pine St', 1),
    (N'Maple Street Market - Columbia City', 2, N'Seattle, WA', N'4800 Rainier Ave S', 1),
    (N'Heartland Fresh Market - West Loop', 3, N'Chicago, IL', N'940 W Madison St', 2),
    (N'Riverbend Foods - East Austin', 4, N'Austin, TX', N'2310 E Cesar Chavez St', 3),
    (N'Prairie Pantry - Northeast', 5, N'Minneapolis, MN', N'1220 Central Ave NE', 4),
    (N'Heartland Fresh Market - Bay View', 1, N'Milwaukee, WI', N'2810 S Kinnickinnic Ave', 2);
GO
```

### Insert employees

```sql
INSERT INTO dbo.Employee (Name, Salary, S_ID)
VALUES
    (N'Jordan Miller', 44000.00, 1),
    (N'Taylor Brooks', 39000.00, 1),
    (N'Logan Reed', 51000.00, 2),
    (N'Morgan Hayes', 42000.00, 3),
    (N'Cameron Davis', 55000.00, 4),
    (N'Casey Nguyen', 46000.00, 5),
    (N'Riley Bennett', 49000.00, 6),
    (N'Avery Parker', 43000.00, 2);
GO
```

### Insert store inventory

```sql
INSERT INTO dbo.StoreProduct (S_ID, P_ID, Amount)
VALUES
    -- Maple Street Market - Capitol Hill
    (1, 1, 150), (1, 2, 200), (1, 3, 100), (1, 4, 80),

    -- Maple Street Market - Columbia City
    (2, 1, 120), (2, 5, 180), (2, 6, 90), (2, 7, 110),

    -- Heartland Fresh Market - West Loop
    (3, 2, 160), (3, 3, 70), (3, 4, 60), (3, 8, 50),

    -- Riverbend Foods - East Austin
    (4, 1, 90), (4, 6, 120), (4, 7, 80), (4, 5, 150),

    -- Prairie Pantry - Northeast
    (5, 3, 110), (5, 4, 70), (5, 8, 60), (5, 2, 180),

    -- Heartland Fresh Market - Bay View
    (6, 1, 130), (6, 2, 170), (6, 5, 140), (6, 7, 100);
GO
```

## Basic queries

## Show all rows

```sql
SELECT * FROM dbo.Chain_Store;
SELECT * FROM dbo.Store;
SELECT * FROM dbo.Employee;
SELECT * FROM dbo.Product;
SELECT * FROM dbo.StoreProduct;
```

`SELECT *` returns every column. Use it to explore a table when you first open the lab.

## Select specific columns

```sql
SELECT Name, Price
FROM dbo.Product;
```

Selecting `Name` and `Price` returns only the fields needed for a price list.

## Filter with WHERE

### Salaries above a threshold

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary > 44000.00;
```

### Salaries within a range

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary BETWEEN 44000.00 AND 49000.00;
```

`BETWEEN` includes both boundaries. The example includes Jordan Miller at $44,000 and Riley Bennett at $49,000.

### Search names with LIKE

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Name LIKE N'%er';
```

`%` matches any sequence of characters. The pattern `%er` matches names ending in `er`, such as Jordan Miller and Avery Parker.

## DISTINCT

```sql
SELECT DISTINCT City
FROM dbo.Store;
```

`DISTINCT` returns one row per unique city value. The two Seattle stores contribute one `Seattle, WA` row.

## Sort with ORDER BY

```sql
SELECT Name, Price
FROM dbo.Product
ORDER BY Price DESC;
```

`ASC` sorts from low to high. `DESC` sorts from high to low, so the most expensive merchandise appears first.

## Aggregate functions

```sql
SELECT
    COUNT(*) AS TotalProducts,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice,
    AVG(Price) AS AvgPrice,
    SUM(Price) AS SumPrice
FROM dbo.Product;
```

These expressions return a count, minimum, maximum, average, and sum over the product rows. The count is 8.

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

`GROUP BY S_ID` calculates a headcount, average salary, and payroll total for each store ID.

## HAVING

```sql
SELECT
    S_ID,
    COUNT(*) AS EmployeeCount
FROM dbo.Employee
GROUP BY S_ID
HAVING COUNT(*) > 1;
```

`WHERE` filters individual rows before grouping. `HAVING` filters the groups after aggregation. The example returns stores 1 and 2 because each has two employees.

## Subquery

```sql
SELECT Name, Salary
FROM dbo.Employee
WHERE Salary > (
    SELECT AVG(Salary)
    FROM dbo.Employee
);
```

The inner query calculates the overall average salary. The outer query returns employees paid above that amount.

## Window function

```sql
SELECT
    Name,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC, ID) AS SalaryRank
FROM dbo.Employee
ORDER BY SalaryRank;
```

`ROW_NUMBER()` ranks the eight salary rows. It keeps a separate row for each employee and uses the ID to break a salary tie.

## JOINs and data analysis

A join connects related rows through their keys. Decide what each output row should represent before adding tables to the query.

## Basic INNER JOIN

```sql
SELECT
    s.Name AS StoreName,
    COUNT(e.ID) AS EmployeeCount
FROM dbo.Store AS s
INNER JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
GROUP BY s.ID, s.Name
ORDER BY s.Name;
```

The join returns the branches with matching employees. Group by both store ID and display name so separately identified stores get separate counts.

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

The left join keeps every store. If a store has no assigned employees, `EmployeeName` is `NULL` for that result row.

## Join three tables

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

Join the chain to the store through `Store.C_ID`, then the store to its employees through `Employee.S_ID`. The output includes the chain, store, and employee names.

## Report inventory by store

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

Each output row shows the quantity of one product at one store.

## Calculate inventory value by store

```sql
SELECT
    s.Name AS StoreName,
    SUM(p.Price * sp.Amount) AS InventoryValue
FROM dbo.StoreProduct AS sp
INNER JOIN dbo.Store AS s
    ON sp.S_ID = s.ID
INNER JOIN dbo.Product AS p
    ON sp.P_ID = p.ID
GROUP BY s.ID, s.Name
ORDER BY InventoryValue DESC;
```

Multiply each product's price by its quantity and sum the values per store. The result estimates inventory value at the listed retail prices.

## Views in SQL Server

A view stores a query definition. You can query a view as a table source and reuse it across multiple reports. Views can also expose a selected set of columns to reporting users.

## Create a basic view

```sql
CREATE OR ALTER VIEW dbo.vwEmployee
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

## Query a view

```sql
SELECT * FROM dbo.vwEmployee;
SELECT DISTINCT EmployeeName FROM dbo.vwEmployee;
```

The view gives you employee names, store names, chain names, and salaries without rewriting the joins.

## Create an aggregate view

```sql
CREATE OR ALTER VIEW dbo.vwStoreEmployeeCount
AS
SELECT
    s.Name AS StoreName,
    COUNT(e.ID) AS EmployeeCount
FROM dbo.Store AS s
LEFT JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
GROUP BY s.ID, s.Name;
GO
```

The view counts employee IDs, so a store with an empty employee list appears with zero.

## Alter a view

```sql
ALTER VIEW dbo.vwStoreEmployeeCount
AS
SELECT
    s.Name AS StoreName,
    COUNT(e.ID) AS EmployeeCount
FROM dbo.Store AS s
LEFT JOIN dbo.Employee AS e
    ON s.ID = e.S_ID
GROUP BY s.ID, s.Name
HAVING COUNT(e.ID) > 1;
GO
```

The updated definition returns stores with at least two employees.

## View with ENCRYPTION

```sql
CREATE OR ALTER VIEW dbo.vwStoreName
WITH ENCRYPTION
AS
SELECT DISTINCT Name
FROM dbo.Store;
GO
```

`WITH ENCRYPTION` obscures the stored view definition from normal metadata queries. The authorized user can still query the rows the view exposes.

## Stored procedures

A stored procedure packages statements into a named operation. It can return a result set, accept inputs, assign an output parameter, or change data.

## Basic procedure

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

### Run the procedure

```sql
EXEC dbo.GetAllProducts;
```

## Procedure with input parameters

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

### Run the procedure

```sql
EXEC dbo.GetProductsByPriceRange @MinPrice = 3.00, @MaxPrice = 8.00;
```

The inputs request products priced from $3.00 to $8.00, inclusive.

## Procedure with an output parameter

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

### Run the procedure

```sql
DECLARE @ProductCount INT;

EXEC dbo.GetProductCount @Count = @ProductCount OUTPUT;

SELECT @ProductCount AS ProductCount;
```

Use `OUTPUT` in the definition and in the call to receive the value. The sample count is 8.

## Procedure for one store's inventory

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

### Run the procedure

```sql
EXEC dbo.GetProductsByStore @StoreID = 2;
```

Store 2 is Maple Street Market's Columbia City branch. The procedure returns four products and their stock quantities.

## Procedure with error handling and affected-row checks

```sql
CREATE OR ALTER PROCEDURE dbo.UpdateProductPrice
    @ProductID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @NewPrice IS NULL OR @NewPrice <= 0
            THROW 50001, N'The product price must be greater than zero.', 1;

        UPDATE dbo.Product
        SET Price = @NewPrice
        WHERE ID = @ProductID;

        IF @@ROWCOUNT = 0
            THROW 50002, N'No product was found with that ID.', 1;

        SELECT N'Price updated successfully' AS Result;
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
        THROW;
    END CATCH;
END;
GO
```

### Run the procedure

```sql
BEGIN TRANSACTION;
EXEC dbo.UpdateProductPrice @ProductID = 1, @NewPrice = 4.79;
SELECT ID, Name, Price FROM dbo.Product WHERE ID = 1;
ROLLBACK TRANSACTION;
```

The transaction shows an updated price of $4.79 for the whole milk. `ROLLBACK` restores its starting price of $4.49. Inside the procedure, `@@ROWCOUNT` detects a missing product, and `THROW` passes an error back to the caller.

## Functions

A user-defined function packages a calculation or a table expression for use in another query.

### Common function types

- A **scalar function** returns one value.
- An **inline table-valued function** returns a result defined by one query.
- A **multi-statement table-valued function** fills and returns a table variable.

## Scalar function

### Calculate an illustrative sales tax

```sql
CREATE OR ALTER FUNCTION dbo.CalculateTax(@Price DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Tax DECIMAL(10,2);

    SET @Tax = ROUND(@Price * 0.075, 2);

    RETURN @Tax;
END;
GO
```

### Use the function

```sql
SELECT
    Name,
    Price,
    dbo.CalculateTax(Price) AS Tax,
    Price + dbo.CalculateTax(Price) AS TotalPrice
FROM dbo.Product;
```

The example uses a fixed 7.5% rate for practice and rounds the result to cents.

## Another scalar function

### Count the employees in a store

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

### Use the function

```sql
SELECT
    Name,
    dbo.GetEmployeeCount(ID) AS EmployeeCount
FROM dbo.Store;
```

## Inline table-valued function

### Return the products for one store

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

### Use the function

```sql
SELECT *
FROM dbo.GetStoreProducts(3);
```

Store 3 is Heartland Fresh Market's West Loop branch.

## Another inline table-valued function

### Find low-stock products

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

### Use the function

```sql
SELECT *
FROM dbo.GetLowStockProducts(90);
```

This call returns inventory rows with fewer than 90 units.

## Multi-statement table-valued function

### Summarize the stores in one chain

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

### Use the function

```sql
SELECT *
FROM dbo.GetStoreSummary(2);
```

Chain 2 is Heartland Fresh Market. Its West Loop and Bay View stores appear with employee counts, product counts, and inventory values.

## Function notes

Call a user-defined function with its schema, as in `dbo.CalculateTax(Price)` or `dbo.GetStoreProducts(3)`. Use a scalar function for a single value and a table-valued function when callers need to join or filter the returned rows.

## Triggers

A trigger runs automatically in response to an event.

### Types of triggers

- **DML triggers** respond to `INSERT`, `UPDATE`, or `DELETE`.
- **DDL triggers** respond to schema events such as `CREATE TABLE`.
- **Logon triggers** respond to a session being established.

## DML trigger that reports price changes

The table's check constraint validates the price before an `AFTER` trigger runs. This trigger compares the new price in `inserted` with the old one in `deleted` and reports how many prices changed.

```sql
CREATE OR ALTER TRIGGER dbo.trg_Product_ReportPriceChange
ON dbo.Product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Changes INT = (
        SELECT COUNT(*)
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.ID = i.ID
        WHERE i.Price <> d.Price
    );

    PRINT CONCAT(N'Product prices changed: ', @Changes);
END;
GO
```

### Test the trigger

```sql
BEGIN TRANSACTION;

UPDATE dbo.Product
SET Price = Price + 0.25
WHERE ID IN (1, 2);

ROLLBACK TRANSACTION;
```

The client messages show that **2** prices changed. One `UPDATE` fires the trigger once, and both affected rows are available to its query.

## INSTEAD OF trigger

An `INSTEAD OF INSERT` trigger runs in place of the submitted insert. The example validates the batch of incoming rows and then writes those rows to `Product`.

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
        THROW 50011, N'A product price must be greater than zero.', 1;
    END;

    INSERT INTO dbo.Product (Name, Price)
    SELECT Name, Price
    FROM inserted;
END;
GO
```

### Disable and enable the trigger

```sql
DISABLE TRIGGER dbo.trg_Product_InsteadOfInsert ON dbo.Product;
ENABLE TRIGGER dbo.trg_Product_InsteadOfInsert ON dbo.Product;
```

## Database-scoped DDL trigger

The trigger uses `EVENTDATA()` to read the name of a newly created table. The lab rolls back both the trigger and the probe table.

```sql
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    EXEC sys.sp_executesql N'
        CREATE TRIGGER trg_ReportRetailTableCreation
        ON DATABASE
        FOR CREATE_TABLE
        AS
        BEGIN
            SET NOCOUNT ON;
            DECLARE @Event XML = EVENTDATA();
            DECLARE @TableName SYSNAME = @Event.value(''(/EVENT_INSTANCE/ObjectName)[1]'', ''sysname'');
            PRINT CONCAT(N''Created table: '', @TableName);
        END;
    ';

    CREATE TABLE dbo.RetailDDLProbe (ID INT PRIMARY KEY);

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

Look for `RetailDDLProbe` in the messages. `sp_executesql` runs the trigger definition in a separate batch within the transaction.

## Cursors

A cursor fetches rows individually. The example visits each employee's salary and adds it to a running total.

## Cursor example

```sql
DECLARE @ID INT;
DECLARE @Salary DECIMAL(10,2);
DECLARE @SumSalary DECIMAL(18,2) = 0;

DECLARE emp_cur CURSOR LOCAL FAST_FORWARD
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

### Walk through the cursor

- `DECLARE` defines the row source and cursor options.
- `OPEN` opens the cursor.
- `FETCH NEXT` advances and assigns values to the variables.
- A `@@FETCH_STATUS` of 0 means the fetch succeeded.
- `CLOSE` closes the cursor and `DEALLOCATE` releases it.

## Set-based alternative to a cursor

```sql
SELECT COALESCE(SUM(Salary), 0) AS TotalSalary
FROM dbo.Employee;
```

### Compare the results

The cursor prints **369000.00** and the aggregate returns the same total. Prefer an aggregate when the calculation applies to the whole set. A cursor is useful when a separate operation must run for each row.

## Transactions and error handling

A transaction groups statements into one operation. `COMMIT` saves the changes together. `ROLLBACK` undoes the changes in the active transaction.

## Transaction example

This lab previews a 50-cent price increase and removes ten units from the store's stock. If either change fails, the error handler rolls back the transaction and raises the error again.

```sql
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Product
    SET Price = Price + 0.50
    WHERE ID = 1;

    IF @@ROWCOUNT <> 1
        THROW 50020, N'The requested product was not found.', 1;

    UPDATE dbo.StoreProduct
    SET Amount = Amount - 10
    WHERE S_ID = 1 AND P_ID = 1 AND Amount >= 10;

    IF @@ROWCOUNT <> 1
        THROW 50021, N'There is not enough stock for this change.', 1;

    SELECT p.Price, sp.Amount
    FROM dbo.Product AS p
    INNER JOIN dbo.StoreProduct AS sp ON sp.P_ID = p.ID
    WHERE p.ID = 1 AND sp.S_ID = 1;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

Inside the transaction, whole milk costs **$4.99** and store 1 has **140** units. After the rollback, the price is **$4.49** and the quantity is **150**.

## Indexes and performance

Indexes can help SQL Server find and join rows efficiently. Run these definitions once in the English lab, then try the [execution plan exercise](english/advanced.md#execution-plans-and-page-reads).

### Index examples

```sql
CREATE NONCLUSTERED INDEX IX_Employee_S_ID
ON dbo.Employee (S_ID);
GO

CREATE NONCLUSTERED INDEX IX_Store_C_ID
ON dbo.Store (C_ID);
GO

CREATE NONCLUSTERED INDEX IX_StoreProduct_Product
ON dbo.StoreProduct (P_ID) INCLUDE (S_ID, Amount);
GO

CREATE NONCLUSTERED INDEX IX_Product_Name
ON dbo.Product (Name);
GO
```

### What these indexes support

- `Employee(S_ID)` helps look up employees by store.
- `Store(C_ID)` helps find the stores in one chain.
- `StoreProduct(P_ID)` helps find which locations carry a product. The included columns cover a query that also needs the store ID and quantity.
- `Product(Name)` supports searches by product name.

### Indexes created by constraints

Primary-key and unique constraints create supporting indexes. The unique index on `(S_ID, P_ID)` already supports looking up inventory by store. For a foreign key, choose an index based on the joins and filters you're actually running.

## Objects and metadata

SQL Server catalog views describe tables, views, triggers, and other database objects.

## List database objects

```sql
SELECT name, type, type_desc
FROM sys.objects
ORDER BY type, name;
```

## List tables

```sql
SELECT name, type_desc
FROM sys.objects
WHERE type = 'U';
```

## List views

```sql
SELECT name, type_desc
FROM sys.objects
WHERE type = 'V';
```

## List triggers

```sql
SELECT name, parent_class_desc, is_disabled
FROM sys.triggers;
```

## Read a view definition with OBJECT_DEFINITION

```sql
SELECT OBJECT_DEFINITION(OBJECT_ID(N'dbo.vwEmployee')) AS ViewDefinition;
```

## Read a definition through sys.sql_modules

```sql
SELECT sm.definition
FROM sys.sql_modules AS sm
WHERE sm.object_id = OBJECT_ID(N'dbo.vwEmployee');
```

## Read a definition with sp_helptext

```sql
EXEC sp_helptext N'dbo.vwEmployee';
```

## System functions and variables

### @@ROWCOUNT

```sql
BEGIN TRANSACTION;

UPDATE dbo.Product
SET Price = Price + 0.25
WHERE ID = 1;

SELECT @@ROWCOUNT AS AffectedRows;

ROLLBACK TRANSACTION;
```

Read `@@ROWCOUNT` immediately after the statement you want to measure. The update matches one product row.

## Best practices

### 1. Use NVARCHAR and the N prefix for Unicode

```sql
BEGIN TRANSACTION;

INSERT INTO dbo.Store (Name, Zone, City, Address, C_ID)
VALUES (N'Maple Street Market - Ballard', 2, N'Seattle, WA', N'1500 NW Market St', 1);

ROLLBACK TRANSACTION;
```

This example previews a new grocery store location within a transaction.

### 2. Use DECIMAL for money

Choose an exact decimal precision and scale for product prices and salaries.

### 3. Name your constraints

```sql
CONSTRAINT CK_Product_Price CHECK (Price > 0)
```

A descriptive name makes it easier to identify a constraint in an error message or in the catalog.

### 4. Select explicit columns for reports

List the columns each report needs so changes to the source table do not unexpectedly change its output.

### 5. Check for a set-based query before using a cursor

Use `SUM`, a join, or another set-based operation when it expresses the whole calculation directly.

### 6. Handle multiple rows in triggers

Use set operations on `inserted` and `deleted` so the trigger handles a batch of changes correctly.

### 7. Use TRY...CATCH for multi-step writes

Check the transaction state with `XACT_STATE()`, roll back when necessary, and preserve unexpected errors with `THROW;`.

### 8. Qualify database object names

Use names such as `dbo.Product`, `dbo.GetAllProducts`, and `dbo.vwEmployee` to identify the intended schema.

### 9. Choose indexes that fit the workload

Look for columns used frequently in joins, filters, or sorts. Compare plans and logical reads before deciding whether an index helps the query.

### 10. Combine CHECK and NOT NULL where required

Use `NOT NULL` when a value is mandatory. Add a `CHECK` constraint to enforce a rule about the values that can be stored.

## Summary

You can now query the same retail data from several angles, package reports in database objects, and test changes inside a transaction. The [advanced lessons and exercises](english/advanced.md) continue with a store inventory report, execution plans, permissions, and backups.
