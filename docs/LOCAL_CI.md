# Local CI

The private fork's macOS packaging workflow runs on the organization MacBook runner using
`[self-hosted, macOS, ARM64, macbook, local-ci]`. The `macbook` label is a toolchain capability gate: this job
requires Xcode 26 and must not be routed to the older Mac Mini toolchain. Keep the runner's real hardware label;
do not add `mac-mini` to the MacBook.
