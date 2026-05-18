#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Dockhand requires Protection Mode to be disabled in the HA UI.
# This provides full access to /var/run/docker.sock.
# ==============================================================================

bashio::log.info "Checking Protection Mode..."

bashio::require.unprotected
