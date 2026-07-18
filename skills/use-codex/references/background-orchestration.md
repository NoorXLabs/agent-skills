# Background orchestration

Use this module to run Codex concurrently without requiring user status checks.

## Keep one lifecycle owner

Launch one Claude background `Agent` for each Codex run. Inside that Agent, run
exactly one foreground bundled runner; it owns one direct `codex exec` process
group through exit. Do not detach Codex, invoke plugin commands or helpers,
create a second job ID, or let the wrapper return before Codex exits.

Treat the Agent as context and lifecycle isolation only. Do not treat it as file,
git-index, worktree, or unsandboxed-process isolation.

## Give the wrapper a prebuilt invocation

Prepare the prompt artifact and render the complete runner command from
[execution.md](execution.md) before launching the wrapper, then use
this envelope:

```text
Act only as a thin Codex runner for <label>.

Working directory: <absolute cwd or worktree>

Execute exactly this prebuilt foreground command:
<complete bundled-runner command with literal artifact and cwd paths>

Do not invoke plugin skills or helpers, detach the process, solve the assignment
yourself, alter the command, or delegate again.

After the process exits, return its complete artifact directory and worker
report. Identify every failure or missing artifact.
```

Put all task-local context in the prepared prompt artifact. Do not assume a fresh
Agent sees the parent conversation or already loaded skills.

## Track and consume completion

Record for each job:

| Field | Purpose |
|---|---|
| Label and Agent ID | Route completion and cancellation |
| Cwd, worktree, and branch | Resume in the correct tree |
| Scope, permissions, access profile | Prevent overlap or escalation |
| Model and effort | Preserve runtime selection |
| Artifact paths and session ID | Recover and resume evidence |
| Status | Track `queued`, `running`, `completed`, `failed`, or `cancelled` |

After launch:

1. Continue only independent, non-overlapping work.
2. Wait for Claude Code's Agent completion notification without polling, tailing,
   sleeping, or asking the user to check back.
3. If asked early, report only that the named job remains active.
4. Require terminal process status, then collect every available artifact; treat
   a partial or missing handoff as failure evidence rather than a reason to wait.
5. Return the result to the parent for routed verification or acceptance.
6. Report completion only after every required job is terminal and reconciled.

Resolve any background Agent permission prompt in the parent. If the environment
disables background tasks, run the same wrapper in the foreground; do not create
a detached fallback.

## Handle failure and follow-up

- Preserve artifacts after invocation, permission, or partial-result failure.
- Apply the resume rule in [execution.md](execution.md); use another
  managed wrapper for a background resume.
- Cancel only through the recorded Agent handle. If cancellation does not prove
  child termination, report that uncertainty; never guess a PID or process group.
- Require an explicit label or ID before cancelling when several jobs are active.
