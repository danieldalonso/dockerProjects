#!/bin/bash

#10 days limit
time_limit=10
find /var/lib/pgsql/bkp* -mtime +$time_limit -exec rm -f {} \;
#find /var/lib/pgsql/10/backup/wal* -mtime +$time_limit -exec rm -f {} \;
echo "Arquivos com mais de $time_limit dias deletados"
echo "Limpeza efetuada com sucesso"
