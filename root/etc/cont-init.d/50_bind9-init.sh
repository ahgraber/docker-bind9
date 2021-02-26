#!/usr/bin/with-contenv bash
# cribbed from https://github.com/linuxserver/docker-swag/blob/master/root/etc/cont-init.d/50-config

# Display variables for troubleshooting
echo -e "Variables set:\\n\
PUID=${PUID}\\n\
PGID=${PGID}\\n\
TZ=${TZ}\\n\
ZONE=${ZONE}\\n\
RZONE=${RZONE}\\n\
FWD1=${FWD1}\\n\
FWD2=${FWD2:-''}\\n\
"

# Sanitize variables
SANED_VARS=( FWD1 FWD2 RZONE ZONE )
for i in "${SANED_VARS[@]}"
do
  export echo "$i"="${!i//\"/}"
  export echo "$i"="$(echo "${!i}" | tr '[:upper:]' '[:lower:]')"
done

# Check to make sure that the required variables are set
[[ -z "${ZONE}" ]] && \
  echo "Please pass your DNS ZONE as an environment variable in your docker run command. See README for more details." && \
  sleep infinity
[[ -z "${RZONE}" ]] && \
  echo "Please pass your DNS Reverse ZONE as an environment variable in your docker run command. See README for more details." && \
  sleep infinity
[[ -z "${FWD1}" ]] && \
  echo "Please pass an upstream dns servers to FWD1 as an environment variable in your docker run command. See README for more details." && \
  sleep infinity

#############################################
######### Make our folders and links ########
#############################################
mkdir -p /config/{log/bind} 
mkdir -p /config/bind/conf  # /etc/bind
mkdir -p /config/bind/lib  # /var/lib/bind

# Link logs
echo "Linking /config/log/bind9 -> /var/log/bind ..."
ln -s /config/log/bind /var/log/bind

# Copy named.conf from defaults not already in /config
[[ ! -f /config/etc/bind/named.conf ]] && \
  echo "Copying default named.conf /config/etc/bind." && \
	cp -n /defaults/named.conf /config/bind/conf/

  # configure named.conf per environmental variables
  sed -i 's/example.com/${ZONE}/g' /defaults/named.conf
  sed -i 's/10.in-addr.arpa/${RZONE}.in-addr.arpa/g' /defaults/named.conf
  sed -i 's/8.8.8.8/${FWD1}/g' /defaults/named.conf
  sed -i 's/8.8.4.4/${FWD2}/g' /defaults/named.conf

# Link /config/lib/bind
echo "Linking /config/conf -> /etc/bind ..."
ln -s /config/bind/conf /etc/bind

# Copy zone/rzone from defaults not already in /config
# rzone will always just tag along
[[ ! -f /config/bind/lib/zone.db ]] && \
  echo "Copying default zone.db and rzone.db to /config..." && \
	cp -n /defaults/zone.db /config/bind/lib
  cp -n /defaults/rzone.db /config/bind/lib

  # configure per environmental variables


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