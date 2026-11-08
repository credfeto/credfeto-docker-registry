# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!--
Please ADD ALL Changes to the UNRELEASED SECTION and not a specific release
-->

## [Unreleased]
### Security
### Added
- Example environment file (.env.example) and a README Configuration section documenting the available settings
### Fixed
- Invalid ':r' volume mode in docker-compose.yml corrected to ':ro' so the volumes mount read-only as intended
### Changed
- Watchtower now removes old images after updating containers (WATCHTOWER_CLEANUP=true)
- Watchtower schedule is now configurable with WATCHTOWER_SCHEDULE (default: daily at 18:00) instead of the fixed WATCHTOWER_POLL_INTERVAL
### Deprecated
### Removed
### Deployment Changes

<!--
Releases that have at least been deployed to staging, BUT NOT necessarily released to live.  Changes should be moved from [Unreleased] into here as they are merged into the appropriate release branch
-->

## [0.0.0] - Project created