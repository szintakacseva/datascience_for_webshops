/*ml_browsingcrab*/
SELECT 
SELECT 
      clientid,
      product_id AS productid,
      substr(sid, 14, 5) AS browserid,
      count(product_id) AS TotalNrOfBrowsing,
	  SUM(IF(date_diff('day', json_date_time, current_timestamp) < 20,1,0)) Past20DaysNrOfBrowsing
FROM crabtestsymd
WHERE length(clientid) > 4
AND   length(substr(sid, 14, 5)) > 0
AND   length(product_id) > 0
AND   clientid <> 'null_'
AND   json_date_time is not null
GROUP BY  clientid, product_id, substr(sid, 14, 5)
ORDER BY  clientid, TotalNrOfBrowsing desc