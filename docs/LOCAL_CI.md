# Local CI

The private fork's macOS packaging workflow runs on the organization MacBook runner using
`[self-hosted, macOS, ARM64, macbook, local-ci]`. The `macbook` label is a toolchain capability gate: this job
requires Xcode 26 and must not be routed to the older Mac Mini toolchain. Keep the runner's real hardware label;
do not add `mac-mini` to the MacBook.

Build 114 is the first compatibility artifact gated on fresh-install Codex, Claude, and authenticated Kimi provider
detection plus launch-at-login persistence. Install this build or newer when provisioning another Mac; do not clone
CodexBar credential files between machines.
