select d.datname, t.spcname, (select iddbversion
    from administration), array_to_string(array (
select coalesce(t.spcname, 'null')|| ': ' || count(*)
from pg_class o join pg_namespace n on n.oid = o.relnamespace left join pg_tablespace t on t.oid = o.reltablespace
where o.relkind = 'i' and n.nspname = 'public'
group by t.spcname
order by t.spcname desc
), ';') as tbs from pg_database d join pg_tablespace t on t.oid = d.dattablespace where d.datname = current_database
();