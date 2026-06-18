#!/bin/bash

echo "Selecione um dos arquivos"
echo $(ls /var/lib/pgsql/bkp/)
echo $(pwd)

default_backup_dir="/var/lib/pgsql/bkp"

read -p "Informe o nome do banco de dados: " database_name
read -p "Informe o usuário do banco: " database_user
read -p "Informe o nome do backup em ${default_backup_dir} ou o caminho completo (.pg_dump): " backup_input



database_name=$(echo "$database_name" | xargs)
database_user=$(echo "$database_user" | xargs)
backup_input=$(echo "$backup_input" | xargs)

if [[ "$backup_input" == */* ]]; then
    backup_path="$backup_input"
else
    backup_path="${default_backup_dir}/${backup_input}"
fi

echo ""
echo "Banco........: $database_name"
echo "Usuário......: $database_user"
echo "Backup.......: $backup_path"
echo ""

if [ ! -f "$backup_path" ]; then
    echo "ERRO: Arquivo de backup não encontrado."
    exit 1
fi

CONTAINER_NAME=$(docker ps --format '{{.Names}}' | grep pg | head -n 1)

if [ -z "$CONTAINER_NAME" ]; then
    echo "ERRO: Nenhum container PostgreSQL encontrado."
    exit 1
fi

echo "Container encontrado: $CONTAINER_NAME"

echo "Iniciando restore..."

cat "$backup_path" | docker exec -i "$CONTAINER_NAME" \
    pg_restore \
    -U "$database_user" \
    -d "$database_name" \
    --no-owner \
    --no-tablespaces \
    --verbose

if [ $? -ne 0 ]; then
    echo "ERRO durante o restore."
    exit 1
fi

echo "Restore concluído."

docker exec -t "$CONTAINER_NAME" psql -U $database_name -f "/var/scripts/fix_indexes_$database_name.sql" -o "/var/scripts/alter_indexes_$database_name.sql"
docker exec -t "$CONTAINER_NAME" psql -U $database_name -f "/var/scripts/alter_indexes_$database_name.sql" -o "/var/scripts/alter_indexes_$database_name.log"
docker log "$CONTAINER_NAME" -f
echo "-------------------------------------------------------"
cat "/var/lib/pgsql/scripts/alter_indexes_$database_name.log"
echo "-------------------------------------------------------"