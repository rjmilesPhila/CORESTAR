DECLARE @myDate AS DATETIME = '2024-08-01 00:00:00.000';

-- CTE to get the most recent MOVEIN date per offender
WITH RankedHousingChanges AS (
    SELECT 
        H.OFFENDER, 
        H.FACILITY, 
        H.MOVEIN,
        ROW_NUMBER() OVER (PARTITION BY H.OFFENDER ORDER BY H.MOVEIN DESC) AS rn
    FROM 
        REP_HOUSINGCHANGES H
    INNER JOIN
        REP_OFFENDERS O ON H.OFFENDER = O.OFFENDER
    INNER JOIN
        REP_ALIASES A ON H.OFFENDER = A.OFFENDER AND H.NAMETAG = A.NAMETAG
    WHERE 
        (H.MOVEIN <= @myDate) 
        AND (H.MOVEOUT >= '2024-07-31 00:00:00.000' OR H.MOVEOUT IS NULL)
        AND H.FACILITY NOT IN ('OC', 'OJ')
),

-- CTE to get total unique offenders based on the most recent MOVEIN date
TotalOffenders AS (
    SELECT 
        COUNT(DISTINCT OFFENDER) AS Total
    FROM 
        RankedHousingChanges
    WHERE 
        rn = 1
),

-- CTE to count offenders by facility based on the most recent MOVEIN date
FacilityCounts AS (
    SELECT 
        FACILITY AS FacilityName,
        COUNT(DISTINCT OFFENDER) AS CountByFacility
    FROM 
        RankedHousingChanges
    WHERE 
        rn = 1
    GROUP BY 
        FACILITY
)

-- Final SELECT to show facility counts and percentages
SELECT 
    FacilityName,
    CountByFacility,
    FORMAT((CountByFacility * 100.0 / Total.Total), '0.00') + '%' AS Percentage
FROM 
    FacilityCounts
CROSS JOIN
    TotalOffenders Total;
