-- Get counts of pages as defined by IIS
	SELECT csUriStem, Count(csUriStem) As PageCounter
	FROM IISLogs
	WHERE 
		csUriStem Not Like '/images/%'
		AND csUriStem Not Like '/App_Themes/%'
		AND csUriStem Not Like '%.gif'
		AND csUriStem Not Like '%.png'
		AND csUriStem Not Like '%.css'
		AND csUriStem Not Like '%.js'
		AND csUriStem Not Like '%.axd'
		AND csUriStem Not Like '%.ico'
	GROUP BY csUriStem
	ORDER BY Count(csUriStem) DESC

-- Get page hits per server based on IP
-- Looks pretty evenly spread
	SELECT sIP, Count(sIP) HitCounter
	FROM IISLogs
	GROUP BY sIP

-- Forbidden pages
	SELECT Count(*) FROM IISLogs WHERE scStatus = 403

-- Total row count, table size
	sp_spaceused IISLogs

-- Hits by date
	SELECT CAST(RequestDate As Date) RequestDate, Count(RequestDate) As RequestDateCounter
	FROM IISLogs
	GROUP BY CAST(RequestDate As Date)

-- Average Hits per day of week, Sunday = 1
	SELECT DatePart(dw,RequestDate),
	DateName(weekday, RequestDate),
	Avg(RequestDateCounter)
	FROM (
		SELECT CAST(RequestDate As Date) RequestDate, Count(RequestDate) As RequestDateCounter
		FROM IISLogs
		GROUP BY CAST(RequestDate As Date)
		) s
	GROUP BY DatePart(dw,RequestDate), DateName(weekday, RequestDate)
	ORDER BY DatePart(dw,RequestDate)

-- Hits by date and server
	SELECT CAST(RequestDate As Date) RequestDate, sIP, Count(RequestDate) As RequestDateCounter
	FROM IISLogs
	GROUP BY CAST(RequestDate As Date), sIP

-- Hits by browser
	SELECT Replace(csUserAgent,'+',' '), Count(csUserAgent)
	FROM IISLogs
	WHERE csUserAgent <> '-'
		--AND csUriStem Not Like '/images/%'
		--AND csUriStem Not Like '/App_Themes/%'
		--AND csUriStem Not Like '%.gif'
		--AND csUriStem Not Like '%.png'
		--AND csUriStem Not Like '%.css'
		--AND csUriStem Not Like '%.js'
		--AND csUriStem Not Like '%.axd'
		--AND csUriStem Not Like '%.ico'
	GROUP BY csUserAgent
	ORDER BY Count(csUserAgent) DESC
GO

-- Get hits by the minute
BEGIN
	DECLARE @StartDate DateTime
	SET @StartDate = '2012-09-27'
	DECLARE @dateOffset DateTime
	SET @dateOffset = GETDATE() - GETUTCDATE()
	SELECT 
		DateAdd(Minute,DateDiff(Minute,0,requestDate + @dateOffset),0) as CreateMinute,
		count(*)
	FROM IISLogs
	WHERE (requestDate + @dateOffset) > @StartDate
	GROUP BY DateAdd(Minute,DateDiff(Minute,0,requestDate + @dateOffset),0)
	ORDER BY CreateMinute
END
GO

-- Get hits by the minute excluding images and javascript
BEGIN
	DECLARE @StartDate DateTime
	SET @StartDate = '2012-09-27'
	DECLARE @dateOffset DateTime
	SET @dateOffset = GETDATE() - GETUTCDATE()
	SELECT 
		DateAdd(Minute,DateDiff(Minute,0,requestDate + @dateOffset),0) as CreateMinute,
		count(*)
	FROM IISLogs
	WHERE (requestDate + @dateOffset) > @StartDate
		AND csUriStem NOT Like '%jpg'
		AND csUriStem NOT Like '%png'
		AND csUriStem NOT Like '%gif'
		AND csUriStem NOT Like '%js'
		AND csUriStem NOT Like '%ico'
	GROUP BY DateAdd(Minute,DateDiff(Minute,0,requestDate + @dateOffset),0)
	ORDER BY CreateMinute
END
GO

-- Get hits by IP for a time period
BEGIN
	DECLARE @StartDate DateTime, @EndDate DateTime
	SELECT @StartDate = '2012-09-27 07:21:00',
		@EndDate = '2012-09-27 07:22:00'

	DECLARE @dateOffset DateTime
	SET @dateOffset = GETDATE() - GETUTCDATE()

	SELECT cIP, Count(cIP) as hitCount
	FROM IISLogs
	WHERE (requestDate + @dateOffset) BETWEEN @StartDate AND @EndDate
	GROUP BY cIP
	ORDER BY Count(cIP) DESC
END
GO

-- Get all info for a time period
BEGIN
	DECLARE @StartDate DateTime, @EndDate DateTime
	SELECT @StartDate = '2012-09-27 07:21:00',
		@EndDate = '2012-09-27 07:22:00'

	DECLARE @dateOffset DateTime
	SET @dateOffset = GETDATE() - GETUTCDATE()

	SELECT requestDate + @dateOffset as requestDateLocal,csMethod,csUriStem,csUriQuery,
		cIP,csUserAgent,scStatus,scSubStatus,scWin32Status,timeTaken
	FROM IISLogs
	WHERE (requestDate + @dateOffset) BETWEEN @StartDate AND @EndDate
	-- ORDER BY cIP --csUriStem
END
GO

-- Get csUriStem and count for a given time period
BEGIN
	DECLARE @StartDate DateTime, @EndDate DateTime
	SELECT @StartDate = '2012-09-27 07:21:00',
		@EndDate = '2012-09-27 07:22:00'

	DECLARE @dateOffset DateTime
	SET @dateOffset = GETDATE() - GETUTCDATE()

	SELECT right(csUriStem,3),Count(right(csUriStem,3))
	FROM IISLogs
	WHERE (requestDate + @dateOffset) BETWEEN @StartDate AND @EndDate
	GROUP BY right(csUriStem,3)
	ORDER BY Count(csUriStem) DESC
END
GO


