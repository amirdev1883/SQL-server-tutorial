USE BikeShareTutorialDB;
GO

SET XACT_ABORT ON;

-- Rehearse creating, closing, and removing a lab repair ticket.
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Repair (RepairCode, BicycleID, OpenedOn, Issue)
    OUTPUT inserted.RepairCode, inserted.Issue
    SELECT 'LAB-RP', BicycleID, '20260505', N'Adjust rear derailleur'
    FROM dbo.Bicycle
    WHERE BikeCode = 'B103';

    IF @@ROWCOUNT <> 1
        THROW 50010, N'The bicycle for the lab repair was not found.', 1;

    UPDATE dbo.Repair
    SET ClosedOn = '20260506', RepairCost = 12.50
    OUTPUT deleted.ClosedOn AS WasClosedOn, inserted.ClosedOn, inserted.RepairCost
    WHERE RepairCode = 'LAB-RP' AND ClosedOn IS NULL;

    DELETE FROM dbo.Repair
    OUTPUT deleted.RepairCode AS RemovedRepair
    WHERE RepairCode = 'LAB-RP' AND ClosedOn IS NOT NULL;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- Demonstrate that an error in a later statement can undo an earlier update.
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Repair
    SET RepairCost = RepairCost + 5.00
    WHERE RepairCode = 'RP001';

    -- The unique repair code deliberately causes error 2627.
    INSERT INTO dbo.Repair (RepairCode, BicycleID, OpenedOn, Issue)
    SELECT 'RP001', BicycleID, '20260506', N'Duplicate ticket'
    FROM dbo.Repair
    WHERE RepairCode = 'RP001';

    ROLLBACK TRANSACTION;
    THROW 50011, N'The exercise expected a duplicate repair code.', 1;
END TRY
BEGIN CATCH
    DECLARE @TransactionState smallint = XACT_STATE();

    IF @TransactionState <> 0
        ROLLBACK TRANSACTION;

    IF ERROR_NUMBER() <> 2627
        THROW;

    SELECT ERROR_NUMBER() AS ExpectedError, @TransactionState AS StateBeforeRollback;
END CATCH;

SELECT RepairCode, RepairCost AS CostAfterRollback
FROM dbo.Repair
WHERE RepairCode = 'RP001';
GO
