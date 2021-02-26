#!/usr/bin/with-contenv bash
# cribbed from https://github.com/linuxserver/docker-swag/blob/master/root/etc/cont-init.d/50-config

# Display variables for troubleshooting
echo -e "Variables set:\\n\
PUID=${PUID}\\n\
PGID=${PGID}\\n\
TZ=${TZ}\\n\
"

#############################################
######### Make our folders and links ########
#############################################
mkdir -p /config/{log/bind,bind/conf,bind/lib} 
# mkdir -p /config/bind/conf  # /etc/bind
# mkdir -p /config/bind/lib  # /var/lib/bind

# Link logs
echo "Linking /config/log/bind9 -> /var/log/bind ..."
ln -s /config/log/bind /var/log/bind


# If files exist in /var/lib bind, copy to config
# otherwise populate from defaults
if [ "$(ls -A /var/lib/bind)" ]; then
  echo "Copying existing files from /var/lib/bind to /config/bind/conf ..." && \
	cp -n /etc/bind/* /config/bind/conf
else
  echo "Copying default bind9 init files to /config/bind/conf ..." && \
	cp -n /defaults/bind/* /config/bind/conf/
fi

# Link /config/lib/bind
echo "Linking /config/conf -> /etc/bind ..."
rm -rf /etc/bind
ln -s /config/bind/conf /etc/bind


# If files exist in /var/lib bind, copy to config
[[ "$(ls -A /var/lib/bind)" ]] && \
  echo "Copying existing files from /var/lib/bind to /config/bind/lib ..." && \
	cp -n /var/lib/bind/* /config/bind/lib

# Link /config/lib/bind
echo "Linking /config/bind/lib -> /var/lib/bind ..."
rm -rf /var/lib/bind
mkdir -p /var/lib/bind
ln -s /config/bind/lib /var/lib/bind
# rm /etc/crontabs/*
# cp /config/crontabs/* /etc/crontabs/


# # change permissions on mount volume
# chown -R abc:abc /config
# chown -R $(whoami) /config


# warn if not running on host network
# ref: https://github.com/prehley/bind9/blob/master/util/entrypoint.sh
container_id=$(grep docker /proc/self/cgroup | sort -n | head -n 1 | cut -d: -f3 | cut -d/ -f5)
if perl -e '($id,$name)=@ARGV;$short=substr $id,0,length $name;exit 1 if $name ne $short;exit 0' $container_id $HOSTNAME; then
    echo "You must add the 'docker run' option '--net=host' if you want to provide DNS service to the host network."
fi