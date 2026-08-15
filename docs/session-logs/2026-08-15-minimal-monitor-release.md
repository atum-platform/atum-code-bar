# Minimal monitor release handoff

The minimal-monitor branch descends from the CodexBar reconciliation branch and
is the intended product branch for the fork. It retains the Claude reliability
work while restoring the minimal limits-monitor UI.

The release build required a macOS 14 availability fallback for the
macOS 15-only `Task.detached(executorPreference:)` API in the cost-store
bridge. The fallback preserves the shared executor on macOS 15 and uses a
detached task on older supported macOS versions.

The packaged app must be built on the MacBook's newer Xcode toolchain and
installed only after package signing, resource, and Claude CLI smoke checks.

The compact Overview contract is: render at most three rows per provider, keep
the provider header compact, order weekly before session before extras, and
default Overview to all currently enabled providers so a newly enabled Kimi
row is not silently omitted by stale selection state.
