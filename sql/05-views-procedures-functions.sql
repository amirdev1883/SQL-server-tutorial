USE BikeShareTutorialDB;
GO

-- A reusable read model for completed trips.
CREATE OR ALTER VIEW dbo.vwCompletedTrips
AS
SELECT t.TripCode, t.StartedAt, t.EndedAt, t.Fare,
       departure.StationCode AS DepartureCode, arrival.StationCode AS ArrivalCode,
       DATEDIFF(minute, t.StartedAt, t.EndedAt) AS DurationMinutes
FROM dbo.Trip AS t
INNER JOIN dbo.Station AS departure ON departure.StationID = t.StartStationID
INNER JOIN dbo.Station AS arrival ON arrival.StationID = t.EndStationID
WHERE t.TripStatus = 'Completed';
GO

-- Omitting a parameter leaves that filter open.
CREATE OR ALTER PROCEDURE dbo.usp_ListDepartures
    @StationCode varchar(8) = NULL,
    @From datetime2(0) = NULL,
    @Until datetime2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @From >= @Until
        THROW 50020, N'The start of the interval must precede its end.', 1;

    SELECT s.StationCode, t.TripCode, t.StartedAt, t.TripStatus
    FROM dbo.Trip AS t
    INNER JOIN dbo.Station AS s ON s.StationID = t.StartStationID
    WHERE (@StationCode IS NULL OR s.StationCode = @StationCode)
      AND (@From IS NULL OR t.StartedAt >= @From)
      AND (@Until IS NULL OR t.StartedAt < @Until)
    ORDER BY t.StartedAt, t.TripCode;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_CountOpenRepairs
    @OpenRepairs int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @OpenRepairs = COUNT(*)
    FROM dbo.Repair
    WHERE ClosedOn IS NULL;
END;
GO

-- One guarded UPDATE prevents a second caller from completing the same open trip.
CREATE OR ALTER PROCEDURE dbo.usp_CompleteTrip
    @TripCode varchar(8),
    @ArrivalCode varchar(8),
    @EndedAt datetime2(0),
    @Fare decimal(8, 2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @EndedAt IS NULL OR @Fare IS NULL OR @Fare < 0
        THROW 50021, N'An end time and a nonnegative fare are required.', 1;

    DECLARE @ArrivalID int = (
        SELECT StationID
        FROM dbo.Station
        WHERE StationCode = @ArrivalCode
    );

    IF @ArrivalID IS NULL
        THROW 50022, N'The arrival station was not found.', 1;

    UPDATE dbo.Trip
    SET TripStatus = 'Completed', EndStationID = @ArrivalID, EndedAt = @EndedAt, Fare = @Fare
    WHERE TripCode = @TripCode
      AND TripStatus = 'Open'
      AND StartedAt < @EndedAt;

    IF @@ROWCOUNT <> 1
        THROW 50023, N'An open trip with a start before the supplied end time was not found.', 1;
END;
GO

-- Scalar UDF: decimal currency to integer cents.
CREATE OR ALTER FUNCTION dbo.ufn_FareInCents(@Fare decimal(8, 2))
RETURNS int
AS
BEGIN
    RETURN CONVERT(int, @Fare * 100);
END;
GO

-- Inline table-valued function: return a query as a parameterized table expression.
CREATE OR ALTER FUNCTION dbo.ufn_OpenRepairs(@BikeType varchar(10))
RETURNS TABLE
AS
RETURN
(
    SELECT b.BikeCode, r.RepairCode, r.OpenedOn, r.Issue
    FROM dbo.Repair AS r
    INNER JOIN dbo.Bicycle AS b ON b.BicycleID = r.BicycleID
    WHERE b.BikeType = @BikeType AND r.ClosedOn IS NULL
);
GO

-- Multi-statement table-valued function: populate and return a table variable.
CREATE OR ALTER FUNCTION dbo.ufn_StationTripSummary
(
    @From date,
    @Until date
)
RETURNS @Summary TABLE
(
    StationCode varchar(8) PRIMARY KEY,
    CompletedTrips int NOT NULL,
    TotalFares decimal(38, 2) NOT NULL
)
AS
BEGIN
    INSERT INTO @Summary (StationCode, CompletedTrips, TotalFares)
    SELECT s.StationCode, COUNT(t.TripID), COALESCE(SUM(t.Fare), 0)
    FROM dbo.Station AS s
    LEFT JOIN dbo.Trip AS t
        ON t.StartStationID = s.StationID
       AND t.TripStatus = 'Completed'
       AND t.StartedAt >= @From
       AND t.StartedAt < @Until
    GROUP BY s.StationCode;

    RETURN;
END;
GO

SELECT TripCode, ArrivalCode, DurationMinutes
FROM dbo.vwCompletedTrips
WHERE DepartureCode = 'CENT'
ORDER BY TripCode;

EXEC dbo.usp_ListDepartures;
EXEC dbo.usp_ListDepartures @StationCode = 'MUSE', @From = '2026-05-01T00:00:00',
    @Until = '2026-05-04T00:00:00';

DECLARE @Count int;
EXEC dbo.usp_CountOpenRepairs @OpenRepairs = @Count OUTPUT;
SELECT @Count AS OpenRepairs;

SELECT TripCode, dbo.ufn_FareInCents(Fare) AS FareInCents
FROM dbo.vwCompletedTrips
WHERE TripCode = 'T002';

SELECT BikeCode, RepairCode, OpenedOn, Issue
FROM dbo.ufn_OpenRepairs('Electric')
ORDER BY BikeCode, RepairCode;

SELECT StationCode, CompletedTrips, TotalFares
FROM dbo.ufn_StationTripSummary('20260501', '20260505')
ORDER BY StationCode;

SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    EXEC dbo.usp_CompleteTrip @TripCode = 'T012', @ArrivalCode = 'RIVR',
        @EndedAt = '2026-05-04T13:25:00', @Fare = 5.50;

    SELECT TripCode, DepartureCode, ArrivalCode, Fare
    FROM dbo.vwCompletedTrips
    WHERE TripCode = 'T012';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
