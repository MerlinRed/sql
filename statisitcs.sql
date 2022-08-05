select attname,
       inherited,
       n_distinct,
       array_to_string(most_common_vals, E'\n') as most_common_vals,
       correlation
FROM pg_stats
where tablename in (
                    'table1',
                    'table2'
                   )