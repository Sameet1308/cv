WITH DateRange AS (
    -- Generate a series of dates between today and the start of the year
    SELECT 
        CAST(DATEADD(DAY, -Number, GETDATE()) AS DATE) AS [Date]
    FROM master..spt_values
    WHERE [Type] = 'P' AND Number <= DATEDIFF(DAY, '2024-01-01', GETDATE())
),
DateFlags AS (
    -- Current Week (Dates from Saturday to Friday)
    SELECT 
        [Date], 
        'Current Week' AS [Flag]
    FROM DateRange
    WHERE DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE()) <= [Date] 
      AND [Date] <= DATEADD(DAY, 7 - DATEPART(WEEKDAY, GETDATE()), GETDATE())

    UNION ALL

    -- Current Month (Dates in the current month)
    SELECT 
        [Date], 
        'Current Month' AS [Flag]
    FROM DateRange
    WHERE DATEPART(MONTH, [Date]) = DATEPART(MONTH, GETDATE())
      AND DATEPART(YEAR, [Date]) = DATEPART(YEAR, GETDATE())

    UNION ALL

    -- Past 30 Days (Dates in the last 30 days)
    SELECT 
        [Date], 
        'Past 30 Days' AS [Flag]
    FROM DateRange
    WHERE [Date] BETWEEN DATEADD(DAY, -30, GETDATE()) AND GETDATE()

    UNION ALL

    -- Current True Week (Monday to Friday)
    SELECT 
        [Date], 
        'Current True Week' AS [Flag]
    FROM DateRange
    WHERE DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE()) <= [Date] 
      AND [Date] <= DATEADD(DAY, 5 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
      AND DATEPART(WEEKDAY, [Date]) BETWEEN 2 AND 6 -- Monday to Friday

    UNION ALL

    -- QTD (Quarter-to-Date)
    SELECT 
        [Date], 
        'QTD' AS [Flag]
    FROM DateRange
    WHERE [Date] >= DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE()), 0) 
      AND [Date] <= GETDATE()

    UNION ALL

    -- MTD (Month-to-Date)
    SELECT 
        [Date], 
        'MTD' AS [Flag]
    FROM DateRange
    WHERE [Date] >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) 
      AND [Date] <= GETDATE()

    UNION ALL

    -- YTD (Year-to-Date)
    SELECT 
        [Date], 
        'YTD' AS [Flag]
    FROM DateRange
    WHERE [Date] >= DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0) 
      AND [Date] <= GETDATE()
)
SELECT [Date], [Flag]
FROM DateFlags
ORDER BY [Flag], [Date];