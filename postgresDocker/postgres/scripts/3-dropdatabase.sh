#!/bin/bash

########################
# BY DANIEL            #
# 05/09/2023           #
# mo                   #
# versao 2.0           #
########################
echo "Database Name: "
read database_name
CONTAINER_NAME=$(docker ps --format '{{.Names}}' | head -n 1 | grep pg)
cp /sesuite/db/pgaudi/postgres/scripts/dropdatabase.sql /var/lib/pgsql/scripts/drop_$database_name.sql
pwd="/var/lib/pgsql/scripts/drop_$database_name.sql"
    if [ -f "$pwd" ]; then
        # Altere a variável dentro do script usando sed
        sed -i "s/databasecustomer/$database_name/g" "$pwd"
        echo "A variável foi alterada para \"$database_name\" no script \"$pwd\"."
        echo "######################################################################"
    else
        echo "O script \"$pwd\" não existe."
    fi

docker exec -t $CONTAINER_NAME psql -U postgres -f /var/scripts/drop_$database_name.sql -o /var/scripts/$database_name-drop.log