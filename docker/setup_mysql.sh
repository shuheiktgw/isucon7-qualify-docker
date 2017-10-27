#!/bin/bash

./db/init.sh

mysql -uroot -e "CREATE USER isucon@'%' IDENTIFIED BY 'isucon'"
mysql -uroot -e "GRANT ALL on *.* TO isucon@'%'"
mysql -uroot -e "CREATE USER isucon@'localhost' IDENTIFIED BY 'isucon'"
mysql -uroot -e "GRANT ALL on *.* TO isucon@'localhost'"

zcat /tmp/isubata/bench/isucon7q-initial-dataset.sql.gz | mysql -uroot --default-character-set=utf8 isubata