#!/bin/bash

echo "Selecione um dos arquivos"
echo $(ls /var/lib/pgsql/bkp/)

read -p "Informe o nome do banco de dados: " database_name
read -p "Informe o usuário do banco: " database_user
read -p "Informe o caminho completo do backup (.pg_dump): " backup_path



database_name=$(echo "$database_name" | xargs)
database_user=$(echo "$database_user" | xargs)
backup_path=$(echo "$backup_path" | xargs)

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

echo "Gerando script de correção de tablespaces..."

cat > /tmp/corrigetbs.sql << EOF
SELECT
    'ALTER INDEX '||schemaname||'.'||indexname||
    ' SET TABLESPACE ${database_user}_indexes;'
FROM pg_indexes
WHERE schemaname NOT IN ('pg_catalog','information_schema')

UNION ALL

SELECT
    'ALTER TABLE '||schemaname||'.'||tablename||
    ' SET TABLESPACE ${database_user}_data;'
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog','information_schema');
EOF

docker cp /tmp/corrigetbs.sql \
    "$CONTAINER_NAME:/tmp/corrigetbs.sql"

docker exec -t "$CONTAINER_NAME" \
    psql -U "$database_user" \
    -d "$database_name" \
    -f /tmp/corrigetbs.sql \
    -o /tmp/altertbs.sql

docker exec -t "$CONTAINER_NAME" \
    psql -U "$database_user" \
    -d "$database_name" \
    -f /tmp/altertbs.sql \
    -o /tmp/log_alter_tbs.log

echo "Correção de tablespaces concluída."
echo ""
echo "Arquivos gerados no container:"
echo "  /tmp/altertbs.sql"
echo "  /tmp/log_alter_tbs.log"