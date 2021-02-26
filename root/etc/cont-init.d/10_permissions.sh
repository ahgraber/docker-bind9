#!/usr/bin/with-contenv bash

# permissions
if [ -d "/letsencrypt" ]; then
    chown -R 644 /letsencrypt
fi
if [ -d "/config/log" ]; then
    chmod -R +r /config/log
fi