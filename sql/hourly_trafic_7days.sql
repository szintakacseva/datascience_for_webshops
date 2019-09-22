/*hourly_trafic_7days.csv*/
WITH 
hourly_trafic_7days_sid AS 
    (SELECT 
     clientid,
     currency,
     sessionid,
         count(*) CountOfAllInteractions,
         count(distinct sessionid) CountOfSessions,
         date_format(date_start,'%H') AS Hour,
    SUM(DISTINCT IF(status IN ('OS', 'OJ', 'OO'),1,0)) CountOfDirectSales, 
    SUM(DISTINCT IF(status IN ('AS', 'AJ', 'AO'),1,0)) CountOfAbandonments, 
    SUM(DISTINCT IF(status IN ('QS', 'QJ', 'QO'),1,0)) CountOfOnsiteRecoveries, 
    SUM(DISTINCT IF(status IN ('RS', 'RJ', 'RO'),1,0)) CountOfEmails
    FROM whale
    WHERE clientid in ('tmp_clientid')
    AND date_diff('day', date_start, current_timestamp) <= 7
    GROUP BY  clientid, sessionid, currency, substr(status, 1, 1), date_format(date_start, '%H')
    ORDER BY  clientid, sessionid, currency, substr(status, 1, 1), Hour ),
hourly_trafic_7days AS 
    (SELECT 
         clientid,
         currency,
         sum(CountOfAllInteractions) as CountOfAllInteractions,
         sum(CountOfSessions) AS CountOfSessions,
         Hour, 
         SUM(CountOfDirectSales) AS CountOfDirectSales, 
         SUM(CountOfAbandonments) AS CountOfAbandonments, 
         SUM(CountOfOnsiteRecoveries) AS CountOfOnsiteRecoveries, 
         SUM(CountOfEmails) AS CountOfEmails
    FROM hourly_trafic_7days_sid 
    GROUP BY  clientid, currency,  Hour
    ORDER BY  clientid, currency, Hour 
    )
SELECT * FROM hourly_trafic_7days