/*kpi.csv*/
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
         sum(DISTINCT IF(status IN ('AS', 'AJ', 'AO'),1,0)) CountOfAbandons,
         sum(DISTINCT IF(status IN ('AS', 'AJ', 'AO'), cartvalue, 0)) ValueOfAbandons
    FROM whale
    WHERE clientid in ('tmp_clientid')
    AND sid is not null
    GROUP BY  clientid, currency, sid
    ),
    rfm_browserid AS
   (
   SELECT clientid,
     substr(sid, 14, 5) AS browserid,
     currency,
     sum(CountOfSessions) CountOfSessions,
     sum(CountOfSales) CountOfSales,
     ROUND(AVG(ValueOfSales)) AOV,
     sum(CountOfAbandons) CountOfAbandons,
     ROUND(AVG(ValueOfAbandons)) AAV
   FROM rfm_sid
   WHERE clientid in ('tmp_clientid')
   GROUP BY clientid, currency, substr(sid, 14, 5)
     ),
   rfm_lastorderdate AS
   (
   SELECT clientid,
   substr(sid, 14, 5) AS browserid,
   currency,
   max(date_format(date_start, '%Y-%m-%d')) as LastOrderDate,
   max(date_format(date_start, '%Y-%m')) as LastOrderMonth,
   concat(date_format(max(date_start), '%Y'),  '-', cast(quarter(max(date_start)) as varchar)) as OrderQuarter,
   date_diff('day', max(date_start), current_timestamp) as NrOfDaysSinceLastOrder
   FROM whale
   WHERE clientid in ('tmp_clientid')
   AND status in ('OS', 'OJ', 'OO', 'QS', 'QJ', 'QO', 'RS', 'RJ', 'RO')
   GROUP BY clientid, currency, substr(sid, 14, 5)
   ),
   rfm_lastabandondate AS
   (
   SELECT clientid,
   substr(sid, 14, 5) AS browserid,
   currency,
   max(date_format(date_start, '%Y-%m-%d')) as LastAbandonDate,
   max(date_format(date_start, '%Y-%m')) as LastAbandonMonth,
   concat(date_format(max(date_start), '%Y'), '-', cast(quarter(max(date_start)) as varchar)) as AbandonQuarter,
   date_diff('day', max(date_start), current_timestamp) as NrOfDaysSinceLastAbandon
   FROM whale
   WHERE clientid in ('tmp_clientid')
   AND status in ('AS', 'AJ', 'AO')
   GROUP BY clientid, currency, substr(sid, 14, 5)
   ),
   rfm_all AS
   (
   SELECT b.*,
   round(cast(b.CountOfAbandons as double)/cast(b.CountOfSessions as double),2) as AR,
   l.LastOrderDate, l.LastOrderMonth, l.OrderQuarter, l.NrOfDaysSinceLastOrder,
   a.LastAbandonDate, a.LastAbandonMonth, a.AbandonQuarter, a.NrOfDaysSinceLastAbandon
   FROM rfm_browserid b, rfm_lastorderdate l, rfm_lastabandondate a
   WHERE b.browserid = l.browserid and a.browserid = b.browserid
   ),
   bounce_rate_sid AS
   (
   SELECT
   clientid,
   sid,
   substr(sid, 14, 5) AS browserid,
   count(sid) AS CountOfJsons
   FROM crab_dev
   WHERE clientid in ('tmp_clientid')
   AND sid is not null
   GROUP BY clientid, substr(sid, 14, 5), sid
   ),
   bounce_rate_browserid AS
   (
   SELECT
   clientid,
   browserid,
   COUNT(CountOfJsons) AS Visits,
   COUNT(CASE WHEN CountOfJsons = 1 THEN CountOfJsons END) BRnumber
   FROM bounce_rate_sid
   WHERE clientid in ('tmp_clientid')
   GROUP BY clientid, browserid
   ),
   kpi AS
   (
   select rfm.*, br.BRnumber, br.Visits,
   round(cast(br.BRnumber as double)/cast(br.Visits as double),4) as BR,
   round(cast(rfm.CountOfSales as double)/cast(br.Visits as double),4) as CR,
   rfm.CountOfSales*rfm.AOV as CLV
   from rfm_all rfm
   INNER JOIN bounce_rate_browserid br
   ON rfm.browserid = br.browserid
   )
   select * from kpi