# 2. Query fundamentals

[English course](../README.md) · [Previous lesson](01-setup-and-design.md) · [Next lesson](03-joins-and-analysis.md)

Open [02-query-fundamentals.sql](../sql/02-query-fundamentals.sql) once setup is complete. Run the queries one at a time and predict the result before viewing the grid.

## Select and filter rows

`SELECT` chooses the columns to return, `FROM` names the source, and `WHERE` keeps rows whose condition is true. Qualify the table with `dbo` and use an alias when the result needs a different column name.

```sql
SELECT StationCode AS Code, StationName AS Station, DockCapacity
FROM dbo.Station
ORDER BY StationCode;
```

- Use `IN` for a list of allowed values and `LIKE N'Cedar%'` for names starting with Cedar. `%` matches any number of characters, and `_` matches one.
- `BETWEEN` includes both boundaries. Use parentheses to group conditions that mix `AND` and `OR`.
- `DISTINCT` removes repeated combinations of the selected columns. Selecting only `District` gives three rows in the sample.
- `ORDER BY` defines the result order. Use a unique tiebreaker along with `TOP` when you want a repeatable set of rows. The three highest fares appear as `T009`, `T002`, and `T004` when ties are ordered by trip code.

## Dates, values, and missing data

Use a half-open time range to include all of May 2, even if timestamps have fractional seconds.

```sql
SELECT TripCode, StartedAt
FROM dbo.Trip
WHERE StartedAt >= '2026-05-02T00:00:00'
  AND StartedAt <  '2026-05-03T00:00:00'
ORDER BY StartedAt, TripCode;
```

Expect `T004`, `T005`, and `T006`. With timestamps at identical times, the second sort column decides their display order.

| Expression | What to observe |
| --- | --- |
| `EndStationID IS NULL` | Cancelled trip `T007` and open trip `T012` have no arrival station. A comparison with `= NULL` yields unknown. |
| `CASE` and `COALESCE` | `CASE` chooses a label based on a condition. `COALESCE` substitutes the first available value, such as `Pending` for a missing end time in a display column. |
| `DATEDIFF(minute, StartedAt, EndedAt)` | The number of minute boundaries crossed. For the seed data, `T001` crosses 18. |
| `CONCAT`, `UPPER`, and `CAST` | Combine a rider code and name, uppercase membership, or convert a date to a midnight timestamp. |
| `TRY_CONVERT(date, …, 23)` | Returns a date for valid ISO date text and `NULL` for an invalid calendar date such as February 30. |

## Aggregate and group data

`COUNT(*)` counts all rows. `COUNT(Fare)`, `AVG(Fare)`, and `SUM(Fare)` use only the rows with a value in `Fare`. A zero fare is counted. With the full sample, the counts are 12 trips and 10 known fares. The sum is 40.00 and the average known fare is 4.00.

Use `WHERE` to filter rows, `GROUP BY` to choose the level of the report, and `HAVING` to filter the groups. The final query in the script reports dates with at least three completed trips. On the seed data, May 1 has three trips and 12.00 in fares, and May 2 has three trips and 10.50.

Try changing the minimum to two. How many dates qualify, and how does the total change?
