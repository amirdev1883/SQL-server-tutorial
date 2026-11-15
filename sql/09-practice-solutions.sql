USE BikeShareTutorialDB;
GO

-- 1. Highest fares, with deterministic order for equal fares.
SELECT TOP (3) TripCode, Fare
FROM dbo.Trip
WHERE TripStatus = 'Completed'
ORDER BY Fare DESC, TripCode;

-- 2. Age of open repairs on May 5.
DECLARE @AsOf date = '20260505';

SELECT RepairCode, DATEDIFF(day, OpenedOn, @AsOf) AS DaysOpen,
       CASE WHEN DATEDIFF(day, OpenedOn, @AsOf) >= 7 THEN 'Review' ELSE 'New' END AS Queue
FROM dbo.Repair
WHERE ClosedOn IS NULL
ORDER BY DaysOpen DESC, RepairCode;

-- 3. Stations with at least two completed departures during the sample period.
SELECT s.StationCode, COUNT(*) AS CompletedDepartures
FROM dbo.Trip AS t
INNER JOIN dbo.Station AS s ON s.StationID = t.StartStationID
WHERE t.TripStatus = 'Completed'
  AND t.StartedAt >= '2026-05-01T00:00:00'
  AND t.StartedAt <  '2026-05-05T00:00:00'
GROUP BY s.StationCode
HAVING COUNT(*) >= 2
ORDER BY s.StationCode;

-- 4. Registered riders with no trips of any status.
SELECT r.RiderCode, r.RiderName
FROM dbo.Rider AS r
WHERE NOT EXISTS (SELECT 1 FROM dbo.Trip AS t WHERE t.RiderID = r.RiderID)
ORDER BY r.RiderCode;

-- 5. Most recent completed trip for each rider who has one.
WITH RiderTrips AS
(
    SELECT RiderID, TripCode,
           ROW_NUMBER() OVER (PARTITION BY RiderID ORDER BY StartedAt DESC, TripID DESC) AS rn
    FROM dbo.Trip
    WHERE TripStatus = 'Completed'
)
SELECT r.RiderCode, t.TripCode
FROM RiderTrips AS t
INNER JOIN dbo.Rider AS r ON r.RiderID = t.RiderID
WHERE t.rn = 1
ORDER BY r.RiderCode;

-- 6. Completed trips that ended at the station they departed from.
SELECT t.TripCode, s.StationCode
FROM dbo.Trip AS t
INNER JOIN dbo.Station AS s ON s.StationID = t.StartStationID
WHERE t.EndStationID = t.StartStationID
  AND t.TripStatus = 'Completed'
ORDER BY t.TripCode;
GO

-- 7. Preview a new repair, roll it back, and check the final row count.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Repair (RepairCode, BicycleID, OpenedOn, Issue)
    SELECT 'LAB-EX', BicycleID, '20260505', N'Inspect front tire'
    FROM dbo.Bicycle
    WHERE BikeCode = 'B106';

    IF @@ROWCOUNT <> 1
        THROW 50050, N'The exercise bicycle was not found.', 1;

    SELECT RepairCode, Issue, ClosedOn
    FROM dbo.Repair
    WHERE RepairCode = 'LAB-EX';

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT COUNT(*) AS RowsAfterRollback
FROM dbo.Repair
WHERE RepairCode = 'LAB-EX';
GO

-- 8. Capstone. Aggregate each station role before joining to the dimension.
WITH CompletedTrips AS
(
    SELECT StartStationID, EndStationID, Fare
    FROM dbo.Trip
    WHERE TripStatus = 'Completed'
      AND StartedAt >= '2026-05-01T00:00:00'
      AND StartedAt <  '2026-05-05T00:00:00'
),
Departures AS
(
    SELECT StartStationID, COUNT(*) AS TripCount, SUM(Fare) AS DepartureFares
    FROM CompletedTrips
    GROUP BY StartStationID
),
Arrivals AS
(
    SELECT EndStationID, COUNT(*) AS TripCount
    FROM CompletedTrips
    GROUP BY EndStationID
)
SELECT s.StationCode, s.StationName,
       COALESCE(d.TripCount, 0) AS Departures,
       COALESCE(a.TripCount, 0) AS Arrivals,
       COALESCE(d.DepartureFares, 0.00) AS DepartureFares,
       COALESCE(a.TripCount, 0) - COALESCE(d.TripCount, 0) AS NetArrivals
FROM dbo.Station AS s
LEFT JOIN Departures AS d ON d.StartStationID = s.StationID
LEFT JOIN Arrivals AS a ON a.EndStationID = s.StationID
ORDER BY s.StationCode;
GO
