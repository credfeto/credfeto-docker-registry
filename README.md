# credfeto-docker-registry

Docker Registry

## Configuration

Copy `.env.example` to `.env` and set the values for the host. Docker Compose
reads `.env` from the project directory.

| Variable               | Default        | Purpose                           |
|------------------------|----------------|-----------------------------------|
| `REGISTRY_HTTP_SECRET` | none           | Secret used to sign registry data |
| `WATCHTOWER_SCHEDULE`  | `0 18 * * * *` | When watchtower applies updates   |

`WATCHTOWER_SCHEDULE` is a 6-field cron expression with seconds first:
`second minute hour day month weekday`. The default runs hourly at 18 minutes
past the hour. Set a different value in `.env` to update hosts at different
times, for example:

```sh
WATCHTOWER_SCHEDULE="0 48 * * * *"
```

Watchtower removes superseded images after each update (`WATCHTOWER_CLEANUP`).
