WITH TotalPopulation AS (
    SELECT COUNT(J.OFFENDER) AS TotalCount
    FROM REP_JAILHOUSE J
    INNER JOIN REP_OFFENDERS O ON J.OFFENDER = O.OFFENDER
    WHERE
        J.OFFENDER IS NOT NULL
        AND J.FACILITY NOT IN ('OC', 'OJ')
		AND J.FACILITY = 'CFCF'
      
),
DateSecurityPopulation AS (
    SELECT
        CAST(J.LOADTIME AS DATE) AS [Date],
        J.SECURITY,
        COUNT(J.OFFENDER) AS Population
    FROM
        REP_JAILHOUSE J
        INNER JOIN REP_OFFENDERS O ON J.OFFENDER = O.OFFENDER
    WHERE
        J.OFFENDER IS NOT NULL
        AND J.FACILITY NOT IN ('OC', 'OJ')
		AND J.FACILITY = 'CFCF'
        
       
    GROUP BY
        CAST(J.LOADTIME AS DATE),
        J.SECURITY
)
SELECT
    D.[Date],
    D.SECURITY,
    D.Population AS POPULATION,
    (D.Population * 100.0 / T.TotalCount) AS PERCENTAGE
FROM
    DateSecurityPopulation D
    CROSS JOIN TotalPopulation T
ORDER BY
    D.Security,  -- Sort by sex
    D.[Date];  -- Sort by date if there are multiple dates for the same sex