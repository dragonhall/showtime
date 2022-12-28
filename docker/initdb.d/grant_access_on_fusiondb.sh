#!/bin/sh

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -NBe "GRANT ALL PRIVILEGES ON dragonhall_utf8.* TO '${MYSQL_USER}'@'%';"
