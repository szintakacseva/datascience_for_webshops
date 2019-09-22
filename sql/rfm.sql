/*rfm.csv*/
WITH 
rfm_sid AS 
    (
      SELECT 
         clientid,
         count(*) CountOfAllInteractions,
         count(distinct sid) CountOfSessions,
         sid,
         currency,
         sum(DISTINCT IF(status IN ('OS', 'OJ', 'OO', 'QS', 'QJ', 'QO', 'RS', 'RJ', 'RO'),1,0)) CountOfSales, 
         sum(DISTINCT IF(status IN ('OS', 'OJ', 'OO', 'QS', 'QJ', 'QO', 'RS', 'RJ', 'RO'), cartvalue, 0)) ValueOfSales,
         sum(DISTINCT IF(status IN ('AS', 'AJ', 'AO'),1,0)) CountOfAbandonments, 
         sum(DISTINCT IF(status IN ('AS', 'AJ', 'AO'), cartvalue, 0)) ValueOfAbandonments
    FROM whale
    WHERE clientid = '18947'
    AND sid is not null
    GROUP BY  clientid, sid, currency
    ),
rfm_browserid AS
(
  SELECT clientid,
  substr(sid, 14, 5) AS browserid,
  currency,
  sum(CountOfSales) CountOfSales,
  ROUND(AVG(ValueOfSales)) AvgValueOfSales,
  sum(CountOfAbandonments) CountOfAbandonments,
  ROUND(AVG(ValueOfAbandonments)) AvgValueOfAbandonments
FROM rfm_sid
WHERE clientid = '18947'
GROUP BY clientid, substr(sid, 14, 5), currency
  ),
rfm_lastorderdate AS
(
  SELECT clientid,
  substr(sid, 14, 5) AS browserid,
  currency,
  max(date_format(date_start, '%Y-%m-%d')) as LastOrderDate,
  max(date_format(date_start, '%Y-%m')) as LastOrderMonth,
  quarter(max(date_start)) as OrderQuarter,
  date_diff('day', max(date_start), current_timestamp) as NrOfDaysSinceLastOrder
FROM whale
WHERE clientid = '18947'
AND status in ('OS', 'OJ', 'OO', 'QS', 'QJ', 'QO', 'RS', 'RJ', 'RO')
GROUP BY clientid, substr(sid, 14, 5), currency
  ),
rfm_lastabandondate AS
(
  SELECT clientid,
  substr(sid, 14, 5) AS browserid,
  currency,
  max(date_format(date_start, '%Y-%m-%d')) as LastAbandonDate,
  max(date_format(date_start, '%Y-%m')) as LastAbandonMonth,
  quarter(max(date_start)) as AbandonQuarter,
  date_diff('day', max(date_start), current_timestamp) as NrOfDaysSinceLastAbandon
FROM whale
WHERE clientid = '18947'
AND status in ('AS', 'AJ', 'AO')
GROUP BY clientid, substr(sid, 14, 5), currency
  ),
rfm_all AS
(
SELECT b.clientid, b.browserid, b.currency, b.CountOfSales, b.AvgValueOfSales, b.CountOfAbandonments,
  b.AvgValueOfabandonments,
  l.LastOrderDate, l.LastOrderMonth, l.OrderQuarter, l.NrOfDaysSinceLastOrder,
  a.LastAbandonDate, a.LastAbandonMonth, a.AbandonQuarter, a.NrOfDaysSinceLastAbandon
FROM rfm_browserid b, rfm_lastorderdate l, rfm_lastabandondate a
WHERE b.browserid = l.browserid and a.browserid = b.browserid
)
select * from rfm_all