# Execution and runtime

## Check the runtime only when needed

On the first run of a session, or after an invocation failure, run
`codex --version` and `codex login status`. If Codex is not authenticated, tell
the user to run `codex login` interactively; do not attempt the OAuth flow.

## Choose one access profile

Select the narrowest profile that supports the worker contract:

| Profile | New run | Resume | Shell capability |
|---|---|---|---|
| `read-only` | `--sandbox read-only` | `sandbox_mode=read-only` | local reads only |
| `workspace-write-no-shell-network` | workspace-write plus network `false` | same | scoped local writes |
| `workspace-write-network` | workspace-write plus network `true` | same | scoped writes and `gh` |
| `full` | `--sandbox danger-full-access` | `sandbox_mode=danger-full-access` | wider authorized access |

The runner supplies resume sandbox modes through `--config`, ignores user config
and exec-policy rules, and disables plugins, apps, browsers, computer use, image
tools, hooks, and Codex subagents. Trusted project config can still expose legacy
`notify` or MCP processes, so treat these as shell sandbox profiles rather than
complete process isolation. The Codex service itself still requires network.
Keep capability distinct from authorization and forbid unapproved remote writes.

## Prepare the prompt and artifacts

Resolve [../scripts/run-codex.sh](../scripts/run-codex.sh) relative to this skill;
never assume an install path. Have the parent create and record a unique artifact
directory outside the repository root:

```bash
job_dir="$(bash "$runner" --prepare --cwd "$worker_cwd")" || exit 1
```

Use a non-shell file-writing tool to put the complete contract from
[worker-contract.md](worker-contract.md) in `job_dir/prompt.md`; never interpolate
task or user text into a shell command. Lifecycle artifacts are not source edits.
Shell-quote every substituted path.

## Run and capture a new task

Pass recorded literal values to the runner:

```bash
bash "$runner" --cwd "$worker_cwd" --artifacts "$job_dir" \
  --model "$codex_model" --effort "$codex_effort" --access "$access_profile"
```

The foreground runner owns one direct Codex process group, waits synchronously,
and never detaches it. It binds Codex to the canonical `worker_cwd`, reads only `prompt.md` from
stdin, separates JSONL, stderr, and the final message, persists `exit-code`, and
prints the artifact path. Setup failures after safe artifact validation receive
the same evidence files; for earlier preflight failures, use the terminal runner
status and stderr. For every run:

- extract exactly one nonempty `thread_id` from the event whose `type` is
  `thread.started`
- require terminal process status and a readable final message
- treat a zero exit with a missing final message as a failed handoff

For every read-only task, have the parent record status, diffs, and hashes of
relevant untracked files before launch and compare them again after terminal
status. Treat the worker's no-change statement as evidence, not verification.

## Resume without escalating access

Resume only the explicit, inactive session whose recorded cwd or worktree, model,
effort, access profile, permissions, and scope remain unchanged. Otherwise start
a fresh session. Never use `--last` when multiple sessions may be eligible.

Create and record a distinct artifact directory and `prompt.md` as above, then
run the same command with `--resume SESSION_ID`. The runner uses the recorded
profile's resume form and capture protocol.

Return the report, runtime evidence, session ID, and artifact directory to the
orchestrator.
