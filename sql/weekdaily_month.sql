/*weekdaily_month.csv*/
SELECT clientid, currency,
count(*) CountOfAllInteractions,
count(distinct sessionid) CountOfSessions,
date_format(date_start, '%Y') as Year,
date_format(date_start, '%Y-%m') as Month,
date_format(date_start, '%W') as Weekday,
SUM(IF(status IN ('OS', 'OJ', 'OO'),1,0)) CountOfDirectSales,
ROUND(SUM(DISTINCT IF(status IN ('OS', 'OJ', 'OO'), cartvalue, 0))) ValueOfDirectSales,
ROUND(AVG(DISTINCT IF(status IN ('OS', 'OJ', 'OO'), cartvalue, 0))) AvgOfDirectSales,
SUM(IF(status IN ('AS', 'AJ', 'AO'),1,0)) CountOfAbandonments,
ROUND(SUM( DISTINCT IF(status IN ('AS', 'AJ', 'AO'), cartvalue, 0))) ValueOfAbandonments,
ROUND(AVG( DISTINCT IF(status IN ('AS', 'AJ', 'AO'), cartvalue, 0))) AvgOfAbandonments,
SUM(IF(status IN ('QS', 'QJ', 'QO'),1,0)) CountOfOnsiteRecoveries,
ROUND(SUM(DISTINCT IF(status IN ('QS', 'QJ', 'QO'), cartvalue, 0))) ValueOfOnsiteRecoveries,
ROUND(AVG(DISTINCT IF(status IN ('QS', 'QJ', 'QO'), cartvalue, 0))) AvgOfOnsiteRecoveries,
SUM(IF(length(eOpen) > 0 OR length(eClose) > 0,1,0)) CountOfOpen,
SUM(IF(length(eClose) > 0,1,0)) CountOfClose,
SUM(IF(eClose != 'btnCloseClicked' AND eClose != 'closeOverlayViaBackground' ,1,0)) CountOfPositiveClose,
SUM(IF(eClose = 'btnCloseClicked' OR eClose = 'closeOverlayViaBackground' ,1,0)) CountOfNegativeClose,
SUM(IF(length(eOpen) > 0 AND length(eClose) = 0,1,0)) CountOfMissingClose
FROM whale
GROUP BY clientid, Currency, date_format(date_start, '%Y'), date_format(date_start, '%Y-%m'),date_format(date_start, '%W')
ORDER BY clientid, Currency, Year, Month, Weekday