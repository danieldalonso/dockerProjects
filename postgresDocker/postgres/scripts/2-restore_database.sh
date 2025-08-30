#!/bin/bash

########################
# BY DANIEL            #
# 05/09/2023           #
# mo                   #
# versao 2.0           #
########################

CONTAINER_NAME=$(docker ps --format '{{.Names}}' | head -n 1 | grep pg)
echo "Tipo de Restore [1] mesma base e user [2] base diferente"
read typerestore
if [ $typerestore -eq 1]; then
    echo "Restore same Database"
    database_name=$(sed -n '18s/<db>//g; 18s/<\/db>//g; 18p' /sesuite/data/conf/database_config.xml)
    database_user=$(sed -n '14s/<databaseUser>//g; 14s/<\/databaseUser>//g; 14p' /sesuite/data/conf/database_config.xml)
    #tratamento para retirar os espaços em branco
    database_name=$(echo "$database_name"| sed 's/ //g')
    database_user=$(echo "$database_user"| sed 's/ //g')
    #executar script de drop de database atual
    cp /sesuite/db/pgaudi/postgres/scripts/dropdatabase.sql /var/lib/pgsql/scripts/$database_name.sql
    pwd="/var/lib/pgsql/scripts/$database_name.sql"
    if [ -f "$pwd" ]; then
        # Altere a variável dentro do script usando sed
        sed -i "s/databasecustomer/$database_name/g" "$pwd"
        echo "A variável foi alterada para \"$database_name\" no script \"$pwd\"."
    else
        echo "O script \"$pwd\" não existe."
    fi
    docker exec -t $CONTAINER_NAME psql -U postgres -f /var/scripts/$database_name.sql -o /var/scripts/$database_name-create.log
else
    echo "Restore new Database"
    echo "New Database Name/User"
    read  database_name
    database_user=$database_name
fi

echo $(ls /var/lib/pgsql/bkp/)
echo "Backup Name: "
read backup_name

backup_path=/var/lib/pgsql/bkp/$backup_name

##Restore database
#pg_restore --host 127.0.0.1 --username postgres --role=${user} --dbname ${user} --no-owner --no-tablespaces --port 5432   --verbose < ${arquivobkp}

echo $database_name" "$database_user"  "$backup_path

docker exec -i $CONTAINER_NAME pg_restore -U "$database_user"  -d "$database_name" --no-owner --no-tablespaces --port 5432 --verbose < "$backup_path"

#Ajuste de TableSpaces
#script gera comandos para alterar as tbs que estão incorretas paras as correspondentes do banco a ser alterado.
echo "SELECT ' ALTER TABLE '||schemaname||'.'||indexname||' SET TABLESPACE  "$database_user"_indexes;'from pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
UNION ALL
SELECT ' ALTER TABLE '||schemaname||'.'||tablename||' SET TABLESPACE  "$database_user"_data;'from pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema');">/var/lib/pgsql/scripts/corrigetbs.sql

docker exec -t $CONTAINER_NAME psql -U "$database_user" -f /var/scripts/corrigetbs.sql -o /var/scripts/altertbs.sql
docker exec -t $CONTAINER_NAME psql -U "$database_user" -f /var/scripts/altertbs.sql -o /var/scripts/log_alter_tbs.log


