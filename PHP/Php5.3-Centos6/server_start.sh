#!/usr/bin/env bash

if [[ ! -d /ltdev/htdocs && -f /ltdev/POA.zip ]]; then
    echo "unpacking POA code"
    cd /ltdev && unzip -qq POA.zip
    rm -rf /ltdev/docker
    rm -rf POA.zip
fi

sed -i -e "s|{UI_SERVER_IP}|$DSOM_URI|g" /etc/consensus/sh/config.sh
sed -i -e "s|{CATALOG_SERVER_IP}|$CATALOG_SERVER_IP|g" /etc/consensus/sh/config.sh

sed -i -e "s|{DOCKER_POS_MYSQL}|$DOCKER_POS_MYSQL|g" /etc/consensus/php/config.php
sed -i -e "s|{DOCKER_POA_MYSQL}|$DOCKER_POA_MYSQL|g" /etc/consensus/php/config.php

sed -i -e "s|{DOCKER_POA_MYSQL}|$DOCKER_POA_MYSQL|g" /etc/consensus/sh/ltpaths.sh
sed -i -e "s|{DOCKER_POA_MYSQL}|$DOCKER_POA_MYSQL|g" /etc/consensus/sh/environment.sh

sed -i -e "s|{DEFAULT_MYSQL_PW}|$DEFAULT_MYSQL_PW|g" /ltdata/keystore/default_mysql.pass
sed -i -e "s|{DEFAULT_MYSQL_USER}|$DEFAULT_MYSQL_USER|g" /ltdata/keystore/default_mysql.user
sed -i -e "s|{DEFAULT_ROOT_PW}|$MYSQL_ROOT_PASSWORD|g" /ltdata/keystore/default_root.pass
sed -i -e "s|{DEFAULT_ROOT_USER}|$MYSQL_ROOT_USER|g" /ltdata/keystore/default_root.user
sed -i -e "s|{KEY_MYSQL_PW}|$KEY_MYSQL_PW|g" /ltdata/keystore/key_mysql.pass
sed -i -e "s|{KEY_MYSQL_USER}|$KEY_MYSQL_USER|g" /ltdata/keystore/key_mysql.user
sed -i -e "s|{PRIVATE_MYSQL_PW}|$PRIVATE_MYSQL_PW|g" /ltdata/keystore/private_mysql.pass
sed -i -e "s|{PRIVATE_MYSQL_USER}|$PRIVATE_MYSQL_USER|g" /ltdata/keystore/private_mysql.user

sed -i -e "s|{HTTPS}|$HTTPS|g" /usr/local/lib/php.ini # secure cookie on or off.

bash -c "while ! curl -s $DOCKER_POA_MYSQL:3306 > /dev/null; do echo waiting for poa mysql; sleep 2; done;"

if [[ ! -d /ltstatic && -f /ltstatic.zip ]]; then
    echo "unpacking ltstatic content"
    cd /
    unzip -qq ltstatic.zip
    rm -rf /ltdev/shtdocs/img
    ln -s /ltstatic/img /ltdev/shtdocs/img
    rm -rf /ltstatic.zip
    echo "assuming this is the first time this container is run, so add credentials"
    php /root/scripts/credentials.php
fi

php /root/scripts/dbmigration.php

touch /var/weblogs/dberrs.txt
chown -R apache /var/weblogs
if [ ! -d "/var/log/httpd" ]; then
    mkdir /var/log/httpd
    chown -R apache /var/log/httpd
fi
if [ ! -f "/var/log/httpd/error_log" ]; then
    touch /var/log/httpd/error_log
    chown apache /var/log/httpd/error_log
fi
if [ ! -f  "/var/log/httpd/access_log" ]; then
    touch /var/log/httpd/access_log
    chown apache /var/log/httpd/access_log
fi

# DB MIGRATIONS
if [ "$ENVIRONMENT" == 'dev' ]; then

    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='productdb'" 2>&1`" ]];
    then
        echo "productdb exists, skipping"
    else
        echo "creating productdb"
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD < /ltdev/db/createscripts/createproductdb.sql
        echo "done creating productdb"
    fi
    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='sessiondb'" 2>&1`" ]];
    then
        echo "sessiondb exists, skipping"
    else
        echo "creating sessiondb"
        echo "CREATE DATABASE sessiondb" | mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD sessiondb < /ltdev/db/createscripts/createsessiondb.sql
        echo "done creating sessiondb"
    fi
    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='serverdb'" 2>&1`" ]];
    then
        echo "serverdb exists, skipping"
    #else
        #echo "loading serverdb"
        ##### NOT USING createscripts currently - using mounted sql directory in poa_db ####
        #mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD < /ltdev/db/createscripts/createserverdb.sql
        #echo "done loading serverdb"
    fi
    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='trackdb'" 2>&1`" ]];
    then
        echo "trackdb exists, skipping"
    else
        echo "loading trackdb"
        echo "CREATE DATABASE trackdb" | mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD trackdb < /ltdev/db/createscripts/createtrackdb.sql
        echo "done loading trackdb"
    fi
    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='cachedb'" 2>&1`" ]];
    then
        echo "cachedb exists, skipping"
    else
        echo "loading cachedb"
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD < /ltdev/db/createscripts/createcachedb.sql
        echo "done loading cachedb"
    fi
    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='privatedb'" 2>&1`" ]];
    then
        echo "privatedb exists, skipping"
    else
        echo "loading privatedb"
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD < /ltdev/db/createscripts/createprivatetables.sql
        echo "done loading privatedb"
    fi
    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='keydb'" 2>&1`" ]];
    then
        echo "keydb exists, skipping"
    else
        echo "loading keydb"
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD < /ltdev/db/createscripts/createkeytables.sql
        echo "done loading keydb"
    fi

    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='adminchangesdb'" 2>&1`" ]];
    then
        echo "adminchangesdb exists, skipping"
    else
        echo "loading adminchangesdb"
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD < /ltdev/db/createscripts/createadminchangesdb.sql
        echo "done loading adminchangesdb"
    fi

    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='bugdb'" 2>&1`" ]];
    then
        echo "bugdb exists, skipping"
    else
        echo "loading bugdb"
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD < /ltdev/db/createscripts/createbugdb.sql
        echo "done loading bugdb"
    fi

    if [[ ! -z "`mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='datadb'" 2>&1`" ]];
    then
        echo "datadb exists, skipping"
    else
        echo "loading datadb"
        mysql -h $DOCKER_POA_MYSQL -uroot -p$MYSQL_ROOT_PASSWORD < /ltdev/db/createscripts/createdatadb.sql
        echo "done loading datadb"
    fi


fi


echo "starting apache"
apachectl start

tail -f /var/log/httpd/error_log -f /var/log/httpd/access_log