-- Test timestamp functions in vectorized mode to verify they run correctly end-to-end.
-- Turning on vectorization has been temporarily moved after filling the test table
-- due to bug HIVE-8197.


CREATE TABLE alltypesorc_string(ctimestamp1 timestamp, stimestamp1 string) STORED AS ORC;

INSERT OVERWRITE TABLE alltypesorc_string
SELECT
  to_utc_timestamp(ctimestamp1, 'America/Los_Angeles') AS toutc,
  CAST(to_utc_timestamp(ctimestamp1, 'America/Los_Angeles') AS STRING) as cst
FROM alltypesorc
ORDER BY toutc, cst
LIMIT 40;

SET hive.vectorized.execution.enabled = true;

CREATE TABLE alltypesorc_wrong(stimestamp1 string) STORED AS ORC;

INSERT INTO TABLE alltypesorc_wrong SELECT 'abcd' FROM alltypesorc LIMIT 1;
INSERT INTO TABLE alltypesorc_wrong SELECT '2000:01:01 00-00-00' FROM alltypesorc LIMIT 1;
INSERT INTO TABLE alltypesorc_wrong SELECT '0000-00-00 99:99:99' FROM alltypesorc LIMIT 1;

EXPLAIN SELECT
  to_unix_timestamp(ctimestamp1) AS c1,
  year(ctimestamp1),
  month(ctimestamp1),
  day(ctimestamp1),
  dayofmonth(ctimestamp1),
  weekofyear(ctimestamp1),
  hour(ctimestamp1),
  minute(ctimestamp1),
  second(ctimestamp1)
FROM alltypesorc_string
ORDER BY c1;

SELECT
  to_unix_timestamp(ctimestamp1) AS c1,
  year(ctimestamp1),
  month(ctimestamp1),
  day(ctimestamp1),
  dayofmonth(ctimestamp1),
  weekofyear(ctimestamp1),
  hour(ctimestamp1),
  minute(ctimestamp1),
  second(ctimestamp1)
FROM alltypesorc_string
ORDER BY c1;

EXPLAIN SELECT
  to_unix_timestamp(stimestamp1) AS c1,
  year(stimestamp1),
  month(stimestamp1),
  day(stimestamp1),
  dayofmonth(stimestamp1),
  weekofyear(stimestamp1),
  hour(stimestamp1),
  minute(stimestamp1),
  second(stimestamp1)
FROM alltypesorc_string
ORDER BY c1;

SELECT
  to_unix_timestamp(stimestamp1) AS c1,
  year(stimestamp1),
  month(stimestamp1),
  day(stimestamp1),
  dayofmonth(stimestamp1),
  weekofyear(stimestamp1),
  hour(stimestamp1),
  minute(stimestamp1),
  second(stimestamp1)
FROM alltypesorc_string
ORDER BY c1;

EXPLAIN SELECT
  to_unix_timestamp(ctimestamp1) = to_unix_timestamp(stimestamp1) AS c1,
  year(ctimestamp1) = year(stimestamp1),
  month(ctimestamp1) = month(stimestamp1),
  day(ctimestamp1) = day(stimestamp1),
  dayofmonth(ctimestamp1) = dayofmonth(stimestamp1),
  weekofyear(ctimestamp1) = weekofyear(stimestamp1),
  hour(ctimestamp1) = hour(stimestamp1),
  minute(ctimestamp1) = minute(stimestamp1),
  second(ctimestamp1) = second(stimestamp1)
FROM alltypesorc_string
ORDER BY c1;

-- Should all be true or NULL
SELECT
  to_unix_timestamp(ctimestamp1) = to_unix_timestamp(stimestamp1) AS c1,
  year(ctimestamp1) = year(stimestamp1),
  month(ctimestamp1) = month(stimestamp1),
  day(ctimestamp1) = day(stimestamp1),
  dayofmonth(ctimestamp1) = dayofmonth(stimestamp1),
  weekofyear(ctimestamp1) = weekofyear(stimestamp1),
  hour(ctimestamp1) = hour(stimestamp1),
  minute(ctimestamp1) = minute(stimestamp1),
  second(ctimestamp1) = second(stimestamp1)
FROM alltypesorc_string
ORDER BY c1;

-- Wrong format. Should all be NULL.
EXPLAIN SELECT
  to_unix_timestamp(stimestamp1) AS c1,
  year(stimestamp1),
  month(stimestamp1),
  day(stimestamp1),
  dayofmonth(stimestamp1),
  weekofyear(stimestamp1),
  hour(stimestamp1),
  minute(stimestamp1),
  second(stimestamp1)
FROM alltypesorc_wrong
ORDER BY c1;

SELECT
  to_unix_timestamp(stimestamp1) AS c1,
  year(stimestamp1),
  month(stimestamp1),
  day(stimestamp1),
  dayofmonth(stimestamp1),
  weekofyear(stimestamp1),
  hour(stimestamp1),
  minute(stimestamp1),
  second(stimestamp1)
FROM alltypesorc_wrong
ORDER BY c1;

EXPLAIN SELECT
  min(ctimestamp1),
  max(ctimestamp1),
  count(ctimestamp1),
  count(*)
FROM alltypesorc_string;

SELECT
  min(ctimestamp1),
  max(ctimestamp1),
  count(ctimestamp1),
  count(*)
FROM alltypesorc_string;

-- SUM of timestamps are not vectorized reduce-side because they produce a double instead of a long (HIVE-8211)...
EXPLAIN SELECT
  sum(ctimestamp1)
FROM alltypesorc_string;

SELECT
 sum(ctimestamp1)
FROM alltypesorc_string;

EXPLAIN SELECT
  avg(ctimestamp1),
  variance(ctimestamp1),
  var_pop(ctimestamp1),
  var_samp(ctimestamp1),
  std(ctimestamp1),
  stddev(ctimestamp1),
  stddev_pop(ctimestamp1),
  stddev_samp(ctimestamp1)
FROM alltypesorc_string;

SELECT
  avg(ctimestamp1),
  variance(ctimestamp1),
  var_pop(ctimestamp1),
  var_samp(ctimestamp1),
  std(ctimestamp1),
  stddev(ctimestamp1),
  stddev_pop(ctimestamp1),
  stddev_samp(ctimestamp1)
FROM alltypesorc_string;