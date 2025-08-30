
select pg_terminate_backend(pid) from pg_stat_activity where datname = 'databasecustomer';
drop database databasecustomer;
drop tablespace databasecustomer_data;
drop tablespace databasecustomer_indexes;
drop user databasecustomer;