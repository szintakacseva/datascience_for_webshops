/*extreme_sessiontimes.csv*/
SELECT clientid, status, COUNT(DISTINCT sessionid) NrOfsessions,
    COUNT(DISTINCT CASE WHEN date_diff('second', date_start,date_updated) >= 60000000 THEN sessionid END) long_count,  
    COUNT(DISTINCT CASE WHEN date_diff('second', date_start,date_updated) between 1000001 and 60000000 THEN sessionid END) tendays,
    COUNT(DISTINCT CASE WHEN date_diff('second', date_start,date_updated) between 450001 and 1000000  THEN sessionid END) fewdays,
    COUNT(DISTINCT CASE WHEN date_diff('second', date_start,date_updated)  between 50001 and 450000 THEN sessionid END) hours,
	COUNT(DISTINCT CASE WHEN date_diff('second', date_start,date_updated)  between 25001 and 50000 THEN sessionid END) _25_50000_sec,
	COUNT(DISTINCT CASE WHEN date_diff('second', date_start,date_updated)  <= 25000 THEN sessionid END) valid
FROM whale
GROUP BY clientid, status
order by clientid, status