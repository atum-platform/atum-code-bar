# CodexBar canonical release reconciliation — 2026-08-27

## Decision

The reproducible release source is `feat/canonical-release-0552`, based on
`upstream/main` at `ea4a72f5d` (CodexBar 0.55.2, build 131). The older
`feat/reconcile-codexbar-upstream` line was not used because it advertised
0.49.x and would have downgraded the installed 0.55.1/build 130 application.

The release branch ports the compact minimal Overview, weekly → session →
other metric ordering, visible unavailable-provider rows, Codex reset-credit
display, and durable Kimi CLI credential refresh/endpoint protection from the
pushed minimal-monitor work. Claude credential handling remains inherited from
the 0.55.2 upstream base.

## Provenance and verification

- Prior installed baseline on both Macs: CodexBar 0.55.1/build 130,
  main-binary SHA256 `e73bc2e832be546f40432623dae299014048b80dc1f4a83ee6ef4db814792fa2`.
- Kimi review job `8289c0c5-c7d0-4072-81cb-c643c9483d8d` correctly identified
  the downgrade risk, but inspected the stale reconciliation checkout rather
  than this release branch. Its security notes remain applicable: Kimi CLI
  credentials are read-only, custom endpoint forwarding is blocked, and
  refresh must remain single-flight.
- The package is built on the MacBook with Xcode, because the local Mac mini
  toolchain cannot compile this Swift package. The exact artifact must pass
  deep code-sign verification and identical SHA256 checks on both Macs before
  installation.

## Operational notes

SwiftPM dependency mirrors were repaired on the MacBook after incomplete
network clones. The repaired caches are local build state only and are not
part of the product source. No credential values are copied or committed;
Claude and Kimi continue to use each machine's own existing credential stores.

The 0.55.1/build 130 application remains the rollback baseline until the new
artifact passes packaging and dual-machine usage probes.
## Overview and first-run discovery follow-up

- Removed the inline Usage & Spend summary from the Overview menu so Overview remains a compact quota monitor.
- Restored a compact Codex “Limit Reset Credits · N available” line when reset credits exist.
- Normalized Overview metric ordering to weekly first, session second, then other lanes, while preserving provider-specific extra-lane curation.
- Extended first-run provider discovery to Kimi Code credentials/CLI and made discovery additive; a manual re-run can enable newly found providers without disabling an existing explicit provider choice.
- Menubar icon investigation: the icon renderer is shared with upstream; the observed visual drift is in the compact merged/provider presentation path and persisted settings, not a missing bundle asset. Final artifact verification remains pending.
- Follow-up: Overview ordering is semantic rather than slot-based for Kimi (7-day before 5-hour), and Claude scoped weekly lanes such as “Fable only” are prioritized over lower-priority extras when compact rows are capped.
- Kimi now uses the same displayed vocabulary as every other provider: “Weekly” first and “Session” second; its 7-day/5-hour API semantics remain internal to ordering and pacing.
- Corrected Kimi’s menu-card slot-to-label mapping so the weekly primary slot is visibly “Weekly” and the 5-hour secondary slot is visibly “Session”.
- Updated the Kimi menu-card regression expectation for the label-only change; the underlying provider model order remains source-compatible while Overview applies semantic ordering.
- Packaged and installed the final exact 0.55.2/build 131 arm64 bundle on both Macs; both main binaries verified at SHA-256 `8d2f91aaa1d4f48c2aef9d1619054de59ec097fb8ea546232e878d7da485baa5` and deep code-sign verification passed.
- Post-install probes: Kimi returned live 7-day/5-hour usage on both Macs; Claude returned live usage on this Mac, while the MacBook reported its existing OAuth credential expired and needs `claude login`. No credential material was copied or modified.
- Discovery follow-up: first-run detection also enables first-party providers with configured API, cookie, workspace, or token-account evidence, covering configured providers beyond the built-in CLI/app probes without persisting or exposing secret values.
- Follow-up correction: Kimi metric construction now labels the primary weekly
  quota `Weekly` and secondary short quota `Session` at the model layer, so
  both full cards and compact Overview consistently use weekly → session order.
- The local mini cannot run package tests because it has Swift 5.10 while this
  package requires Swift 6.2; compatible verification remains on the MacBook
  build host.
- Built the corrected arm64 app on the MacBook; source compilation and deep
  code-sign verification passed. The package launch smoke check was limited by
  its intentionally unreadable isolated build-root probe, not by a launch or
  signing failure.
- Installed the corrected bundle on both Macs with macOS metadata-preserving
  copy; both running app main binaries match SHA-256
  `d31befe7cb8896615a4cc2c0addd108266d71ff6d1e497b4b0e26467dda868ac`.
