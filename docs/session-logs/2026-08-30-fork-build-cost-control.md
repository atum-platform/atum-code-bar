# Fork-build cost control — 2026-08-30

## Context

August billing showed a one-day spike in GitHub-hosted macOS runner use. The
`Fork app build` workflow ran alongside normal CI for every ready pull request,
including same-repository and Dependabot branches. Normal CI already owns those
trusted pull requests and performs the macOS Swift test lane when its path gate
requires it.

## Change

Limit the automatic `Fork app build` job to ready, external-fork pull requests.
Keep `workflow_dispatch` available for an explicit package check. This preserves
the existing macOS packaging path for untrusted fork contributions while
removing duplicate 20–30 minute macOS jobs from ordinary internal pull requests.

No check name, test command, artifact, release workflow, or normal CI gate was
changed. GitHub's existing budget email alerts remain the spending-warning
mechanism; no custom billing monitor was added.

## Verification

- Parsed `.github/workflows/fork-build.yml` as YAML.
- Evaluated the job predicate against representative workflow-dispatch,
  internal-PR, external-fork-PR, draft, and converted-to-draft event shapes.
- Inspected recent Actions history: internal and Dependabot pull requests had
  been running both `CI` and `Fork app build`, with the latter consuming about
  20–30 hosted macOS minutes per run.

## Follow-up

Measure the next several pull requests in GitHub billing. Internal pull requests
should show `Fork app build` as skipped, external ready fork pull requests should
still run it, and manual dispatches should remain available.
