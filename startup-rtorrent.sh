#!/usr/bin/env sh

set -x

# set rtorrent user and group id
RT_UID=${USR_ID:=1000}
RT_GID=${GRP_ID:=1000}
RT_GID_current=$(getent group rtorrent | cut -d: -f3)

# update uids and gids
[[ "$RT_GID" != "$RT_GID_current" ]] && groupmod -g ${RT_GID} rtorrent
id -u rtorrent >/dev/null 2>&1 || \
  adduser -u "$RT_UID" -G rtorrent -h /home/rtorrent -D -s /bin/ash rtorrent

# arrange dirs and configs
mkdir -p /downloads/.rtorrent/session
mkdir -p /downloads/.rtorrent/watch
mkdir -p /downloads/.log/rtorrent
if [ ! -e /downloads/.rtorrent/.rtorrent.rc ]; then
    cp /root/.rtorrent.rc /downloads/.rtorrent/
fi
ln -sf /downloads/.rtorrent/.rtorrent.rc /home/rtorrent/
chown -R rtorrent:rtorrent /downloads/.rtorrent
chown -R rtorrent:rtorrent /home/rtorrent
chown rtorrent:rtorrent /downloads/.log/rtorrent

rm -f /downloads/.rtorrent/session/rtorrent.lock

# run
su -l -c "TERM=xterm rtorrent" rtorrent
