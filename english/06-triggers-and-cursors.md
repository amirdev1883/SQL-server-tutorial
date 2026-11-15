# 6. Triggers and cursors

[English course](../README.md) · [Previous lesson](05-views-procedures-functions.md) · [Next lesson](07-performance-and-administration.md)

Run [06-triggers-and-cursors.sql](../sql/06-triggers-and-cursors.sql) in a fresh lab connection after setup. The audit table and audit trigger stay in the lab database. Sample edits, the intake view and its trigger, and the DDL trigger are rolled back.

## Audit a multi-row update

A DML trigger responds to a change statement. For an `UPDATE`, SQL Server provides old row values in `deleted` and new row values in `inserted`. Those pseudo-tables can contain multiple rows, even when the trigger fires once.

`dbo.trg_Trip_AuditStatus` joins `deleted` and `inserted` on `TripID` and writes a log row for each actual status change. Run the test to see `LAB-TRIP` and `T012` both move from `Open` to `Cancelled`. The trigger participates in the same transaction as the update, which also rolls back the two audit rows at the end.

## Route an insert through a view

An `INSTEAD OF INSERT` trigger handles the request sent to a view. The repair intake example accepts a public bike code, looks up the bicycle ID, and inserts a ticket into `dbo.Repair`. The test returns `LAB-NEW` for bike `B106`. The lab also shows `DISABLE TRIGGER` and `ENABLE TRIGGER` for that view.

Keep simple invariant checks in constraints. Use triggers when behavior must respond automatically to an operation, such as capturing a status change or translating writes made through a view.

## Inspect a schema change

A DDL trigger responds to schema activity. The database-scoped lab trigger runs on `CREATE_TABLE`, reads the object name from `EVENTDATA()`, and prints `Created table TutorialDDLProbe` in the client's messages. The transaction rolls back both the trigger and the probe table.

The intake and DDL labs execute constant definition strings with `sp_executesql` so each `CREATE` runs in its own batch while the surrounding transaction and error handler stay together.

## Compare a cursor with a set-based query

The cursor opens a sorted station result and fetches one row at a time. `@@FETCH_STATUS` controls the loop, `CLOSE` releases the active result, and `DEALLOCATE` removes the cursor. Check the messages for lines like `CENT has 24 docks`.

The set-based `SELECT` creates the same six labels in a single result grid. Use a set-based expression when you can describe the intended result for every row together. A cursor can fit a task that must call an operation separately for each row.
