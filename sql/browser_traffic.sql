WITH
    humpback_bt AS
    (SELECT *,
    IF( (    strpos(browserdesc, 'Android') > 0
         OR strpos(browserdesc, 'iPhone') > 0
		 OR strpos(browserdesc, 'iPad') > 0
         OR strpos(browserdesc, 'Mobile') > 0
		 OR strpos(browserdesc, 'BB') > 0
         OR strpos(browserdesc, 'BlackBerry') > 0
		 OR strpos(browserdesc, 'Nokia') > 0
         OR strpos(browserdesc, 'SAMSUNG') > 0
        ),'M','D') AS browsertype
    FROM humpback
    WHERE clientid in ('tmp_clientid')),
    browser_traffic_sid AS
    (SELECT
         clientid,
         currency,
         sessionid,
         browsertype,
         count(*) CountOfAllInteractions,
         count(distinct sessionid) CountOfSessions,
         date_format(date_start, '%Y-%m-%d') as Day,
         SUM(DISTINCT IF(status IN ('OS', 'OJ', 'OO'),1,0)) CountOfDirectSales,
         SUM(DISTINCT IF(status IN ('AS', 'AJ', 'AO'),1,0)) CountOfAbandonments,
         SUM(DISTINCT IF(status IN ('QS', 'QJ', 'QO'),1,0)) CountOfOnsiteRecoveries,
         SUM(DISTINCT IF(status IN ('RS', 'RJ', 'RO'),1,0)) CountOfEmails
     FROM humpback_bt
     WHERE clientid in ('tmp_clientid')
     AND date_diff('day', date_start, current_timestamp) <= 90
     GROUP BY  clientid, sessionid, currency, substr(status, 1, 1), date_format(date_start, '%Y-%m-%d'), browsertype
     ORDER BY  clientid, sessionid, currency, substr(status, 1, 1), Day ),
    browser_traffic AS
    (SELECT
         clientid,
         currency,
         browsertype,
         sum(CountOfAllInteractions) as CountOfAllInteractions,
         sum(CountOfSessions) AS CountOfSessions,
         Day,
         SUM(CountOfDirectSales) AS CountOfDirectSales,
         SUM(CountOfAbandonments) AS CountOfAbandonments,
         SUM(CountOfOnsiteRecoveries) AS CountOfOnsiteRecoveries,
         SUM(CountOfEmails) AS CountOfEmails
    FROM browser_traffic_sid
    GROUP BY  clientid, currency,  Day, browsertype
    ORDER BY  clientid, currency, Day, browsertype
    )
    SELECT * FROM browser_traffic;