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
- Kimi labels now use the same compact vocabulary as its quota windows: “7-day” first and “5-hour” second; other providers continue to use “Weekly” and “Session”.
- Updated the Kimi menu-card regression expectation for the label-only change; the underlying provider model order remains source-compatible while Overview applies semantic ordering.
