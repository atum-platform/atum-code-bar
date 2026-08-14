# ASUS portable CI

Date: 2026-08-14

## Change

- Routed CI change detection, lint, and the aggregate gate through the
  `portable-ci` capability.
- Routed scheduled upstream monitoring through the same ASUS-first pool.
- Added explicit fork-origin rejection to portable pull-request jobs.
- Registered the shared `portable-ci` runner label with the repository's
  actionlint configuration.

## Boundaries

Swift/Xcode jobs, Linux ARM jobs, musl builds, fork app packaging, and release
matrices retain their existing runners. They require exact architectures,
privileged package installation, or hosted Apple toolchains that the portable
pool does not promise.

## Verification

- `actionlint -ignore SC2016` must pass; the ignored informational findings are
  pre-existing literal Markdown format strings in shell summaries.
- Portable pull-request jobs must report `ubuntu-asus-anka-labs` when ASUS is
  available.
- Existing exact-platform jobs must retain their current runner selectors.
