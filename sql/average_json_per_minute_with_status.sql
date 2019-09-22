/*average_json_per_minute_with_status.csv*/
SELECT
c.clientid,
c.sid,
substr(c.sid, 14, 5) AS browserid,
round(truncate(max(c.delta))/60, 2) AS maxdelta,
count(c.sid) AS CountOfJsons,
COALESCE(TRY(round(count(c.sid)/round(truncate(max(c.delta))/60, 2), 2)), 0) as AvgNrOfJSONsPerMinute,
substr(status, 1, 1) as status
FROM crab c, whale w
WHERE c.sid = w.sid
AND   length(c.clientid) > 4
AND   c.delta > 0
AND   c.clientid <> 'null_'
AND   c.json_date_time is not null
AND   c.clientid in ('tmp_clientid')
AND   w.status IN ('OS', 'OJ', 'OO', 'AS', 'AJ', 'AO', 'QS', 'QJ', 'QO', 'RS', 'RJ', 'RO')
GROUP BY c.clientid, c.sid, w.status
ORDER BY c.clientid, c.sid, w.status