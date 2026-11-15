USE BikeShareTutorialDB;
GO

IF OBJECT_ID(N'dbo.TripStatusAudit', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TripStatusAudit
    (
        AuditID bigint IDENTITY(1, 1) CONSTRAINT PK_TripStatusAudit PRIMARY KEY,
        TripCode varchar(8) NOT NULL,
        PreviousStatus varchar(12) NOT NULL,
        NewStatus varchar(12) NOT NULL,
        ChangedAt datetime2(3) NOT NULL CONSTRAINT DF_TripStatusAudit_ChangedAt DEFAULT (SYSUTCDATETIME())
    );
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_Trip_AuditStatus
ON dbo.Trip
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.TripStatusAudit (TripCode, PreviousStatus, NewStatus)
    SELECT i.TripCode, d.TripStatus, i.TripStatus
    FROM inserted AS i
    INNER JOIN deleted AS d ON d.TripID = i.TripID
    WHERE i.TripStatus <> d.TripStatus;
END;
GO

SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Trip (TripCode, RiderID, BicycleID, StartStationID, StartedAt)
    SELECT 'LAB-TRIP', r.RiderID, b.BicycleID, s.StationID, '2026-05-04T14:00:00'
    FROM dbo.Rider AS r
    CROSS JOIN dbo.Bicycle AS b
    CROSS JOIN dbo.Station AS s
    WHERE r.RiderCode = 'R005' AND b.BikeCode = 'B102' AND s.StationCode = 'CENT';

    DECLARE @LastAuditID bigint = COALESCE((SELECT MAX(AuditID) FROM dbo.TripStatusAudit), 0);

    UPDATE dbo.Trip
    SET TripStatus = 'Cancelled', EndedAt = DATEADD(minute, 2, StartedAt)
    WHERE TripCode IN ('T012', 'LAB-TRIP') AND TripStatus = 'Open';

    SELECT TripCode, PreviousStatus, NewStatus
    FROM dbo.TripStatusAudit
    WHERE AuditID > @LastAuditID AND TripCode IN ('T012', 'LAB-TRIP')
    ORDER BY TripCode;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- The view, INSTEAD OF trigger, and example ticket exist only inside this transaction.
-- Each constant DDL string runs in its own batch.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    EXEC sys.sp_executesql N'
        CREATE VIEW dbo.vwRepairIntake
        AS
        SELECT r.RepairCode, b.BikeCode, r.OpenedOn, r.Issue
        FROM dbo.Repair AS r
        INNER JOIN dbo.Bicycle AS b ON b.BicycleID = r.BicycleID;
    ';

    EXEC sys.sp_executesql N'
        CREATE TRIGGER dbo.trg_RepairIntake_Insert
        ON dbo.vwRepairIntake
        INSTEAD OF INSERT
        AS
        BEGIN
            SET NOCOUNT ON;

            IF EXISTS (
                SELECT 1
                FROM inserted AS i
                WHERE NOT EXISTS (SELECT 1 FROM dbo.Bicycle AS b WHERE b.BikeCode = i.BikeCode)
            )
                THROW 50030, N''Every repair needs a known bicycle code.'', 1;

            INSERT INTO dbo.Repair (RepairCode, BicycleID, OpenedOn, Issue)
            SELECT i.RepairCode, b.BicycleID, i.OpenedOn, i.Issue
            FROM inserted AS i
            INNER JOIN dbo.Bicycle AS b ON b.BikeCode = i.BikeCode;
        END;
    ';

    DISABLE TRIGGER dbo.trg_RepairIntake_Insert ON dbo.vwRepairIntake;
    ENABLE TRIGGER dbo.trg_RepairIntake_Insert ON dbo.vwRepairIntake;

    EXEC sys.sp_executesql N'
        INSERT INTO dbo.vwRepairIntake (RepairCode, BikeCode, OpenedOn, Issue)
        VALUES (''LAB-NEW'', ''B106'', ''20260504'', N''Check headlight'');

        SELECT RepairCode, BikeCode, Issue
        FROM dbo.vwRepairIntake
        WHERE RepairCode = ''LAB-NEW'';
    ';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- A database-scoped DDL trigger reports CREATE TABLE events in this lab.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    EXEC sys.sp_executesql N'
        CREATE TRIGGER trg_ReportTableCreation
        ON DATABASE
        FOR CREATE_TABLE
        AS
        BEGIN
            SET NOCOUNT ON;

            DECLARE @Event xml = EVENTDATA();
            DECLARE @TableName sysname = @Event.value(''(/EVENT_INSTANCE/ObjectName)[1]'', ''sysname'');
            PRINT CONCAT(N''Created table '', @TableName);
        END;
    ';

    CREATE TABLE dbo.TutorialDDLProbe (ProbeID int NOT NULL);

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Cursor: print a station label per row.
DECLARE @StationCode varchar(8), @DockCapacity smallint;
DECLARE station_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT StationCode, DockCapacity
    FROM dbo.Station
    ORDER BY StationCode;

OPEN station_cursor;
FETCH NEXT FROM station_cursor INTO @StationCode, @DockCapacity;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT(@StationCode, N' has ', @DockCapacity, N' docks');
    FETCH NEXT FROM station_cursor INTO @StationCode, @DockCapacity;
END;

CLOSE station_cursor;
DEALLOCATE station_cursor;

-- Set-based query: return the same labels in a single result set.
SELECT CONCAT(StationCode, N' has ', DockCapacity, N' docks') AS StationLabel
FROM dbo.Station
ORDER BY StationCode;
GO
