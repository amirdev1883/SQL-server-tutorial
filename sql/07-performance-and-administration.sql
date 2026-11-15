USE BikeShareTutorialDB;
GO

-- Build a larger heap for a comparison that fits on more than one data page.
DROP TABLE IF EXISTS #TripSearch;

SELECT value AS SearchID,
       CASE WHEN value % 200 = 0 THEN 'CENT' ELSE 'MUSE' END AS DepartureCode,
       DATEADD(minute, value, CONVERT(datetime2(0), '2026-05-01T00:00:00')) AS StartedAt,
       CONVERT(decimal(8, 2), (value % 500) / 100.0) AS Fare
INTO #TripSearch
FROM GENERATE_SERIES(1, 20000);

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT StartedAt, Fare
FROM #TripSearch
WHERE DepartureCode = 'CENT'
  AND StartedAt >= '2026-05-05T00:00:00'
  AND StartedAt <  '2026-05-06T00:00:00'
ORDER BY StartedAt;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

CREATE NONCLUSTERED INDEX IX_TripSearch_DepartureTime
    ON #TripSearch (DepartureCode, StartedAt) INCLUDE (Fare);

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT StartedAt, Fare
FROM #TripSearch
WHERE DepartureCode = 'CENT'
  AND StartedAt >= '2026-05-05T00:00:00'
  AND StartedAt <  '2026-05-06T00:00:00'
ORDER BY StartedAt;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

DROP TABLE #TripSearch;
GO

-- Look up the trip table and its columns, indexes, and constraints.
SELECT s.name AS SchemaName, o.name AS ObjectName, o.type_desc
FROM sys.objects AS o
INNER JOIN sys.schemas AS s ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
ORDER BY s.name, o.type_desc, o.name;

SELECT c.name AS ColumnName, TYPE_NAME(c.user_type_id) AS TypeName, c.is_nullable
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID(N'dbo.Trip')
ORDER BY c.column_id;

SELECT name AS IndexName, type_desc, is_unique
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.Trip')
ORDER BY index_id;

SELECT name AS ConstraintName, definition
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID(N'dbo.Trip')
ORDER BY name;

SELECT name AS TriggerName, parent_class_desc, is_disabled
FROM sys.triggers
WHERE is_ms_shipped = 0
ORDER BY name;

SELECT OBJECT_DEFINITION(OBJECT_ID(N'dbo.vwCompletedTrips')) AS ViewDefinition;

SELECT OBJECT_NAME(object_id) AS ModuleName, definition
FROM sys.sql_modules
WHERE object_id = OBJECT_ID(N'dbo.vwCompletedTrips');

EXEC sys.sp_helptext N'dbo.vwCompletedTrips';
GO

-- Compare regular and obscured module definitions without leaving the demo view.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    EXEC sys.sp_executesql N'
        CREATE VIEW dbo.vwLabCapacity
        WITH ENCRYPTION
        AS
        SELECT StationCode, DockCapacity
        FROM dbo.Station;
    ';

    SELECT OBJECT_ID(N'dbo.vwLabCapacity', N'V') AS ViewID,
           OBJECT_DEFINITION(OBJECT_ID(N'dbo.vwLabCapacity')) AS HiddenDefinition;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Grant a sandbox user access to one reporting view through a role.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    CREATE ROLE BikeShareReportReader AUTHORIZATION dbo;
    CREATE USER BikeShareDemoReader WITHOUT LOGIN;
    ALTER ROLE BikeShareReportReader ADD MEMBER BikeShareDemoReader;
    GRANT SELECT ON OBJECT::dbo.vwCompletedTrips TO BikeShareReportReader;

    EXECUTE AS USER = N'BikeShareDemoReader';
    BEGIN TRY
        SELECT USER_NAME() AS ReaderName,
               COALESCE(HAS_PERMS_BY_NAME(N'dbo.Trip', N'OBJECT', N'SELECT'), 0) AS CanSelectTripTable;

        SELECT COUNT(*) AS ReadableCompletedTrips
        FROM dbo.vwCompletedTrips;
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
GO
