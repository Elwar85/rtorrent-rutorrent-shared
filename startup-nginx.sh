#!/usr/bin/env sh

set -x

MAIN_DIR=/downloads
RUTORRENT_DIR=$MAIN_DIR/.rutorrent
TORRENTS_DIR=$RUTORRENT_DIR/torrents
NGINX_LOG_DIR=$MAIN_DIR/.log/nginx

if [ ! -d "$TORRENTS_DIR" ]; then
    mkdir -p ${TORRENTS_DIR}
    chown -R nginx:nginx ${RUTORRENT_DIR}
fi

if [ ! -d "$NGINX_LOG_DIR" ]; then
    mkdir -p $NGINX_LOG_DIR
    chown -R nginx:nginx ${NGINX_LOG_DIR}
fi

RT_GID=${GRP_ID:=1000}
RT_GID_current=$(cat /etc/group | grep ^rtorrent | cut -d ":" -f3)
[[ "$RT_GID" != "$RT_GID_current" ]] && groupmod -g ${RT_GID} rtorrent

rm -f /etc/nginx/sites-enabled/*
rm -rf /etc/nginx/ssl

# Basic auth enabled by default
site=rutorrent-basic.nginx

# Check if TLS needed
if [ -e /downloads/nginx.key ] && [ -e /downloads/nginx.crt ]; then
    mkdir -p /etc/nginx/ssl
    cp /downloads/nginx.crt /etc/nginx/ssl/
    cp /downloads/nginx.key /etc/nginx/ssl/
    site=rutorrent-tls.nginx
fi

cp /root/$site /etc/nginx/sites-enabled/
[ -n "$NOIPV6" ] && sed -i 's/listen \[::\]:/#/g' /etc/nginx/sites-enabled/$site
[ -n "$WEBROOT" ] && ln -s /var/www/rutorrent /var/www/rutorrent/$WEBROOT

# Check if .htpasswd presents
if [ -e /downloads/.htpasswd ]; then
    cp /downloads/.htpasswd /var/www/rutorrent/ && chmod 755 /var/www/rutorrent/.htpasswd && chown nginx:nginx /var/www/rutorrent/.htpasswd
else
# disable basic auth
    sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/$site
fi

mkdir -p /run/nginx
nginx -g "daemon off;"

