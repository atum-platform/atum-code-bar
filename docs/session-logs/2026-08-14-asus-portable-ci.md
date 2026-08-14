# ASUS portable CI

Date: 2026-08-14

## Change

- Routed CI change detection and the aggregate gate through the `portable-ci`
  capability.
- Routed lint through ASUS's rootless `container-ci` capability using an Ubuntu
  24.04 job container.
- Routed scheduled upstream monitoring through the same ASUS-first pool.
- Added explicit fork-origin rejection to portable pull-request jobs.
- Registered the shared `portable-ci` and `container-ci` runner labels with the
  repository's actionlint configuration.

## Boundaries

Swift/Xcode jobs, Linux ARM jobs, musl builds, fork app packaging, and release
matrices retain their existing runners. They require exact architectures,
privileged package installation, or hosted Apple toolchains that the portable
pool does not promise.

The host's Ubuntu 26.04 libxml2 ABI is newer than the ABI expected by the pinned
SwiftLint release. The lint container preserves the job's prior Ubuntu 24.04
contract without adding legacy libraries or sudo access to the host.

## Verification

- `actionlint -ignore SC2016` must pass; the ignored informational findings are
  pre-existing literal Markdown format strings in shell summaries.
- Portable pull-request jobs must report `ubuntu-asus-anka-labs` when ASUS is
  available.
- Existing exact-platform jobs must retain their current runner selectors.
