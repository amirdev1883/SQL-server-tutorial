USE BikeShareTutorialDB;
GO

-- Select columns and assign aliases.
SELECT StationCode AS Code, StationName AS Station, DockCapacity
FROM dbo.Station
ORDER BY StationCode;

-- Combine predicates. BETWEEN includes both endpoints.
SELECT StationCode, StationName, District, DockCapacity
FROM dbo.Station
WHERE District IN (N'Downtown', N'West')
  AND (DockCapacity BETWEEN 16 AND 20 OR StationName LIKE N'Cedar%')
ORDER BY DockCapacity DESC, StationCode;

-- Return each district once.
SELECT DISTINCT District
FROM dbo.Station
ORDER BY District;

-- TOP needs an ORDER BY to state which rows are wanted.
SELECT TOP (3) TripCode, Fare
FROM dbo.Trip
WHERE TripStatus = 'Completed'
ORDER BY Fare DESC, TripCode;

-- A half-open interval includes every timestamp on May 2.
SELECT TripCode, StartStationID, StartedAt
FROM dbo.Trip
WHERE StartedAt >= '2026-05-02T00:00:00'
  AND StartedAt <  '2026-05-03T00:00:00'
ORDER BY StartedAt, TripCode;

-- NULL marks an unrecorded end station here. The CASE handles both reasons.
SELECT TripCode,
       CASE WHEN TripStatus = 'Open' THEN 'In progress' ELSE 'Cancelled' END AS TripLabel,
       COALESCE(CONVERT(varchar(19), EndedAt, 126), 'Pending') AS EndedAtLabel
FROM dbo.Trip
WHERE EndStationID IS NULL
ORDER BY TripCode;

-- Calculate elapsed minute boundaries and create a rider display label.
SELECT TripCode, DATEDIFF(minute, StartedAt, EndedAt) AS Minutes
FROM dbo.Trip
WHERE TripStatus = 'Completed'
ORDER BY TripCode;

SELECT CONCAT(RiderCode, N' · ', RiderName) AS RiderLabel, UPPER(Membership) AS MembershipLabel,
       CAST(JoinedOn AS datetime2(0)) AS JoinedAtMidnight
FROM dbo.Rider
ORDER BY RiderCode;

-- TRY_CONVERT returns NULL if the text cannot be parsed as a date.
SELECT TRY_CONVERT(date, '2026-05-02', 23) AS AcceptedDate,
       TRY_CONVERT(date, '2026-02-30', 23) AS RejectedDate;

-- COUNT(*) counts rows. COUNT(Fare) counts the rows with a known fare.
SELECT COUNT(*) AS Trips, COUNT(Fare) AS TripsWithFare,
       SUM(Fare) AS TotalFares, AVG(Fare) AS AverageKnownFare,
       MIN(Fare) AS LowestKnownFare, MAX(Fare) AS HighestKnownFare
FROM dbo.Trip;

-- WHERE filters trips before grouping. HAVING filters the resulting groups.
SELECT CAST(StartedAt AS date) AS TripDay, COUNT(*) AS CompletedTrips, SUM(Fare) AS Fares
FROM dbo.Trip
WHERE TripStatus = 'Completed'
GROUP BY CAST(StartedAt AS date)
HAVING COUNT(*) >= 3
ORDER BY TripDay;
GO
