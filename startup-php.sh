#!/usr/bin/env sh

set -x

MEM=${PHP_MEM:=256M}

sed -i 's/memory_limit.*$/memory_limit = '$MEM'/g' /etc/php81/php.ini
sed -i 's/memory_limit.*$/memory_limit = '$MEM'/g' /etc/php81/php-fpm.conf

mkdir -p /run/php
mkdir -p /var/run/php
php-fpm81 --nodaemonize
php-fpm --nodaemonize

