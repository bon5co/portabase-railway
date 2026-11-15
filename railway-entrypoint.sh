#!/bin/bash
# Railway wrapper entrypoint for Portabase. Starts as root (the upstream entrypoint does too).
set -eu

fail() { echo "railway-entrypoint: $1" >&2; exit 1; }

[ -n "${AUTH_DEFAULT_PASSWORD:-}" ] || fail "AUTH_DEFAULT_PASSWORD is empty; refusing to start with no administrator password"
[ -n "${PROJECT_SECRET:-}" ] || fail "PROJECT_SECRET is empty; refusing to start with no signing secret"
[ "${#PROJECT_SECRET}" -ge 32 ] || fail "PROJECT_SECRET is shorter than 32 characters"

# Database: a full DATABASE_URL wins; otherwise build it from the postgres service's host and password.
if [ -z "${DATABASE_URL:-}" ]; then
  [ -n "${DB_HOST:-}" ] || fail "neither DATABASE_URL nor DB_HOST is set"
  [ -n "${DB_PASSWORD:-}" ] || fail "DB_PASSWORD is empty"
  export DATABASE_URL="postgresql://${DB_USER:-portabase}:${DB_PASSWORD}@${DB_HOST}:5432/${DB_NAME:-portabase}?schema=public"
fi
until pg_isready -q -d "$DATABASE_URL"; do
  echo "railway-entrypoint: waiting for the database"
  sleep 2
done

# Public URL and trusted origin come from the Railway domain unless the deployer set a custom one.
if [ -z "${PROJECT_URL:-}" ]; then
  [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ] || fail "PROJECT_URL is unset and the service has no public domain"
  export PROJECT_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

# Upstream's nginx listens on 80 (hard-coded); a public Railway service must answer on the injected
# PORT because its healthcheck dials it.
LISTEN_PORT="${PORT:-8080}"
if [ "$LISTEN_PORT" != "80" ]; then
  sed -i "s/listen 80;/listen ${LISTEN_PORT};/" /etc/nginx/nginx.conf
fi

mkdir -p /data/private/uploads
echo "railway-entrypoint: listen=${LISTEN_PORT} url=${PROJECT_URL} data-owner=$(stat -c %u:%g /data)"

exec sh /app/app-prod-entrypoint.sh "$@"
