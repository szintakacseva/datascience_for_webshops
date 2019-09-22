/*average_json_per_minute.csv*/
SELECT clientid, sid, substr(sid, 14, 5) AS browserid,
round(truncate(max(delta))/60, 2) AS maxdelta,
count(sid) AS CountOfJsons,
COALESCE(TRY(round(count(sid)/round(truncate(max(delta))/60, 2), 2)), 0) as AvgNrOfJSONsPerMinute
FROM crab
WHERE length(clientid) > 4
AND   delta > 0
AND   delta is not null
AND   clientid <> 'null_'
AND   json_date_time is not null
AND   clientid in ('tmp_clientid')
GROUP BY clientid, sid
ORDER BY clientid, sid