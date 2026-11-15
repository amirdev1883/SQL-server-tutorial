# SQL Server Tutorial

**English** · [فارسی](README.fa.md)

Learn Transact-SQL (T-SQL) on **SQL Server 2022 or later** by building and querying a city bike-share database. Start with tables and filters, then work up to trip reports, transaction-safe updates, and execution plans.

## Start here

1. Follow [setup and database design](english/01-setup-and-design.md) to install or connect to SQL Server.
2. Run [00-create-database.sql](sql/00-create-database.sql) and [01-build-bike-share.sql](sql/01-build-bike-share.sql) in that order. The second script creates and fills five related tables.
3. Run this query in the same SQL client. The sample data returns 10 completed trips and 40.00 in fares.

```sql
USE BikeShareTutorialDB;
GO

SELECT COUNT(*) AS CompletedTrips, SUM(Fare) AS TotalFares
FROM dbo.Trip
WHERE TripStatus = 'Completed';
```

## Lessons

| Lesson | What you will practice |
| --- | --- |
| [1. Setup and database design](english/01-setup-and-design.md) | Create and seed a database, choose data types, and enforce relationships with keys and constraints. |
| [2. Query fundamentals](english/02-query-fundamentals.md) | Read, filter, sort, and group rows. Work with dates, strings, and `NULL`. |
| [3. Joins and analysis](english/03-joins-and-analysis.md) | Join station and trip data, combine query results, and build reports with subqueries, CTEs, and window functions. |
| [4. Data changes and transactions](english/04-data-changes-and-transactions.md) | Insert, update, and delete rows. Preview changes and handle errors inside transactions. |
| [5. Views, procedures, and functions](english/05-views-procedures-functions.md) | Create reusable database objects with input parameters, output parameters, and scalar or table results. |
| [6. Triggers and cursors](english/06-triggers-and-cursors.md) | Audit updates that affect multiple rows and compare a cursor with a set-based query. |
| [7. Performance, permissions, and backups](english/07-performance-and-administration.md) | Measure an index, inspect metadata, grant access through a role, and verify a backup. |
| [8. Exercises and capstone](english/08-practice.md) | Write your own queries and build a station dashboard. Check your results against the solutions. |

The [Persian edition](README.fa.md) teaches SQL Server with a separate retail database. You can run both editions on the same development instance.
