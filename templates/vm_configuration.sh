#!/bin/bash
mkdir /tmp/log
cd ~/
echo $(date -u) "Start configuration" > /tmp/log/configuration.log
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
apt-get update
ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive \
apt-get install -y --no-install-recommends mssql-tools unixodbc-dev
echo $(date -u) "mssql-tools inslalled" >> /tmp/log/configuration.log

echo $(date -u) "start importing database" >> /tmp/log/configuration.log
curl -L -o ${SQL_BASE_NAME}.${SQL_DB_BACKUP_TYPE} https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.${SQL_DB_BACKUP_TYPE}

gsutil cp ${SQL_BASE_NAME}.${SQL_DB_BACKUP_TYPE} ${BUCKET_NAME}/databases/

gcloud sql import ${SQL_DB_BACKUP_TYPE} ${SQL_INSTANCE_NAME} ${BUCKET_NAME}/databases/${SQL_BASE_NAME}.${SQL_DB_BACKUP_TYPE} --database=${SQL_BASE_NAME} --quiet \
&& gsutil rm ${BUCKET_NAME}/databases/${SQL_BASE_NAME}*

echo $(date -u) "copy script.sql" >> /tmp/log/configuration.log 
gsutil cp ${BUCKET_NAME}/vm_templates/script.sql .

echo $(date -u) "runing script.sql" >> /tmp/log/configuration.log
/opt/mssql-tools/bin/sqlcmd -d ${SQL_BASE_NAME} -U ${SQLROOT_NAME} -P '${SQLROOT_PASSWD}' -S ${SQL_INSTANCE_IP} -i "script.sql"

echo $(date -u) "shutting down instance" >> /tmp/log/configuration.log
shutdown -h 5
