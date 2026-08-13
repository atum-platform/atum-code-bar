# Local CI

The scheduled upstream monitor runs on the private Anka Ventures Labs ARM64 Mac
Mini through these labels:

```yaml
runs-on: [self-hosted, macOS, ARM64, mac-mini, local-ci]
```

It is serialized with a workflow-level concurrency group and does not mutate
the persistent runner's global Git configuration.

The main CI, fork build, and release workflows remain GitHub-hosted. They
currently require Ubuntu packages, Linux musl build environments, Xcode 26, or
Intel macOS and are not compatible with the Mini's macOS 26 / Xcode 15.4
toolchain. Reassess those jobs when matching isolated runners exist.

Verification for this migration is `actionlint` plus one manual upstream monitor
run reporting runner `mac-mini-anka-labs`.
