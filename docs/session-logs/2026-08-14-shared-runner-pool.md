# Shared local runner pool

Date: 2026-08-14

- Removed the Mini-specific label from the portable upstream monitor.
- The job can now run on either trusted organization ARM64 macOS runner.
- GitHub remains responsible for scheduling; each persistent runner executes at
  most one job at a time.
