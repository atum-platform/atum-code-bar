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

Metric ordering is based on each window's duration (weekly, then session, then
other windows), not the provider-neutral `primary`/`secondary` field names.
This matters for Kimi, whose primary snapshot lane is weekly and secondary
lane is its five-hour session quota.

The ordering helper is covered by the production MacBook build before
installation; the Mac mini's older Xcode cannot compile the Swift 6.2 package.

Credential ownership is provider-specific: Claude is read from the Claude CLI
credential source, while Kimi is read from Kimi Code CLI's
`~/.kimi-code/credentials/kimi-code.json`. CodexBar intentionally does not
refresh Kimi-owned OAuth credentials. An expired Kimi token therefore requires
`kimi login`; the monitor now keeps an enabled provider visible in Overview
even when its credential is expired, so the failure is actionable rather than
silently hiding the provider.
