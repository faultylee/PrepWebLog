/*
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO
*/

-- SET backup file location
-- All paths are relative to SQL Server running under the Service Account
DECLARE @LogFileLocation VarChar(520), @PrepWebLogPath VarChar(500)
SET @LogFileLocation = 'C:\Temp\LogFiles20120927\'
SET @PrepWebLogPath = 'C:\Temp\PrepWebLog.exe'

BEGIN
	IF object_id('tempdb..#LogFiles') IS NOT NULL
	BEGIN
		DROP TABLE #LogFiles
	END

	--DROP TABLE #LogFiles
	CREATE TABLE #LogFiles
		(
		icId Int Identity(1,1) PRIMARY KEY,
		LogFileName VarChar(255),
		PreppedLogFileName VarChar(255)
		)

-- Get list of backup files to work with from the specified folder
	INSERT INTO #LogFiles (LogFileName)
	EXEC('master.dbo.xp_cmdshell ''dir /B /A:-D ' + @LogFileLocation + '*.log''')
	DELETE #LogFiles WHERE LogFileName Is Null

	DELETE #LogFiles
	WHERE LogFileName Like 'Prepped%'

	UPDATE #LogFiles
	--SET PreppedLogFileName = LogFileName
	SET PreppedLogFileName = 'Prepped' + LogFileName

-- Run a cursor through the databases to restore them
	DECLARE @LogFileName VarChar(255), @PreppedLogFileName VarChar(255), @cmd Varchar(8000)

	DECLARE LogCursor CURSOR FAST_FORWARD FOR
	SELECT LogFileName, PreppedLogFileName FROM #LogFiles
	OPEN LogCursor
	FETCH NEXT FROM LogCursor INTO @LogFileName, @PreppedLogFileName
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		PRINT 'master.dbo.xp_cmdshell ''' + @PrepWebLogPath + ' ' + @LogFileLocation + @LogFileName + ' ' + @LogFileLocation + @PreppedLogFileName + ''''
		EXEC('master.dbo.xp_cmdshell ''' + @PrepWebLogPath + ' ' + @LogFileLocation + @LogFileName + ' ' + @LogFileLocation + @PreppedLogFileName + '''')

		-- Insert logs into table
		SET @cmd = 
			'BULK INSERT dbo.IISLogs FROM ''' + @LogFileLocation + @PreppedLogFileName + '''
			WITH ( 
				FIELDTERMINATOR = '' '',
				ROWTERMINATOR = ''\n''
				)'

		PRINT @cmd
 		EXEC (@cmd)

		FETCH NEXT FROM LogCursor INTO @LogFileName, @PreppedLogFileName
	END

	CLOSE LogCursor
	DEALLOCATE LogCursor

	DROP TABLE #LogFiles

END

/*
	UPDATE dbo.IISLogs SET RequestDate = RequestDate + RequestTime, RequestTime = Null WHERE RequestTime Is Not Null

	CREATE CLUSTERED INDEX idx_IISLogs_Clstd_DateTime ON dbo.IISLogs(RequestDate) WITH (FILLFACTOR=90)

	SELECT Count(*) FROM IISLogs WHERE RequestTime Is Not Null

	sp_spaceused IISLogs
*/


/*
SELECT * FROM #LogFiles

SELECT * FROM IISLogs
*/