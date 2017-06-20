#!/bin/bash
echo "Running post-configuration script:"

IFS='
'
for x in $(compgen -A variable | grep MYSQLD_); do
	echo "Appending [mysqld] variable: ${!x}"
	sed -i "/\[mysqld\]/a ${!x}" /etc/mysql/my.cnf
done