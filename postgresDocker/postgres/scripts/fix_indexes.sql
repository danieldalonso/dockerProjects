select 'ALTER INDEX ' || o.relname || ' SET tablespace databasecustomer_indexes;'
from pg_class o join pg_namespace n on n.oid = o.relnamespace and n.nspname = 'public'left join pg_tablespace t on t.oid = o.reltablespace
where o.relkind = 'i' and t.spcname is null;