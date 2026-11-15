# 4. Data changes and transactions

[English course](../README.md) · [Previous lesson](03-joins-and-analysis.md) · [Next lesson](05-views-procedures-functions.md)

Run [04-data-changes-and-transactions.sql](../sql/04-data-changes-and-transactions.sql) in a fresh lab connection. Both demonstrations roll back their sample changes.

## Change and inspect rows

The first lab opens a repair ticket, closes it, and removes it.

1. **`INSERT`** uses an explicit column list and resolves the bicycle ID from its unique code.
2. **`UPDATE`** closes the ticket only while `ClosedOn IS NULL`. Preview the `WHERE` predicate with a `SELECT` before adapting this pattern for your own data.
3. **`DELETE`** removes the ticket with the matching code and a close date.

`OUTPUT inserted.ColumnName` exposes a new value and `OUTPUT deleted.ColumnName` exposes an old value. The lesson prints the old close date and new repair cost so you can inspect the effect of the update. Output rows describe the statement's work, while a later rollback can undo that work. Read `@@ROWCOUNT` immediately after the statement whose result you want to check, because later statements can reset it.

## Group related changes

In autocommit mode, each successful statement commits as its own transaction. Use an explicit transaction when multiple changes belong together. `COMMIT` makes the changes durable. `ROLLBACK` undoes them.

The second lab adds 5.00 to the existing repair `RP001` and then attempts to insert a duplicate repair code. SQL Server raises error **2627**. Inside `CATCH`, `XACT_STATE()` is **-1**, and the rollback restores the original cost of **14.00**.

- `SET XACT_ABORT ON` makes a runtime error such as that constraint violation invalidate the active transaction. The `CATCH` block explicitly rolls back when the state is nonzero.
- `XACT_STATE()` returns **1** for an active transaction that can commit, **-1** for one that must be rolled back, and **0** when there is no active transaction.
- Use `THROW;` inside `CATCH` to re-raise unexpected errors with their original details.

## Think about concurrent sessions

An explicit transaction gives related statements an all-or-nothing outcome. Its isolation level controls what other transactions can see and when they might wait. Under the default `READ COMMITTED` level, readers see committed data. SQL Server can implement that with locks or row versions depending on the database's `READ_COMMITTED_SNAPSHOT` setting.

Keep transactions short. To complete a ride, submit an `UPDATE` with `TripStatus = 'Open'` in the predicate and check the affected-row count. That protects the state transition if two callers try to complete the same ride. You'll see that pattern in the next lesson.
