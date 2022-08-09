select amname from pg_am; -- виды индексов

-- свойствам метода доступа
select a.amname, p.name, pg_indexam_has_property(a.oid, p.name)
from pg_am a,
     unnest(array ['can_order','can_unique','can_multi_col','can_exclude']) p(name)
where a.amname = 'btree'
order by a.amname;

-- Свойства, относящиеся к индексу
select p.name, pg_index_has_property('t_a_idx'::regclass, p.name)
from unnest(array ['clusterable','index_scan','bitmap_scan','backward_scan']) p(name);

-- обычный индекс по текстовому полю не поддерживает операцию LIKE
explain (costs off) select * from t where b like 'A%'; -- Seq Scan

create index on t(b text_pattern_ops);

explain (costs off) select * from t where b like 'A%'; -- Bitmap Heap Scan