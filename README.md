# credfeto-docker-registry

Docker Registry

## Configuration

Copy `.env.example` to `.env` and set the values for the host. Docker Compose
reads `.env` from the project directory.

| Variable                    | Default        | Purpose                           |
|-----------------------------|----------------|-----------------------------------|
| `REGISTRY_HTTP_SECRET`      | none           | Secret used to sign registry data |
| `WATCHTOWER_SCHEDULE`       | `0 18 * * * *` | When watchtower applies updates   |
| `REGISTRY_FIREWALL_ENFORCE` | unset          | `true` enforces the host firewall |

`WATCHTOWER_SCHEDULE` is a 6-field cron expression with seconds first:
`second minute hour day month weekday`. The default runs hourly at 18 minutes
past the hour. Set a different value in `.env` to update hosts at different
times, for example:

```sh
WATCHTOWER_SCHEDULE="0 48 * * * *"
```

Watchtower removes superseded images after each update (`WATCHTOWER_CLEANUP`).

## Host firewall

`update` runs `firewall/configure`, which locks the docker cache down for ingress and egress, the same way as the DNS, monitoring and key servers:

| Filter                                 | Traffic                     | Allowed                                                                                                                                                                       |
|----------------------------------------|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `reg_ingress` (nftables)               | LAN -> published port       | the cache (tcp 8081) from the reverse proxies only, since every host reaches it as `docker-cache.markridgwell.com` through Traefik                                            |
| `reg-egress` (firewalld policy)        | host -> anywhere            | DNS to the fleet's DNS servers, NTP to the router, HTTPS to the proxies, journald uploads to monitoring, GitHub, ghcr.io, Docker Hub, Cloudflare, chaotic-aur, pkgstats, the Arch WKD, ICMP |
| `reg-egress-docker` (firewalld policy) | containers -> outside world | DNS, HTTPS to the proxies, Docker Hub and Cloudflare (the cache's upstream and Watchtower), the Alpine CDN (`cache-gc` installs curl and jq when it starts)                    |

SSH to the host is left to the host's base configuration. The zone rules `update` adds for ports 8008, 8080 and 8081 do not filter the published container port (Docker translates it before firewalld's rules run); the host firewall does.

Ingress is an nftables table of its own (`firewall/ingress.nft.template`, loaded by `registry-ingress-firewall.service` before Docker starts) because firewalld accepts Docker's translated traffic before its policies run.

Two timers keep it current:

* `registry-egress-refresh.timer` (every 10 minutes) refreshes the firewalld ipsets for destinations without a stable address: names resolved from DNS, plus GitHub's and Cloudflare's published ranges (`firewall/github-egress-ranges` and `firewall/cloudflare-egress-ranges`).
* `registry-firewall-sync.timer` (every 15 minutes) pulls the checkout and re-runs `firewall/configure` when anything under `firewall/` changed since the commit it last applied. Container changes still wait for `update`.

The `Repo: Update egress ranges` workflow regenerates the two range files daily and commits any change to main, refusing a list that has shrunk by more than a fifth.

`REGISTRY_FIREWALL_ENFORCE` in `.env` is the only switch. Unset or anything other than `true` is observation mode: every rule is in place, but traffic that matches none of them still flows and is logged with the prefix `reg-ingress-unmatched:`, `reg-egress-unmatched:` or `reg-egress-docker-unmatched:` (rate-limited to 30 a minute). Run in observation mode first and check the journal for anything legitimate that is not covered:

```sh
sudo journalctl -k --since -1d | grep -E 'reg-[a-z-]+-unmatched'
```

then set `REGISTRY_FIREWALL_ENFORCE=true` and run `./update`. Every host pulls images through this cache, so check `curl -fsS https://docker-cache.markridgwell.com/v2/` from another host straight after enforcing.
