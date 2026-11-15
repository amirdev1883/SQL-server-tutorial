# 7. Performance, permissions, and backups

[English course](../README.md) · [Previous lesson](06-triggers-and-cursors.md) · [Next lesson](08-practice.md)

Run [07-performance-and-administration.sql](../sql/07-performance-and-administration.sql) after [creating the views and procedures](05-views-procedures-functions.md). Running [the trigger lab](06-triggers-and-cursors.md) first also gives the metadata queries an audit trigger to inspect.

## Compare a query before and after indexing

The script creates 20,000 synthetic rows in `#TripSearch` using `GENERATE_SERIES`, which requires database compatibility level 160 or higher. A database created on a standard SQL Server 2022 instance uses level 160 by default. To check the lab's level, run:

```sql
SELECT name, compatibility_level
FROM sys.databases
WHERE name = N'BikeShareTutorialDB';
```

Enable **Include Actual Execution Plan** in SSMS or your client's equivalent. In the script, run both copies of the query and compare the **Messages** and plan outputs.

1. The first query reads the rows for Cedar Square on May 5 from the table before the index exists.
2. Create the composite index with `(DepartureCode, StartedAt)` as its keys and `Fare` as an included column.
3. Run the same query. Both result sets should have seven rows. Compare logical page reads, the access operators, and whether the plan needs a separate sort.

The query uses an equality match on the first key and a range on the second. A range on the original timestamp gives the optimizer a search argument for the index. An included column can satisfy the output without another lookup. Indexes also use space and add work to writes, so evaluate them against the queries that need them. Plan shapes and timings can vary with statistics, data distribution, and cache state. [Microsoft's index design guide](https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide)

## Inspect database metadata

The script uses catalog views to list objects, columns, indexes, constraints, and triggers. In the trip table, find the primary-key index, the unique index on `TripCode`, and the check constraint on trip status.

Use `OBJECT_DEFINITION`, `sys.sql_modules`, or `sp_helptext` to read a view's SQL definition when your permissions allow it. In the optional view demonstration, `WITH ENCRYPTION` obscures the saved definition from normal catalog queries. The table data stays readable through the view for authorized users.

## Give a reporting user access to one view

The role demonstration creates a database user `WITHOUT LOGIN`, a role, and a `SELECT` grant on `dbo.vwCompletedTrips`. Under `EXECUTE AS USER`, the reader can count 10 completed trips through the view and has no direct `SELECT` permission on the trip table. SQL Server uses the common owner of the view and the tables for this access check. `REVERT` restores the original identity and the lab rolls back the demo principals.

Database users represent identities inside a database. A role groups permissions that can be assigned to several database users. In this exercise, the role grants exactly the access the report needs.

## Back up and restore the practice database

Run [08-backup-and-verify.sql](../sql/08-backup-and-verify.sql) on a development instance where you have backup rights. It writes a uniquely named, copy-only full backup to the engine's default backup directory. The **BackupFile** result gives the full server-side path. `RESTORE VERIFYONLY` checks that the backup is readable and `RESTORE FILELISTONLY` lists the logical names to use during a restore.

To practice a full restore, use a fresh destination database name. Replace the backup path and both destination paths below with paths on your SQL Server host. The example uses Linux paths. Use the logical names shown by `FILELISTONLY` if they differ. The SQL Server service account needs access to the paths.

```sql
USE master;
GO

IF DB_ID(N'BikeShareTutorialRestore') IS NOT NULL
    THROW 50041, N'Choose an unused name for the restored database.', 1;

RESTORE DATABASE BikeShareTutorialRestore
FROM DISK = N'/var/opt/mssql/backup/BikeShareTutorialDB-example.bak'
WITH MOVE N'BikeShareTutorialDB' TO N'/var/opt/mssql/data/BikeShareTutorialRestore.mdf',
     MOVE N'BikeShareTutorialDB_log' TO N'/var/opt/mssql/data/BikeShareTutorialRestore_log.ldf',
     CHECKSUM, RECOVERY;
GO

SELECT COUNT(*) AS CompletedTrips
FROM BikeShareTutorialRestore.dbo.Trip
WHERE TripStatus = 'Completed';
```

The restored copy should return 10 completed trips from the starting dataset. Confirm that you can open the copy and run your practice reports before you treat the restore as complete. [Microsoft's backup and restore guide](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases)
