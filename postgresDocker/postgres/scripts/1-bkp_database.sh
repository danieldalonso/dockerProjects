#!/bin/bash

########################
# BY DANIEL            #
# 05/09/2023           #
# mo                   #
# versao 2.0           #
########################

database_name=$(sed -n '18s/<db>//g; 18s/<\/db>//g; 18p' /sesuite/data/conf/database_config.xml)
database_user=$(sed -n '14s/<databaseUser>//g; 14s/<\/databaseUser>//g; 14p' /sesuite/data/conf/database_config.xml)
#tratamento para retirar os espaços em branco
database_name=$(echo "$database_name"| sed 's/ //g')
database_user=$(echo "$database_user"| sed 's/ //g')
backup_path=/var/backups/$database_name-`date +%Y_%m_%d`.pg_dump

echo "Database Name:" $database_name
CONTAINER_NAME=$(docker ps --format '{{.Names}}' | head -n 1 | grep pg)
docker exec -t $CONTAINER_NAME pg_dump -F c -U "$database_user" -d "$database_name" -f "$backup_path"