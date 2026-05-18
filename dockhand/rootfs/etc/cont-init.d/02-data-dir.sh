#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Ensure /data/db exists
# ==============================================================================
bashio::log.info "Initialising data directory..."

mkdir -p /data/db
