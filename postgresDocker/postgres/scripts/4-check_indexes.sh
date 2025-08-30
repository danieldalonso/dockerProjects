#!/bin/bash

########################
# BY DANIEL            #
# 05/09/2023           #
# mo                   #
# versao 2.0           #
########################
echo "Database Name: "
read database_name
echo "Options [1] check indexes [2] fix indexes"
read options

CONTAINER_NAME=$(docker ps --format '{{.Names}}' | head -n 1 | grep pg)

cp /sesuite/db/pgaudi/postgres/scripts/check_indexes.sql /var/lib/pgsql/scripts/check_indexes_$database_name.sql
cp /sesuite/db/pgaudi/postgres/scripts/fix_indexes.sql /var/lib/pgsql/scripts/fix_indexes_$database_name.sql

database_user=$database_name

if [ $options -eq 1 ]; then
    echo "Verifica Indices"
    
    pwd="/var/lib/pgsql/scripts/check_indexes_$database_name.sql"
    docker exec -t $CONTAINER_NAME psql -U $database_user -f /var/scripts/check_indexes_$database_name.sql -o /var/scripts/$database_name-check_indexes.log
    echo "-------------------------------------------------------"
    cat /var/lib/pgsql/scripts/$database_name-check_indexes.log    
    echo "-------------------------------------------------------"
else
    pwd="/var/lib/pgsql/scripts/fix_indexes_$database_name.sql"
    if [ -f "$pwd" ]; then
        # Altere a variável dentro do script usando sed
        sed -i "s/databasecustomer/$database_name/g" "$pwd"
        echo "A variável foi alterada para \"$database_name\" no script \"$pwd\"."
        echo "######################################################################"
    else
        echo "O script \"$pwd\" não existe."
    fi
    docker exec -t $CONTAINER_NAME psql -U postgres -f /var/scripts/fix_indexes_$database_name.sql -o /var/scripts/$database_name-fix_indexes.log
    echo "-------------------------------------------------------"
    cat /var/lib/pgsql/scripts/$database_name-fix_indexes.log    
    echo "-------------------------------------------------------"
fi
