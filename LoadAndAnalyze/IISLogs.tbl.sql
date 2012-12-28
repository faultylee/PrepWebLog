--DROP TABLE dbo.IISLogs
/*
CREATE TABLE dbo.IISLogs (
	requestDate datetime NULL,
	requestTime datetime NULL ,
	sService varchar (50) NULL ,
	sIP varchar (50) NULL ,
	csMethod varchar (50) NULL ,
	csUriStem varchar (2048) NULL ,
	csUriQuery varchar (2048) NULL ,
	sPort int,
	csUsername VArChar(255),
	cIP varchar (50) NULL ,
	csUserAgent varchar (1000) NULL ,
	scStatus int NULL ,
	scSubStatus int NULL ,
	scWin32Status bigint NULL
	)
*/

CREATE TABLE [dbo].[IISLogs](
	[requestDate] [datetime] NULL,
	[requestTime] [datetime] NULL,
	[sIP] [varchar](50) NULL,
	[csMethod] [varchar](50) NULL,
	[csUriStem] [varchar](2048) NULL,
	[csUriQuery] [varchar](2048) NULL,
	[sPort] [int] NULL,
	[csUsername] [varchar](255) NULL,
	[cIP] [varchar](50) NULL,
	[csUserAgent] [varchar](1000) NULL,
	[scStatus] [int] NULL,
	[scSubStatus] [int] NULL,
	[scWin32Status] [bigint] NULL,
	[timeTaken] [int] NULL
) ON [PRIMARY]

GO

ALTER TABLE IISLogs
REBUILD PARTITION = ALL WITH (DATA_COMPRESSION =  PAGE)

GO

/*
sp_spaceused IISLogs
	CREATE INDEX idx_IISLogs_sIP ON dbo.IISLogs(sIP) INCLUDE (csUriStem) WITH (FILLFACTOR=90)
	CREATE INDEX idx_IISLogs_RequestDate ON dbo.IISLogs(RequestDate) WITH (FILLFACTOR=90)

*/