USE master;
GO

-- Optional lab. SQL Server writes this file to its own default backup folder.
DECLARE @Folder nvarchar(4000) = CONVERT(nvarchar(4000), SERVERPROPERTY('InstanceDefaultBackupPath'));

IF NULLIF(@Folder, N'') IS NULL
    THROW 50040, N'Configure a default backup folder on your development instance first.', 1;

DECLARE @Separator nchar(1) = CASE WHEN CHARINDEX(N'\', @Folder) > 0 THEN N'\' ELSE N'/' END;
DECLARE @BackupFile nvarchar(4000) = CONCAT(
    @Folder,
    CASE WHEN RIGHT(@Folder, 1) IN (N'\', N'/') THEN N'' ELSE @Separator END,
    N'BikeShareTutorialDB-', CONVERT(nvarchar(36), NEWID()), N'.bak'
);

SELECT @BackupFile AS BackupFile;

BACKUP DATABASE BikeShareTutorialDB
TO DISK = @BackupFile
WITH COPY_ONLY, CHECKSUM;

RESTORE VERIFYONLY
FROM DISK = @BackupFile
WITH CHECKSUM;

RESTORE FILELISTONLY FROM DISK = @BackupFile;
GO
