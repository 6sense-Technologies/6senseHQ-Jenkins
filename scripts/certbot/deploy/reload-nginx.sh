#!/bin/sh
# Reload nginx after certbot renews certificates.
# Runs inside the certbot container; uses Docker Engine API over the mounted socket
# because the certbot image does not include the docker CLI.

set -e

CONTAINER="${NGINX_CONTAINER_NAME:-nginx}"
SOCKET="/var/run/docker.sock"

if [ ! -S "$SOCKET" ]; then
  echo "Docker socket not found at $SOCKET" >&2
  exit 1
fi

# HUP makes the nginx master (PID 1) reload config and pick up new certs.
curl -sf --unix-socket "$SOCKET" \
  -X POST "http://localhost/containers/${CONTAINER}/kill?signal=HUP" \
  > /dev/null

echo "Reloaded nginx (${CONTAINER})"
