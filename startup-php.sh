#!/usr/bin/env sh

set -x

MEM=${PHP_MEM:=256M}

sed -i 's/memory_limit.*$/memory_limit = '$MEM'/g' /etc/php84/php.ini
sed -i 's/memory_limit.*$/memory_limit = '$MEM'/g' /etc/php84/php-fpm.conf

mkdir -p /run/php
mkdir -p /var/run/php
php-fpm84 --nodaemonize
php-fpm --nodaemonize
