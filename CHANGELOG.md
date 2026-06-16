# Changelog

## [Unreleased]
### Security
### Added
### Fixed
### Changed
- Migrated `docker-compose.yml` to be compatible with rootless Podman Compose (issue #7)
- Updated watchtower service to use Podman socket (`${XDG_RUNTIME_DIR}/podman/podman.sock`) instead of Docker socket
- Replaced `docker` commands in `update` and `cleanup` scripts with `podman` equivalents
- Added `.yamllint.yml` configuration matching global pre-commit and ansible-lint requirements
- Added YAML document-start markers to `docker-compose.yml`, `cache-config.yml`, and `registry-config.yml`
- `update` script now creates a dedicated unprivileged `registry` system user and installs a system-level `podman-registry.service` unit; the service manages the Podman Compose stack lifecycle rather than starting it directly
### Removed
### Deployment Changes
