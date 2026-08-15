# CodexBar reconciliation

Date: 2026-08-15

## Canonical branch

- The owned source of truth is `anka-ventures-labs/atum-code-bar`.
- The reconciliation branch is `feat/reconcile-codexbar-upstream`, based on the
  fork's `origin/main` and merged with the current `steipete/CodexBar` upstream
  main.
- The installed `/Applications/CodexBar.app` remains the rollback baseline until
  the reconciled artifact passes hosted Xcode verification and runtime checks on
  both Macs.

## Reconciliation result

- Upstream main already contains the Claude retry/fallback and cost-store work
  that had appeared split across the fork feature branches.
- The fork-specific delta is CI routing, fork packaging, upstream monitoring, and
  the associated durable documentation.
- No compiled application bundle is treated as source; future installs must come
  from an artifact built from the canonical branch.

## Verification and next step

- The local Mac has Swift 5.10/Xcode 15.4, while the package requires Swift 6.2,
  so local compilation is not a valid release gate.
- The hosted fork-build workflow is the required build gate and must run with
  Xcode 26 before merging the reconciliation branch.
- Runtime acceptance is a successful Claude CLI fallback probe and a live
  CodexBar refresh on both the Mac mini and MacBook, with no fresh crash report.
