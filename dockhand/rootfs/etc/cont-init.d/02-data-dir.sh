#!/usr/bin/with-contenv bashio
# ==============================================================================
# Ensure /data/db exists and is owned by the dockhand user
# ==============================================================================
bashio::log.info "Initialising data directory..."

mkdir -p /data/db
if ! chown -R dockhand:dockhand /data; then
	bashio::log.warning "Unable to chown /data to dockhand:dockhand (likely restricted mount permissions); continuing"
fi
