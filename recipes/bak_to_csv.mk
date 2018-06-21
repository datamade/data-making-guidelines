SHELL := /bin/bash
BAK_PATH = path/to/dir/with/bak/file.bak
PASSWORD = password
DOCKER_NAME = bak
DB_NAME = name_of_database
MDF = path/to/where/you/want/to/restore/database.mdf
MDF_LOG = path/to/where/you/want/to/restore/database/logs.ldf
PG_DB = states_attorney
TABLESPACE = NAME_OF_TABLESPACE_TO_EXPORT_FROM

SOURCE_TABLE = $(PREFIX)_$(shell echo $(basename $(notdir $@)) | tr a-z A-Z)
CHECK_DOCKER = sudo docker ps --filter=name=$(DOCKER_NAME) -q


TABLES = names of tables to export

CSV = $(patsubst %,%.csv,$(TABLES))

.PHONY : all
all : CSV


restore_db :
	restore database $(DB_NAME) from disk='$(BAK_PATH)' with move '$(DB_NAME)' to '$(MDF)', move '$(DB_NAME)_log' to '$(MDF_LOG)'

db :
	/opt/mssql-tools/bin/sqlcmd -S localhost,1402 -U SA -P "$(PASSWORD)" -Q "CREATE DATABASE $(DB_NAME) ON (FILEDOCKER_NAME = '$(MDF)'), (FILEDOCKER_NAME = '$(MDF_LOG)') FOR ATTACH"


%.header: sqlserver
	/opt/mssql-tools/bin/bcp "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='$(SOURCE_TABLE)'" queryout $@_raw -c -S localhost,1402 -U SA -d $(DB_NAME) -P '$(PASSWORD)'
	cat $@_raw | tr '\n' ',' | sed 's/,$$/\n/' > $@
	rm $@_raw

%.data: sqlserver
	/opt/mssql-tools/bin/bcp "SELECT * FROM $(TABLE_SPACE).$(SOURCE_TABLE)" queryout $@_raw -c -t $$'\035' -r $$'\036' -S localhost,1402 -U SA -d $(DB_NAME) -P '$(PASSWORD)'
	cat $@_raw | python scripts/bcp_to_csv.py > $@
	rm $@_raw

%.csv : %.header %.data 
	cat $^ > $@

% : %.csv
	cat $< | head -300000 | csvsql --datetime='%Y-%m-%d %H:%M:%S.%f' -z 10000000 --no-constraints --db postgresql:///$(PG_DB) --table $*
	if psql -d $(PG_DB) -c "\d $@"  > /dev/null 2>&1; then cat $< | \
            psql -d $(PG_DB) -c "COPY \"$@\" FROM STDIN WITH CSV HEADER"; fi
	touch $@

linux-tools:
	curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
	curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
	sudo apt-get update 
	sudo apt-get install mssql-tools 


sqlserver : $(DOCKER_NAME)
	if ! $(CHECK_DOCKER); then sudo docker restart $(DOCKER_NAME); fi

$(DOCKER_NAME) : microsoft/mssql-server-linux
	if ! $(CHECK_DOCKER) -a; then sudo docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=$(PASSWORD)' -v $(SA_PATH):/drives/sa -p 1402:1433 --name $(DOCKER_NAME) -d microsoft/mssql-server-linux:2017-latest; fi

microsoft/mssql-server-linux :
	if ! sudo docker images -q $@:2017-latest; then sudo docker pull microsoft/mssql-server-linux:2017-latest; fi
