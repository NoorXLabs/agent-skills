---
name: use-codex
description: >-
  Delegate implementation, refactoring, debugging, diagnosis, research, or code
  review to local Codex CLI workers while Claude Code scopes, orchestrates, and
  independently accepts results. Use when the user says "use codex", "run
  codex", or "delegate to codex"; requests Codex subagents or a second opinion;
  or repository instructions require Codex. This direct-CLI skill replaces
  codex-plugin-cc; never combine the runtimes.
---

# Use Codex

## Enforce the role boundary

- Keep Claude as the control plane: scope tasks, launch workers, inspect status
  and diffs, run acceptance checks, and approve or reject results.
- Make Codex the execution plane: explore the repository and GitHub, implement,
  test, repair rejected work, and perform source-changing integration.
- Do not have Claude create or edit source files, apply patches, resolve source
  conflicts, or make corrective changes, even when the fix looks trivial.
- Allow Claude to run read-only inspection and verification commands and manage
  worker, session, and worktree lifecycles. Delegate every source change back to
  Codex.
- Treat GitHub reads, local repository writes, and GitHub remote mutations as
  three separate permissions. Forbid remote mutations unless the user explicitly
  authorizes them.

## Route the run

Read only the references needed for the request:

- Before every new or resumed worker, read
  [references/runtime-defaults.md](references/runtime-defaults.md),
  [references/worker-contract.md](references/worker-contract.md), and
  [references/execution.md](references/execution.md). Select model and effort for
  a new run, including review; preserve both recorded values for a resume.
- When the worker must investigate a GitHub repository, PR, issue, discussion,
  run, or other remote context, read
  [references/github-context.md](references/github-context.md).
- After any worker changes files, read
  [references/acceptance-loop.md](references/acceptance-loop.md).
- For a long-running job or any work that should continue while Claude does
  something else, also read
  [references/background-orchestration.md](references/background-orchestration.md).
- For code review, second opinions, or adversarial no-fix analysis, read
  [references/reviews.md](references/reviews.md).
- For two or more concurrent Codex runs, read
  [references/concurrent-runs.md](references/concurrent-runs.md) and
  [references/background-orchestration.md](references/background-orchestration.md).

## Own the execution path

Invoke local `codex` directly; never use codex-plugin-cc commands, helpers, jobs,
status checks, rescue paths, or runtime for a task governed by this skill.
