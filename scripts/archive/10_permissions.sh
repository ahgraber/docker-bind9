#!/usr/bin/with-contenv bash

# permissions
if [ -d "/config/log" ]; then
    chmod -R +r /config/log
fi
if [ -d "/config/bind" ]; then
    chmod -R +r /config/bind
fi
if [ -d "/defaults" ]; then
    chown -R 644 /defaults
fi