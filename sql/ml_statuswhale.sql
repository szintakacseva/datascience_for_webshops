/*ml_statuswhale*/
SELECT
clientid,
productid,
substr(sid, 14, 5) AS browserid,
SUM(IF(status IN ('OS', 'OJ', 'OO'),1,0)) CountOfDirectSales,
SUM(IF(status IN ('AS', 'AJ', 'AO'),1,0)) CountOfAbandonments,
SUM(IF(status IN ('QS', 'QJ', 'QO'),1,0)) CountOfOnsiteRecoveries,
SUM(IF(status IN ('OS', 'OJ', 'OO') and date_diff('day', date_start, current_timestamp) < 20,1,0)) Past20DaysCountOfDirectSales,
SUM(IF(status IN ('AS', 'AJ', 'AO') and date_diff('day', date_start, current_timestamp) < 20,1,0)) Past20DaysCountOfAbandonments,
SUM(IF(status IN ('QS', 'QJ', 'QO') and date_diff('day', date_start, current_timestamp) < 20,1,0)) Past20DaysCountOfOnsiteRecoveries
FROM whale
WHERE
      length(clientid) > 4
AND   length(substr(sid, 14, 5)) > 0
AND   length(productid) > 0
AND   date_start is not null
GROUP BY  clientid, productid, substr(sid, 14, 5) 
ORDER BY  clientid, productid, substr(sid, 14, 5)