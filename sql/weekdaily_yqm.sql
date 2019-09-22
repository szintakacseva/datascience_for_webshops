/*weekdaily_yqm.csv*/
SELECT clientid, currency,
count(distinct sessionid) CountOfSessions,
date_format(date_start, '%Y') as Year,
quarter(date_start) as Quarter,
date_format(date_start, '%Y-%m') as Month,
date_format(date_start, '%b') as AbrMonth,
date_format(date_start, '%M') as FullMonth,
date_format(date_start, '%W') as Weekday,
date_format(date_start, '%a') as AbrWeekday,
SUM(IF(status IN ('OS', 'OJ', 'OO'),1,0)) CountOfDirectSales,
ROUND(SUM(DISTINCT IF(status IN ('OS', 'OJ', 'OO'), cartvalue, 0))) ValueOfDirectSales,
SUM(IF(status IN ('AS', 'AJ', 'AO'),1,0)) CountOfAbandonments,
ROUND(SUM( DISTINCT IF(status IN ('AS', 'AJ', 'AO'), cartvalue, 0))) ValueOfAbandonments,
SUM(IF(status IN ('QS', 'QJ', 'QO'),1,0)) CountOfOnsiteRecoveries,
ROUND(SUM(DISTINCT IF(status IN ('QS', 'QJ', 'QO'), cartvalue, 0))) ValueOfOnsiteRecoveries,
SUM(IF(length(eOpen) > 0 OR length(eClose) > 0,1,0)) CountOfOpen,
SUM(IF(length(eClose) > 0,1,0)) CountOfClose,
SUM(IF(eClose != 'btnCloseClicked' AND eClose != 'closeOverlayViaBackground' ,1,0)) CountOfPositiveClose,
SUM(IF(eClose = 'btnCloseClicked' OR eClose = 'closeOverlayViaBackground' ,1,0)) CountOfNegativeClose,
SUM(IF(length(eOpen) > 0 AND length(eClose) = 0,1,0)) CountOfMissingClose
FROM whale
WHERE sessiontime > 300 AND sessiontime < 450000
GROUP BY clientid, Currency, date_format(date_start, '%Y'), quarter(date_start), date_format(date_start, '%Y-%m'),
date_format(date_start, '%b'), date_format(date_start, '%M'), date_format(date_start, '%W'), date_format(date_start, '%a')
ORDER BY clientid, Currency, Year, Quarter, Month, Weekday