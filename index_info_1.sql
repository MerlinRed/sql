create table t(a integer, b text, c boolean);

insert into t(a,b,c)
select s.id, chr((32+random()*94)::integer), random() < 0.01
from generate_series(1,100000) as s(id)
order by random();

create index on t(a);

analyze t;

-- Индексное сканирование
explain (costs off) select * from t where a = 1; -- Index Scan using

-- Сканирование по битовой карте
explain (costs off) select * from t where a <= 100; -- Bitmap Heap Scan

create index on t(b);

analyze t;

explain (costs off) select * from t where a <= 100 and b = 'a'; -- BitmapAnd

select attname, correlation from pg_stats where tablename = 't';

-- Последовательное сканирование
explain (costs off) select * from t where a <= 40000; -- Seq Scan

-- Покрывающие индексы
vacuum t;

explain (costs off) select a from t where a < 100; -- Index Only Scan

explain (analyze, costs off) select a from t where a <= 100; -- Index Only Scan; Heap Fetches: 0 because vacuum

-- Индексы по нескольким полям
create index on t(a,b);

analyse t;

explain (costs off) select * from t where a <= 100 and b = 'a'; -- Index Scan using

explain (costs off) select * from t where a <= 100; -- Bitmap Heap Scan

-- Индексы по выражениям
explain (costs off) select * from t where lower(b) = 'a'; -- Seq Scan

create index on t(lower(b));

analyse t;

explain (costs off) select * from t where lower(b) = 'a'; -- Bitmap Heap Scan

select * from pg_stats where tablename = 't_lower_idx';

-- Частичные индексы
create index on t(c);

analyse t;

explain (costs off) select * from t where c; -- Index Scan

explain (costs off) select * from t where not c; -- Seq Scan

select relpages from pg_class where relname='t_c_idx'; -- 278 rows

create index on t(c) where c;

analyse t;

select relpages from pg_class where relname='t_c_idx1'; -- 5 rows

-- Сортировка
set enable_indexscan=off;

explain (costs off) select * from t order by a; -- Sort; Seq Scan

set enable_indexscan=on;

explain (costs off) select * from t order by a; -- Index Scan

-- Параллельное построение
create index concurrently on t(a); -- parallel create index

select indexrelid::regclass index_name, indrelid::regclass table_name from pg_index where indisvalid; -- success index

select indexrelid::regclass index_name, indrelid::regclass table_name from pg_index where not indisvalid; -- bad index