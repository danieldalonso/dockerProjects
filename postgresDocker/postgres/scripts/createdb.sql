-- conectar com o user postgres

    CREATE USER namedb WITH ENCRYPTED PASSWORD 'namedb';

    CREATE TABLESPACE namedb_data    OWNER namedb LOCATION '/var/lib/postgresql/data/tbs/namedb_data';
    CREATE TABLESPACE namedb_indexes OWNER namedb LOCATION '/var/lib/postgresql/data/tbs/namedb_indexes';

    GRANT namedb TO postgres;
    GRANT CREATE ON TABLESPACE namedb_data TO postgres;
    GRANT CREATE ON TABLESPACE namedb_indexes TO postgres;

    CREATE DATABASE namedb
      WITH OWNER = namedb
        ENCODING = 'UTF8'
        TABLESPACE = namedb_data
        LC_COLLATE = 'en_US.utf8'
        LC_CTYPE = 'en_US.utf8'
        CONNECTION LIMIT = -1;

    REVOKE ALL ON DATABASE namedb FROM public;



  