# Portabase on Railway: thin wrapper over the official image.
# What it adds: a boot-time superadmin from one generated password (upstream creates it from
# AUTH_DEFAULT_*), the Railway-injected PORT (upstream's nginx hard-codes port 80), the public URL
# and trusted origin taken from the Railway domain, the database URL assembled from the postgres
# service's host and password, the REST API switched on, anonymous sign-up and telemetry off, and
# a refusal to boot with an empty secret or password.
# upstream: portabase/portabase
FROM portabase/portabase:1.36.2@sha256:6a28b09baa25f66cfd879d573fe7ee469dbfbc98ae5460d31f2da8adf95aa1c9

USER root

ENV AUTH_DEFAULT_USER=admin@example.com \
    AUTH_DEFAULT_USER_NAME="Portabase Admin" \
    API_ENABLED=true \
    OPENAPI_ENABLED=true \
    AUTH_SIGNUP_ENABLED=false \
    TELEMETRY=false \
    DB_USER=portabase \
    DB_NAME=portabase

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
