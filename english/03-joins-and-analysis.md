# 3. Joins and analysis

[English course](../README.md) · [Previous lesson](02-query-fundamentals.md) · [Next lesson](04-data-changes-and-transactions.md)

Run [03-joins-and-analysis.sql](../sql/03-joins-and-analysis.sql). Before each join, decide what one output row should represent and which rows you want to keep when a match is missing.

## Join tables

A trip has two station relationships. Give the station table a separate alias for each role. An inner join requires a departure station and a left join keeps the trip when its arrival station is missing.

```sql
SELECT t.TripCode, departure.StationName AS DepartedFrom, arrival.StationName AS ArrivedAt
FROM dbo.Trip AS t
INNER JOIN dbo.Station AS departure ON departure.StationID = t.StartStationID
LEFT JOIN dbo.Station AS arrival ON arrival.StationID = t.EndStationID
ORDER BY t.TripCode;
```

To count completed departures for every station, start from `Station` and left join `Trip`. Put `t.TripStatus = 'Completed'` in the join condition. This preserves Hilltop Library and North Market with counts of zero. Count `t.TripID` so the synthetic row with a missing trip contributes zero. Moving the status test into `WHERE` removes the rows with missing trips.

| Join | Example in the script |
| --- | --- |
| `INNER JOIN` | Look up each trip's rider and bicycle. |
| `LEFT JOIN` | Keep trips with missing arrival stations or stations with zero completed departures. A `RIGHT JOIN` preserves the right input and can be written as a left join by swapping inputs. |
| `FULL OUTER JOIN` | Combine stations that have completed departures, arrivals, or both. `HILL` has only an arrival. `NORTH` appears in neither input. |
| `CROSS JOIN` | Generate all 12 combinations of six station codes and two bicycle types. |
| Self-join | Find pairs of stations in the same district. An ordering condition keeps one row per pair. |

Joining two tables with several matches per key can multiply rows. For example, joining raw arrivals and departures at the same station can multiply both counts. Aggregate each side to one row per station before joining to produce a dashboard.

## Subqueries and set operations

- A scalar subquery supplies a single value. The script uses the overall average fare to find the four trips with fares above 4.00.
- A correlated `NOT EXISTS` subquery finds registered riders with zero trip records. Ada Chen (`R005`) is the only match. The subquery tests for rows and can safely express an anti-join when values on the other side may be missing.
- `UNION ALL` stacks compatible result sets and keeps duplicates. The arrivals and departures query returns 20 events from 10 completed trips. `UNION` removes duplicate output rows. `INTERSECT` returns common rows and `EXCEPT` returns rows in the first result absent from the second. The sample `EXCEPT` finds `HILL` and `NORTH` as stations without departures.

## CTEs, temporary tables, and windows

A common table expression (CTE) names a result within one statement. Use it to build a readable chain of steps. The latest-trip example assigns `ROW_NUMBER()` per departure station in a CTE and then keeps row number 1 in the outer query. If another statement precedes `WITH` in the batch, terminate the preceding statement with a semicolon.

A local temporary table stores intermediate rows for subsequent statements on the same connection. In the script, `#DailyFares` holds four daily totals and the next query returns the three days with at least 10.00 in fares. The script drops the temporary table before finishing.

Window functions calculate across related rows and keep the detail rows visible.

| Window expression | What to observe |
| --- | --- |
| `ROW_NUMBER()` | Sequential position within a station. The timestamp and trip ID together define a repeatable order. |
| `RANK()` | Equivalent fares share the same rank. Two trips with 6.50 both take rank 2 and the next fare is rank 4. |
| `SUM(Fare) OVER (ORDER BY StartedAt, TripID ROWS UNBOUNDED PRECEDING)` | The running total advances one row at a time and ends at 40.00. |
| `LAG(StartedAt) OVER (PARTITION BY RiderID ORDER BY StartedAt, TripID)` | Compare each completed trip with that rider's previous completed start. The first trip in each rider's group has a missing previous start. |
