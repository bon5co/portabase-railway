# portabase-railway

Wrapper image for running the official [Portabase](https://github.com/portabase/portabase) image on
[Railway](https://railway.com). Published as `ghcr.io/bon5co/portabase-railway:1.36.2`.

It changes the following and leaves everything else, including every upstream variable, alone:

1. **Refuses to start with an empty `AUTH_DEFAULT_PASSWORD` or `PROJECT_SECRET`** (or a secret under 32 characters), so a deploy never boots without an administrator password or with a guessable signing secret.
2. **Honours `$PORT`** by rewriting upstream's nginx `listen 80` to it. Railway's healthcheck dials the injected port, not 80.
3. **Takes `PROJECT_URL` and the trusted origin from `RAILWAY_PUBLIC_DOMAIN`** unless you set your own.
4. **Builds `DATABASE_URL`** from `DB_HOST` and `DB_PASSWORD` (the postgres service) unless you set one, and waits for the database.
5. **Bakes** the administrator `admin@example.com`, the REST API and OpenAPI on (`API_ENABLED`, `OPENAPI_ENABLED`), anonymous sign-up off (`AUTH_SIGNUP_ENABLED=false`) and telemetry off.

## Variables

| Variable | Purpose |
|---|---|
| `AUTH_DEFAULT_PASSWORD` | Required. Password of the administrator `admin@example.com`, created at first boot. |
| `PROJECT_SECRET` | Required, 32 characters or more. Signs sessions and encrypts stored secrets. Keep it stable across redeploys. |
| `DB_HOST`, `DB_PASSWORD` | The postgres service's private host and password. |

Data lives in Postgres and on the volume mounted at `/data` (local backup storage and uploads).
