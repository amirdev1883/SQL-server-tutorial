# 8. Exercises and capstone

[English course](../README.md) · [Previous lesson](07-performance-and-administration.md) · [SQL solutions](../sql/09-practice-solutions.sql)

Run the exercises in `BikeShareTutorialDB` after setup. The checks below assume the starting data. Attempt each exercise, then compare your query with the solutions.

| Exercise | Task | Check your result |
| --- | --- | --- |
| 1. Highest fares | Return the three most expensive completed trips. Break equal fares by trip code. | `T009`, `T002`, `T004`, in that order. |
| 2. Repair queue | List open repairs and their age in calendar days on May 5, 2026. Label seven days or more `Review` and the rest `New`. | `RP002` is 13 days old and `RP003` is 3. |
| 3. Station counts | For May 1–4, return stations with two or more completed departures and their counts. Use an exclusive upper date boundary. | `CENT` has 4, `MUSE` has 2, and `PARK` has 3. |
| 4. Unused registrations | Return riders who have never started a trip of any status. | `R005` (Ada Chen) is the only result. |
| 5. Latest trip per rider | Return one most recent completed trip for every rider with a completed trip. Resolve any timestamp tie by trip ID. | Five rows. Nora Brooks (`R001`) maps to `T010`. |
| 6. Round trips | Find completed trips that arrived at their departure station. Include the station code. | `T006` at `PARK`. |
| 7. Transaction rehearsal | Insert an open repair ticket for bike `B106`, query it, roll back the transaction, and verify that the ticket is gone. | One matching row before rollback and zero after. |

## Capstone project

For trips started May 1–4, 2026, build a result with one row per station. Count only completed trips and attribute each fare to its departure station. Return the station code and name, departures, arrivals, departure fares, and net arrivals (arrivals minus departures).

A station without activity should still appear with zeros. A completed round trip contributes to both its station's departure and arrival counts. Aggregate arrivals and departures in separate CTEs before joining them to the station table.

| Station | Departures | Arrivals | Departure fares | Net arrivals |
| --- | ---: | ---: | ---: | ---: |
| `CENT` | 4 | 3 | 20.75 | -1 |
| `HILL` | 0 | 1 | 0.00 | 1 |
| `MUSE` | 2 | 2 | 6.75 | 0 |
| `NORTH` | 0 | 0 | 0.00 | 0 |
| `PARK` | 3 | 2 | 6.00 | -1 |
| `RIVR` | 1 | 2 | 6.50 | 1 |

Your report should sum to 10 departures, 10 arrivals, and 40.00 in fares. For an extension, turn the report into a stored procedure with start and exclusive end parameters. Call it for May 2 only and check that the departure and arrival totals both equal 3.
