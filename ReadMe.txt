Use IISLogs.tbl.sql to create the table to store your IIS Logs (standard W3C Format, custom formats will need the table definition modified)

Use InsertLogs.script.sql to process your log files, it will run PrepWebLog and do the bulk inserts. You will need to have command shell turned on in SQL Server (script to do this commented out at top of this file)
This will need a little work to get going on your system. All paths are relative to SQL Server. UNC paths are OK if the permissions are correct.
Make sure to put a backslash "\" at the end of folder paths.

AnalyzeIISLogs is some basic scripts I have that look for some generic info in the log files
	Hits per time period, hits per day of week, analysis into some of those.
