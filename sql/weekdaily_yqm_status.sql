/*weekdaily_yqm_status.csv*/
SELECT clientid, currency,
status as detailed_status,
substr(status, 1, 1) as status,
count(distinct sessionid) CountOfSessions,
date_format(date_start, '%Y') as Year,
quarter(date_start) as Quarter,
date_format(date_start, '%Y-%m') as Month,
date_format(date_start, '%b') as AbrMonth,
date_format(date_start, '%M') as FullMonth,
date_format(date_start, '%W') as Weekday,
date_format(date_start, '%a') as AbrWeekday,
ROUND(AVG( DISTINCT IF(date_diff('second', date_start,date_updated) > 0, date_diff('second', date_start,date_updated), 0))) AvgSessionTime,
ROUND(MIN( DISTINCT IF(date_diff('second', date_start,date_updated) > 0, date_diff('second', date_start,date_updated), 0))) MinSessionTime,
ROUND(MAX( DISTINCT IF(date_diff('second', date_start,date_updated) > 0, date_diff('second', date_start,date_updated), 0))) MaxSessionTime
FROM whale
WHERE
date_diff('second', date_start,date_updated)  <= 25000
AND status IN ('OS', 'OJ', 'OO', 'AS', 'AJ', 'AO', 'QS', 'QJ', 'QO', 'RS', 'RJ', 'RO')
AND length(productid) > 0
GROUP BY clientid, currency, status, date_format(date_start, '%Y'), quarter(date_start), date_format(date_start, '%Y-%m'),
date_format(date_start, '%b'), date_format(date_start, '%M'), date_format(date_start, '%W'), date_format(date_start, '%a')
ORDER BY clientid, currency, status, Year, Quarter, Month, Weekday