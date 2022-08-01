-- Отсутствующие индексы
select
  relname,
  seq_scan - idx_scan as too_much_seq,
  case
    when
      seq_scan - coalesce(idx_scan, 0) > 0
    then
      'Missing Index?'
    else
      'OK'
  end,
  pg_relation_size(relname::regclass) AS rel_size, seq_scan, idx_scan
FROM
  pg_stat_all_tables
where
  schemaname = 'public'
  and pg_relation_size(relname::regclass) > 80000
ORDER BY
  too_much_seq DESC;


-- Неиспользуемые индексы
select
  indexrelid::regclass as index,
  relid::regclass as table,
  'DROP INDEX ' || indexrelid::regclass || ';' as drop_statement
FROM
  pg_stat_user_indexes
  JOIN
    pg_index USING (indexrelid)
WHERE
  idx_scan = 0
  AND indisunique is false;