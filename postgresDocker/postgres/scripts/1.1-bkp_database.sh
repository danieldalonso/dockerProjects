#!/bin/bash

read -p "Informe o nome do banco de dados: " database_name
read -p "Informe o usuário do banco: " database_user

# Remove espaços em branco no início e fim
database_name=$(echo "$database_name" | xargs)
database_user=$(echo "$database_user" | xargs)

backup_path="/var/backups/${database_name}-$(date +%Y_%m_%d).pg_dump"

echo "Database Name: $database_name"
echo "Database User: $database_user"

CONTAINER_NAME=$(docker ps --format '{{.Names}}' | grep pg | head -n 1)

if [ -z "$CONTAINER_NAME" ]; then
    echo "Nenhum container PostgreSQL encontrado."
    exit 1
fi

echo "Container encontrado: $CONTAINER_NAME"

docker exec -t "$CONTAINER_NAME" \
    pg_dump -F c \
    -U "$database_user" \
    -d "$database_name" \
    -f "$backup_path"

if [ $? -eq 0 ]; then
    echo "Backup criado com sucesso: $backup_path"
else
    echo "Erro ao gerar backup."
    exit 1
fi