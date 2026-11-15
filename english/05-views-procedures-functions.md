# 5. Views, procedures, and functions

[English course](../README.md) · [Previous lesson](04-data-changes-and-transactions.md) · [Next lesson](06-triggers-and-cursors.md)

Run [05-views-procedures-functions.sql](../sql/05-views-procedures-functions.sql) after setup. `CREATE OR ALTER` lets you rerun the object definitions. The trip update at the end rolls back its data change.

## Views

A regular view stores a query definition that you can select from. `dbo.vwCompletedTrips` combines trips with their station codes and exposes a calculated duration. This lets several reports reuse the same definition of a completed trip.

```sql
SELECT TripCode, ArrivalCode, DurationMinutes
FROM dbo.vwCompletedTrips
WHERE DepartureCode = 'CENT'
ORDER BY TripCode;
```

The four rows are `T001`, `T002`, `T005`, and `T009`. Sort in the calling query to control the displayed order.

## Stored procedures

Use a stored procedure for a named operation with inputs, outputs, and optionally data changes.

| Procedure | Try it |
| --- | --- |
| `dbo.usp_ListDepartures` | Call with no parameters for all 12 departures. Supply a station code and a half-open timestamp range to limit the result. The sample call returns `T003`. |
| `dbo.usp_CountOpenRepairs` | Pass a variable and include `OUTPUT` at the call site to receive the count of two. |
| `dbo.usp_CompleteTrip` | Provide the trip code, arrival station, end time, and fare. Run the sample transaction to see `T012` appear in the completed trips view before rollback. |

```sql
DECLARE @OpenCount int;
EXEC dbo.usp_CountOpenRepairs @OpenRepairs = @OpenCount OUTPUT;
SELECT @OpenCount AS OpenRepairs;
```

In the update procedure, input validation runs before the write. The `WHERE` clause applies the change only to an open trip whose start precedes the supplied end time. The check on `@@ROWCOUNT` gives the caller a clear error when the requested transition cannot happen. Other procedures perform read-only work and use `SET NOCOUNT ON` to suppress per-statement row-count messages.

## User-defined functions

| Function type | Example | How to call it |
| --- | --- | --- |
| Scalar | `ufn_FareInCents` returns one integer amount. Trip `T002` has a fare of 650 cents. | Invoke it in a `SELECT` expression. |
| Inline table-valued | `ufn_OpenRepairs` returns the open repairs for one bicycle type. Electric returns `RP002`. | Select from it in `FROM` as a table source. |
| Multi-statement table-valued | `ufn_StationTripSummary` populates a table variable with six station totals, including zero counts. | Select from it with the start and exclusive end date. |

Functions fit calculations and reusable query expressions. Stored procedures fit operations that change persistent data or expose output parameters. An inline table-valued function is often a good starting point when a single query can produce the result.

Use separate batches for `CREATE OR ALTER VIEW`, `PROCEDURE`, and `FUNCTION` definitions. In the scripts, `GO` ends each batch so the next definition starts a new one.
