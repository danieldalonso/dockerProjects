# pgaudi
Projeto de banco PG em Docker para Audi

Será criado um PG na versão 12.x

Estrutura de diretorios

SERVIDOR LOCAL

/var/lib/pgsql

DIRETORIO DE PERSISTENCIA.

PG
/var/lib/pgsql/pg/
/var/lib/pgsql/bkp/
/var/lib/pgsql/scripts/

SCRIPTS
/var/lib/pgsql/scripts:/var/scripts

BACKUP
/var/lib/pgsql/bkp:/var/backups

AGENDAMENTOS

Para realizar o agendamento, é necessario realizar o procedimento abaixo:

executar> crontab -e
copiar o conteudo abaixo
####Daily Backup
00 00  * * *  /sesuite/repo/pgaudi/postgres/scripts/1-bkp_database.sh
####10 days left
00 00  * * *  /sesuite/repo/pgaudi/postgres/scripts/5-maintenance.sh

Salvar arquivo.

#####
Atualizações:

Incluído pg_stats

CREATE EXTENSION IF NOT EXISTS pg_stat_statements; 

