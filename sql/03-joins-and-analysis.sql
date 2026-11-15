USE BikeShareTutorialDB;
GO

-- Give the two station roles distinct aliases. LEFT JOIN keeps unfinished trips.
SELECT t.TripCode, r.RiderName, b.BikeType,
       departure.StationName AS DepartedFrom, arrival.StationName AS ArrivedAt
FROM dbo.Trip AS t
INNER JOIN dbo.Rider AS r ON r.RiderID = t.RiderID
INNER JOIN dbo.Bicycle AS b ON b.BicycleID = t.BicycleID
INNER JOIN dbo.Station AS departure ON departure.StationID = t.StartStationID
LEFT JOIN dbo.Station AS arrival ON arrival.StationID = t.EndStationID
ORDER BY t.TripCode;

-- Keep every station, including stations without completed departures.
SELECT s.StationCode, COUNT(t.TripID) AS CompletedDepartures
FROM dbo.Station AS s
LEFT JOIN dbo.Trip AS t
    ON t.StartStationID = s.StationID
   AND t.TripStatus = 'Completed'
GROUP BY s.StationCode
ORDER BY CompletedDepartures DESC, s.StationCode;

-- Compare departure and arrival groups. Hilltop Library has arrivals only.
WITH Departures AS
(
    SELECT StartStationID AS StationID, COUNT(*) AS TripCount
    FROM dbo.Trip
    WHERE TripStatus = 'Completed'
    GROUP BY StartStationID
),
Arrivals AS
(
    SELECT EndStationID AS StationID, COUNT(*) AS TripCount
    FROM dbo.Trip
    WHERE TripStatus = 'Completed'
    GROUP BY EndStationID
)
SELECT s.StationCode, COALESCE(d.TripCount, 0) AS Departures, COALESCE(a.TripCount, 0) AS Arrivals
FROM Departures AS d
FULL OUTER JOIN Arrivals AS a ON a.StationID = d.StationID
INNER JOIN dbo.Station AS s ON s.StationID = COALESCE(d.StationID, a.StationID)
ORDER BY s.StationCode;

-- Generate a planning row for each combination of station and bicycle type.
SELECT s.StationCode, types.BikeType
FROM dbo.Station AS s
CROSS JOIN (VALUES ('Classic'), ('Electric')) AS types (BikeType)
ORDER BY s.StationCode, types.BikeType;

-- Self-join: list each pair of stations in the same district once.
SELECT a.District, a.StationCode AS StationA, b.StationCode AS StationB
FROM dbo.Station AS a
INNER JOIN dbo.Station AS b ON b.District = a.District AND b.StationCode > a.StationCode
ORDER BY a.District, a.StationCode, b.StationCode;

-- Scalar subquery: compare a trip with the overall average fare.
SELECT TripCode, Fare
FROM dbo.Trip
WHERE Fare > (SELECT AVG(Fare) FROM dbo.Trip WHERE TripStatus = 'Completed')
ORDER BY Fare DESC, TripCode;

-- Correlated subquery: find riders who have never started a trip.
SELECT r.RiderCode, r.RiderName
FROM dbo.Rider AS r
WHERE NOT EXISTS (SELECT 1 FROM dbo.Trip AS t WHERE t.RiderID = r.RiderID)
ORDER BY r.RiderCode;

-- UNION ALL keeps every event. A round trip records two events at one station.
SELECT t.StartStationID AS StationID, t.StartedAt AS EventTime, t.TripCode, 'Departure' AS EventType
FROM dbo.Trip AS t
WHERE t.TripStatus = 'Completed'
UNION ALL
SELECT t.EndStationID, t.EndedAt, t.TripCode, 'Arrival'
FROM dbo.Trip AS t
WHERE t.TripStatus = 'Completed'
ORDER BY EventTime, TripCode, EventType;

-- INTERSECT keeps stations in both sets. EXCEPT subtracts the second set.
SELECT StartStationID AS StationID
FROM dbo.Trip
WHERE TripStatus = 'Completed'
INTERSECT
SELECT EndStationID
FROM dbo.Trip
WHERE TripStatus = 'Completed'
ORDER BY StationID;

SELECT StationCode
FROM dbo.Station
EXCEPT
SELECT s.StationCode
FROM dbo.Station AS s
INNER JOIN dbo.Trip AS t ON t.StartStationID = s.StationID
ORDER BY StationCode;

-- A CTE lets the outer query filter on the row number calculated inside it.
WITH RankedTrips AS
(
    SELECT TripCode, StartStationID, StartedAt,
           ROW_NUMBER() OVER (PARTITION BY StartStationID ORDER BY StartedAt DESC, TripID DESC) AS rn
    FROM dbo.Trip
)
SELECT s.StationCode, t.TripCode, t.StartedAt
FROM RankedTrips AS t
INNER JOIN dbo.Station AS s ON s.StationID = t.StartStationID
WHERE t.rn = 1
ORDER BY s.StationCode;

-- Ties share a fare rank. The final ORDER BY makes the display stable.
SELECT TripCode, Fare, RANK() OVER (ORDER BY Fare DESC) AS FareRank
FROM dbo.Trip
WHERE TripStatus = 'Completed'
ORDER BY FareRank, TripCode;

-- ROWS advances the running total one row at a time. TripID breaks timestamp ties.
SELECT TripCode, StartedAt, Fare,
       SUM(Fare) OVER (ORDER BY StartedAt, TripID ROWS UNBOUNDED PRECEDING) AS RunningFares,
       LAG(StartedAt) OVER (PARTITION BY RiderID ORDER BY StartedAt, TripID) AS PreviousCompletedStart
FROM dbo.Trip
WHERE TripStatus = 'Completed'
ORDER BY StartedAt, TripID;

-- Store and reuse a small intermediate result within this connection.
DROP TABLE IF EXISTS #DailyFares;
SELECT CAST(StartedAt AS date) AS TripDay, SUM(Fare) AS Revenue
INTO #DailyFares
FROM dbo.Trip
WHERE TripStatus = 'Completed'
GROUP BY CAST(StartedAt AS date);

SELECT TripDay, Revenue
FROM #DailyFares
WHERE Revenue >= 10.00
ORDER BY TripDay;

DROP TABLE #DailyFares;
GO
