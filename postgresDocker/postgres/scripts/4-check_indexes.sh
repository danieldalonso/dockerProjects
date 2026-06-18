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

database_name=$(echo "$database_name" | xargs)
options=$(echo "$options" | xargs)

CONTAINER_NAME=$(docker ps --format '{{.Names}}' | grep pg | head -n 1)

if [ -z "$CONTAINER_NAME" ]; then
    echo "ERRO: Nenhum container PostgreSQL encontrado."
    exit 1
fi

cp /sesuite/db/pgaudi/postgres/scripts/check_indexes.sql "/var/lib/pgsql/scripts/check_indexes_$database_name.sql"
cp /sesuite/db/pgaudi/postgres/scripts/fix_indexes.sql "/var/lib/pgsql/scripts/fix_indexes_$database_name.sql"

database_user=$database_name

if [ "$options" -eq 1 ]; then
    echo "Verifica Indices"
    
    pwd="/var/lib/pgsql/scripts/check_indexes_$database_name.sql"
    docker exec -t "$CONTAINER_NAME" psql -U "$database_user" -f "/var/scripts/check_indexes_$database_name.sql" -o "/var/scripts/$database_name-check_indexes.log"
    echo "-------------------------------------------------------"
    cat "/var/lib/pgsql/scripts/$database_name-check_indexes.log"
    echo "-------------------------------------------------------"
elif [ "$options" -eq 2 ]; then
    echo "Corrige Indices"

    pwd="/var/lib/pgsql/scripts/fix_indexes_$database_name.sql"
    if [ -f "$pwd" ]; then
        # Altere a variável dentro do script usando sed
        sed -i.bak "s/databasecustomer/$database_name/g" "$pwd"
        rm -f "$pwd.bak"
        echo "A variável foi alterada para \"$database_name\" no script \"$pwd\"."
        echo "######################################################################"
    else
        echo "O script \"$pwd\" não existe."
    fi
    docker exec -t "$CONTAINER_NAME" psql -U $database_name -f "/var/scripts/fix_indexes_$database_name.sql" -o "/var/scripts/$database_name-fix_indexes.log"
    echo "-------------------------------------------------------"
    cat "/var/lib/pgsql/scripts/$database_name-fix_indexes.log"
    echo "-------------------------------------------------------"
else
    echo "ERRO: Opção inválida: $options"
    exit 1
fi
