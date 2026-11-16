# Advanced SQL Server lessons

[English tutorial](../README.md) · [Persian tutorial](../README.fa.md)

These lessons use the U.S. grocery dataset. First create the [tables and sample data](../README.md#getting-started). For the permissions example, also create `dbo.vwEmployee` from the main tutorial.

```sql
USE SQLServerTutorialENDB;
GO
```

## Missing values and left joins

Start with `Store` and use a `LEFT JOIN` to keep every store in the headcount report. `COUNT(e.ID)` counts the matching employees. When a store has no employees, `SUM(e.Salary)` returns `NULL` and `COALESCE` displays zero.

```sql
SELECT s.ID, s.Name,
       COUNT(e.ID) AS EmployeeCount,
       COALESCE(SUM(e.Salary), 0) AS TotalSalary
FROM dbo.Store AS s
LEFT JOIN dbo.Employee AS e ON e.S_ID = s.ID
GROUP BY s.ID, s.Name
ORDER BY s.ID;
```

Stores 1 and 2 have two employees each. The other four stores have one each. Use `IS NULL` when you need to filter for a missing value.

## CTEs and window functions

First calculate inventory value at each store. Then rank the stores within each chain and keep the first row. `PARTITION BY` starts the numbering again for each chain. The store ID breaks a tie in inventory value.

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

The query returns four rows. For Maple Street Market, Capitol Hill has the highest inventory value at **$2,329.70**. A common table expression (CTE) is available to the one statement that follows its definition. To reuse the rows across several statements on the same connection, store them in a local temporary table such as `#Inventory`.

## Compare two sets

`EXCEPT` returns distinct rows from the first query that are absent from the second. This example finds products in stock at Capitol Hill (store 1) that are unavailable at West Loop (store 3).

```sql
SELECT P_ID AS ProductID
FROM dbo.StoreProduct
WHERE S_ID = 1 AND Amount > 0
EXCEPT
SELECT P_ID
FROM dbo.StoreProduct
WHERE S_ID = 3 AND Amount > 0
ORDER BY ProductID;
```

The query returns **product 1**, whole milk. Replacing `EXCEPT` with `INTERSECT` finds the three shared products with IDs **2, 3, and 4**. `UNION` combines both results and removes duplicate output rows. `UNION ALL` keeps all output rows.

## Change data and inspect the result

Run this exercise in a fresh connection. Insert a product into a temporary table, update its price, and delete it. `OUTPUT` shows what each statement changed, and `ROLLBACK` undoes the work inside the transaction.

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
    VALUES (N'Honeycrisp Apples, 3 lb', 5.99);

    UPDATE #PricePractice
    SET Price = 6.49
    OUTPUT deleted.Price AS OldPrice, inserted.Price AS NewPrice
    WHERE Name = N'Honeycrisp Apples, 3 lb';

    DELETE FROM #PricePractice
    OUTPUT deleted.ID AS RemovedProduct
    WHERE Name = N'Honeycrisp Apples, 3 lb';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

DROP TABLE #PricePractice;
```

The update returns **$5.99** from `deleted.Price` and **$6.49** from `inserted.Price`. These row sources expose the values before and after the update.

## Execution plans and page reads

Enable **Include Actual Execution Plan** in SSMS. This lab builds a temporary table with 10,000 rows, then runs the same search before and after creating an index. Both searches return ten rows. Compare **logical reads** in Messages and the table access operator in the execution plan. `GENERATE_SERIES` requires SQL Server 2022 or later and a database compatibility level of at least 160.

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
WHERE ProductID = 108;

CREATE INDEX IX_InventorySearch_Product
ON #InventorySearch (ProductID) INCLUDE (InventoryID, Amount);

SELECT InventoryID, Amount
FROM #InventorySearch
WHERE ProductID = 108;

SET STATISTICS IO OFF;
DROP TABLE #InventorySearch;
```

The index uses `ProductID` as its search key. Its included columns hold the values requested by the result, so the query can be covered by the index. Use the plan and the page counts to measure its effect.

## Report permissions

Give a demo database user read access to the employee report through a role. `EXECUTE AS USER` lets you run the query with that user's permissions. `REVERT` restores your identity, and the final rollback removes the demo role and user.

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

The demo reader can query **8** rows through the view. You can grant the same reporting permission to additional users by placing them in the role.

## Backup

Replace the example path with a new file in a directory where the SQL Server service can write. `COPY_ONLY` creates an independent full backup, `RESTORE VERIFYONLY` checks its readability, and `RESTORE FILELISTONLY` gives you the logical file names to use when restoring the backup as a separate database. [Restore to a new location](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-to-a-new-location-sql-server)

```sql
DECLARE @BackupFile NVARCHAR(4000) = N'/var/opt/mssql/backup/SQLServerTutorialENDB-practice.bak';

BACKUP DATABASE SQLServerTutorialENDB TO DISK = @BackupFile WITH COPY_ONLY, CHECKSUM;
RESTORE VERIFYONLY FROM DISK = @BackupFile WITH CHECKSUM;
RESTORE FILELISTONLY FROM DISK = @BackupFile;
```

## Final exercise

Build a report with one row per store. Show its grocery chain, location name, employee count, and inventory value at retail prices. Aggregate employees and inventory separately by store before joining the results. A direct join of the individual employee and inventory rows can multiply the counts.

Your report should have **six** rows and a total inventory value of **$11,428.30**. The highest-value store is **Prairie Pantry - Northeast** at **$2,374.80**, with **one** employee.

<details>
<summary>Suggested solution</summary>

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

[Back to the English tutorial](../README.md)
