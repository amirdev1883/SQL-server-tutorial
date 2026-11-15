USE BikeShareTutorialDB;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ExistingLabTables int = (
    SELECT COUNT(*)
    FROM sys.tables
    WHERE schema_id = SCHEMA_ID(N'dbo')
      AND name IN (N'Station', N'Bicycle', N'Rider', N'Trip', N'Repair')
);

IF @ExistingLabTables = 5
BEGIN
    PRINT N'The bike-share tables already exist. Existing rows were left in place.';
    RETURN;
END;

IF @ExistingLabTables > 0
    THROW 50000, N'Only some bike-share tables exist. Start with an empty lab database.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    CREATE TABLE dbo.Station
    (
        StationID int IDENTITY(1, 1) CONSTRAINT PK_Station PRIMARY KEY,
        StationCode varchar(8) NOT NULL CONSTRAINT UQ_Station_Code UNIQUE,
        StationName nvarchar(80) NOT NULL,
        District nvarchar(40) NOT NULL,
        DockCapacity smallint NOT NULL,
        CONSTRAINT CK_Station_DockCapacity CHECK (DockCapacity > 0)
    );

    CREATE TABLE dbo.Bicycle
    (
        BicycleID int IDENTITY(1, 1) CONSTRAINT PK_Bicycle PRIMARY KEY,
        BikeCode varchar(8) NOT NULL CONSTRAINT UQ_Bicycle_Code UNIQUE,
        BikeType varchar(10) NOT NULL,
        CommissionedOn date NOT NULL,
        IsActive bit NOT NULL CONSTRAINT DF_Bicycle_IsActive DEFAULT (1),
        CONSTRAINT CK_Bicycle_BikeType CHECK (BikeType IN ('Classic', 'Electric'))
    );

    CREATE TABLE dbo.Rider
    (
        RiderID int IDENTITY(1, 1) CONSTRAINT PK_Rider PRIMARY KEY,
        RiderCode varchar(8) NOT NULL CONSTRAINT UQ_Rider_Code UNIQUE,
        RiderName nvarchar(80) NOT NULL,
        Membership varchar(10) NOT NULL CONSTRAINT DF_Rider_Membership DEFAULT ('DayPass'),
        JoinedOn date NOT NULL,
        CONSTRAINT CK_Rider_Membership CHECK (Membership IN ('Member', 'DayPass'))
    );

    CREATE TABLE dbo.Trip
    (
        TripID int IDENTITY(1, 1) CONSTRAINT PK_Trip PRIMARY KEY,
        TripCode varchar(8) NOT NULL CONSTRAINT UQ_Trip_Code UNIQUE,
        RiderID int NOT NULL CONSTRAINT FK_Trip_Rider REFERENCES dbo.Rider (RiderID),
        BicycleID int NOT NULL CONSTRAINT FK_Trip_Bicycle REFERENCES dbo.Bicycle (BicycleID),
        StartStationID int NOT NULL CONSTRAINT FK_Trip_StartStation REFERENCES dbo.Station (StationID),
        EndStationID int NULL CONSTRAINT FK_Trip_EndStation REFERENCES dbo.Station (StationID),
        StartedAt datetime2(0) NOT NULL,
        EndedAt datetime2(0) NULL,
        TripStatus varchar(12) NOT NULL CONSTRAINT DF_Trip_Status DEFAULT ('Open'),
        Fare decimal(8, 2) NULL,
        CONSTRAINT CK_Trip_Completion CHECK (
            (TripStatus = 'Open' AND EndStationID IS NULL AND EndedAt IS NULL AND Fare IS NULL)
            OR (TripStatus = 'Completed' AND EndStationID IS NOT NULL
                AND EndedAt IS NOT NULL AND EndedAt > StartedAt AND Fare IS NOT NULL AND Fare >= 0)
            OR (TripStatus = 'Cancelled' AND EndStationID IS NULL
                AND EndedAt IS NOT NULL AND EndedAt >= StartedAt AND Fare IS NULL)
        )
    );

    CREATE TABLE dbo.Repair
    (
        RepairID int IDENTITY(1, 1) CONSTRAINT PK_Repair PRIMARY KEY,
        RepairCode varchar(8) NOT NULL CONSTRAINT UQ_Repair_Code UNIQUE,
        BicycleID int NOT NULL CONSTRAINT FK_Repair_Bicycle REFERENCES dbo.Bicycle (BicycleID),
        OpenedOn date NOT NULL,
        ClosedOn date NULL,
        Issue nvarchar(120) NOT NULL,
        RepairCost decimal(8, 2) NULL,
        CONSTRAINT CK_Repair_Closure CHECK (
            (ClosedOn IS NULL AND RepairCost IS NULL)
            OR (ClosedOn IS NOT NULL AND ClosedOn >= OpenedOn
                AND RepairCost IS NOT NULL AND RepairCost >= 0)
        )
    );

    INSERT INTO dbo.Station (StationCode, StationName, District, DockCapacity)
    VALUES
        ('CENT', N'Cedar Square', N'Downtown', 24),
        ('MUSE', N'Makers Museum', N'Downtown', 18),
        ('RIVR', N'Riverside Trail', N'West', 16),
        ('PARK', N'Orchard Park', N'West', 20),
        ('HILL', N'Hilltop Library', N'North', 12),
        ('NORTH', N'North Market', N'North', 14);

    INSERT INTO dbo.Bicycle (BikeCode, BikeType, CommissionedOn, IsActive)
    VALUES
        ('B101', 'Classic', '20250801', 1),
        ('B102', 'Electric', '20250910', 1),
        ('B103', 'Classic', '20250801', 1),
        ('B104', 'Electric', '20251004', 1),
        ('B105', 'Classic', '20250619', 0),
        ('B106', 'Electric', '20260415', 1);

    INSERT INTO dbo.Rider (RiderCode, RiderName, Membership, JoinedOn)
    VALUES
        ('R001', N'Nora Brooks', 'Member', '20260320'),
        ('R002', N'Malik Reed', 'DayPass', '20260430'),
        ('R003', N'Lena Park', 'Member', '20260407'),
        ('R004', N'Theo Grant', 'DayPass', '20260502'),
        ('R005', N'Ada Chen', 'Member', '20260427'),
        ('R006', N'Jonah Price', 'DayPass', '20260502');

    -- Resolve foreign keys by code so the seed does not depend on identity values.
    INSERT INTO dbo.Trip
        (TripCode, RiderID, BicycleID, StartStationID, EndStationID, StartedAt, EndedAt, TripStatus, Fare)
    SELECT sample.TripCode, r.RiderID, b.BicycleID, start_station.StationID, end_station.StationID,
           sample.StartedAt, sample.EndedAt, sample.TripStatus, sample.Fare
    FROM (VALUES
        ('T001', 'R001', 'B101', 'CENT', 'MUSE', '2026-05-01T08:00:00', '2026-05-01T08:18:00', 'Completed', 3.00),
        ('T002', 'R002', 'B102', 'CENT', 'RIVR', '2026-05-01T08:20:00', '2026-05-01T08:45:00', 'Completed', 6.50),
        ('T003', 'R003', 'B103', 'MUSE', 'CENT', '2026-05-01T09:00:00', '2026-05-01T09:14:00', 'Completed', 2.50),
        ('T004', 'R004', 'B104', 'RIVR', 'CENT', '2026-05-02T09:15:00', '2026-05-02T09:42:00', 'Completed', 6.50),
        ('T005', 'R001', 'B101', 'CENT', 'PARK', '2026-05-02T12:00:00', '2026-05-02T12:30:00', 'Completed', 4.00),
        ('T006', 'R006', 'B103', 'PARK', 'PARK', '2026-05-02T12:00:00', '2026-05-02T12:22:00', 'Completed', 0.00),
        ('T007', 'R002', 'B102', 'RIVR', NULL, '2026-05-03T10:00:00', '2026-05-03T10:03:00', 'Cancelled', NULL),
        ('T008', 'R003', 'B103', 'PARK', 'MUSE', '2026-05-03T11:00:00', '2026-05-03T11:20:00', 'Completed', 3.00),
        ('T009', 'R004', 'B104', 'CENT', 'HILL', '2026-05-03T15:00:00', '2026-05-03T15:35:00', 'Completed', 7.25),
        ('T010', 'R001', 'B101', 'PARK', 'CENT', '2026-05-04T08:30:00', '2026-05-04T08:55:00', 'Completed', 3.00),
        ('T011', 'R006', 'B103', 'MUSE', 'RIVR', '2026-05-04T11:15:00', '2026-05-04T11:42:00', 'Completed', 4.25),
        ('T012', 'R002', 'B106', 'MUSE', NULL, '2026-05-04T13:00:00', NULL, 'Open', NULL)
    ) AS sample (TripCode, RiderCode, BikeCode, StartCode, EndCode, StartedAt, EndedAt, TripStatus, Fare)
    INNER JOIN dbo.Rider AS r ON r.RiderCode = sample.RiderCode
    INNER JOIN dbo.Bicycle AS b ON b.BikeCode = sample.BikeCode
    INNER JOIN dbo.Station AS start_station ON start_station.StationCode = sample.StartCode
    LEFT JOIN dbo.Station AS end_station ON end_station.StationCode = sample.EndCode;

    INSERT INTO dbo.Repair (RepairCode, BicycleID, OpenedOn, ClosedOn, Issue, RepairCost)
    SELECT sample.RepairCode, b.BicycleID, sample.OpenedOn, sample.ClosedOn, sample.Issue, sample.RepairCost
    FROM (VALUES
        ('RP001', 'B102', '20260414', '20260416', N'Brake adjustment', 14.00),
        ('RP002', 'B104', '20260422', NULL, N'Battery diagnostics', NULL),
        ('RP003', 'B105', '20260502', NULL, N'Frame inspection', NULL),
        ('RP004', 'B101', '20260412', '20260412', N'Light replacement', 8.00)
    ) AS sample (RepairCode, BikeCode, OpenedOn, ClosedOn, Issue, RepairCost)
    INNER JOIN dbo.Bicycle AS b ON b.BikeCode = sample.BikeCode;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT TripStatus, COUNT(*) AS TripCount
FROM dbo.Trip
GROUP BY TripStatus
ORDER BY TripStatus;
GO
