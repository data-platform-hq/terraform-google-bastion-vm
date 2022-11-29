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
curl -L -o WideWorldImporters-Full.bak https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak
curl -L -o WideWorldImportersDW-Full.bak https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak
gsutil cp WideWorldImporters* ${BUCKET_NAME}/databases/
gcloud sql import bak ${SQL_INSTANCE_NAME} ${BUCKET_NAME}/databases/WideWorldImporters-Full.bak --database=${SQL_BASE_NAME} --quiet 
gcloud sql import bak ${SQL_INSTANCE_NAME} ${BUCKET_NAME}/databases/WideWorldImportersDW-Full.bak --database=${SQL_BASE_NAME}_dw --quiet 

echo $(date -u) "copy script.sql" >> /tmp/log/configuration.log 
gsutil cp ${BUCKET_NAME}/templates/script.sql .

echo $(date -u) "runing script.sql" >> /tmp/log/configuration.log
/opt/mssql-tools/bin/sqlcmd -d ${SQL_BASE_NAME} -U ${SQLROOT_NAME} -P '${SQLROOT_PASSWD}' -S ${SQL_INSTANCE_IP} -i "script.sql"