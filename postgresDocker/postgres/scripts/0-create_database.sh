#!/bin/bash

########################
# BY DANIEL            #
# 30/06/2023           #
# mo                   #
# versao 1.0           #
########################

echo "Infomar versão do Banco (12, 13, 14,1 15)"
read pgversion
echo "informar nome do banco/username a ser criado: "
read user

#executa docker para criação de estrutura de diretorios.
docker exec -t pg${pgversion} mkdir /var/lib/postgresql/data/tbs
docker exec -t pg${pgversion} mkdir /var/lib/postgresql/data/tbs/${user}_data
docker exec -t pg${pgversion} mkdir /var/lib/postgresql/data/tbs/${user}_indexes
docker exec -t pg${pgversion} chmod 700 /var/lib/postgresql/data/tbs -Rf
docker exec -t pg${pgversion} chown postgres.postgres /var/lib/postgresql/data/tbs -Rf

#ajuste de script
cp /sesuite/db/pgaudi/postgres/scripts/createdb.sql /var/lib/pgsql/scripts/${user}.sql
pwd="/var/lib/pgsql/scripts/${user}.sql"

if [ -f "$pwd" ]; then
  # Altere a variável dentro do script usando sed
  sed -i "s/namedb/$user/g" "$pwd"
  echo "A variável foi alterada para \"$user\" no script \"$pwd\"."
else
  echo "O script \"$pwd\" não existe."
fi
#executa comando de criacao de database
docker exec -t pg${pgversion} psql -U postgres -f /var/scripts/${user}.sql -o /var/scripts/${user}-create.log

#executa comandos pos criacao de database(extension)
cp /sesuite/db/pgaudi/postgres/scripts/postcreatedb.sql /var/lib/pgsql/scripts/postcreatedb-${user}.sql
docker exec -t pg${pgversion} psql -U postgres -d ${user} -f /var/scripts/postcreatedb-${user}.sql -o /var/scripts/postcreatedb-${user}.log
