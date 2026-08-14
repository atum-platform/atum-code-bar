# Local CI

Portable CI runs on the private Anka Ventures Labs runner pool through these
labels:

```yaml
runs-on: [self-hosted, portable-ci, local-ci]
```

The router prefers the ASUS Linux runner, exposes the MacBook after the primary
has remained busy for the fallback delay, and then exposes the Mac Mini. The
scheduled upstream monitor is serialized and does not mutate a persistent
runner's global Git configuration. Main CI uses the same pool for change
detection and the final aggregate gate. Lint runs in a digest-pinned official
Swift 6.3.3 Noble container on ASUS because the pinned SwiftLint binary requires
both a compatible libxml2 ABI and the Swift SourceKit runtime. Fork-origin pull
requests are rejected before assignment to a self-hosted runner.

Swift/Xcode tests, Linux ARM builds, Linux musl packaging, the fork app build,
and release workflows remain GitHub-hosted. They require exact architectures,
privileged package installation, or hosted Xcode images and are not part of the
portable lane. Reassess those jobs when matching isolated runners exist.

Verification is `actionlint -ignore SC2016` plus a pull-request CI run showing
portable jobs in the fallback pool and lint on `ubuntu-asus-anka-labs` while
exact-platform jobs retain their existing hosts. SC2016 findings are
pre-existing informational reports for literal Markdown format strings in shell
summaries.
