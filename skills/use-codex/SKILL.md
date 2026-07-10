---
name: use-codex
description: >-
  Delegate implementation, refactors, debugging, diagnosis, or research to Codex
  (gpt-5.6-sol) as a headless subagent with FULL sandbox access — network and git
  writes enabled, no approval prompts — and orchestrate several Codex instances in
  parallel. This is the repo's implementation runtime: use it whenever CLAUDE.md
  requires routing implementation/sub-agent work through Codex, when the user says
  "use codex", "run codex", "delegate to codex", "have codex do X", or when a coding
  task should be handed to Codex for execution or a second opinion. Replaces the
  removed `codex-plugin-cc` plugin, whose read-only sandbox blocked network and
  `.git` writes.
---

# Codex runtime

Drive the local `codex` CLI directly. Unlike the old plugin (which ran
`codex app-server` pinned to a read-only sandbox), you invoke `codex exec`
non-interactively with **full access** — Codex can reach the network, write files,
and commit to git without prompting.

Per CLAUDE.md, all implementation and sub-agent coding work in this repo routes
through Codex: model `gpt-5.6-sol`, reasoning effort `xhigh`. Those are the defaults
in `~/.codex/config.toml`, so a bare `codex exec` already uses them.

## Preflight (once per session, if unsure)

```bash
codex --version           # expect codex-cli >= 0.144.0
codex login status        # expect "Logged in using ChatGPT"
```

Codex auth is its own ChatGPT login — **separate** from the product's
`CLAUDE_CODE_OAUTH_TOKEN`. If not logged in, tell the user to run `codex login`
interactively; do not attempt the OAuth flow yourself.

## The one command that matters

```bash
codex exec --dangerously-bypass-approvals-and-sandbox \
  -m gpt-5.6-sol -c model_reasoning_effort=xhigh \
  --output-last-message /tmp/codex-<label>.txt \
  "<the task, written as a complete, self-contained instruction>"
```

- `--dangerously-bypass-approvals-and-sandbox` — full network + filesystem + git,
  no prompts. This is the intended default here; the machine is the user's trusted
  dev environment and the config already sets `hide_full_access_warning = true`.
  Codex can therefore read anything the user can, mutate the repo, and push — give
  it scoped tasks and always run the verification gate below.
- `-m gpt-5.6-sol -c model_reasoning_effort=xhigh` — pin the runtime AGENTS.md
  mandates for implementation work. These are already the `~/.codex/config.toml`
  defaults, but state them in the command so a config drift can't silently downgrade
  an implementation run. Do **not** lower the model or effort for implementation.
  You may drop `-c model_reasoning_effort=low` only for throwaway non-implementation
  chores (a quick lookup, a mechanical rename) where correctness isn't load-bearing.
- `--output-last-message <file>` — Codex's final answer, clean, for you to read back.
  stdout also carries the live transcript (reasoning, commands, diffs).
- The prompt is the whole contract. Codex starts cold with no chat history — state
  the goal, constraints, files in scope, and the acceptance check.

**Capturing output:** when you background or pipe a run, redirect the whole stream to
a file (`> /tmp/codex-<label>.log 2>&1`). Do **not** pipe a live `codex exec` through
`tail`/`head` — they buffer until the pipe closes, so if the run is killed (timeout,
cancel) all streamed output is lost. Read the log file instead, and prefer
`--output-last-message` for the clean final report.

### Narrower sandboxes (opt down when you don't need full access)

```bash
# Review / diagnose / research — no writes at all:
codex exec --sandbox read-only "<question>"

# Edit the workspace but not the wider system; grant network explicitly:
codex exec --sandbox workspace-write \
  -c sandbox_workspace_write.network_access=true "<task>"
```

## Getting structured results back

```bash
# Live JSONL event stream (parse programmatically):
codex exec --json ... "<task>" > /tmp/codex-events.jsonl

# Force the final message to match a JSON Schema:
codex exec --output-schema /path/to/schema.json ... "<task>"
```

## Continuing a run

```bash
codex exec resume <session-id> "<follow-up>"  # a specific session (id printed in the header)
codex exec resume --last "<follow-up>"        # ONLY when a single run exists this session
```

Use resume for "keep going", "apply your top fix", or "dig deeper" instead of
re-sending the whole context. Prefer resuming by explicit `<session-id>`. `--last`
resolves to the most recent session globally, so if more than one run is in flight
(see orchestration below) it can resume the wrong task and apply edits in the wrong
context — only use `--last` when you are certain exactly one run has happened.

## As a background job / subagent

For a long implementation you don't want to block on, run it detached and read the
output file when it finishes:

```bash
codex exec --dangerously-bypass-approvals-and-sandbox \
  -m gpt-5.6-sol -c model_reasoning_effort=xhigh \
  --output-last-message /tmp/codex-featureX.txt \
  "<task>"   # launch via Bash run_in_background; redirect stdout to a log, don't pipe to tail
```

Alternatively, spawn an `Agent` subagent whose whole job is to run one `codex exec`
call and hand back its final message — useful when you want Codex work isolated from
your own context.

## Orchestrating multiple Codex instances

**Default: run in the main working tree.** A single run, or several runs done one
after another, all happen in the repo as-is — no worktree, no ceremony. Worktrees are
an opt-in tool for exactly one situation (case 3 below), not a routine step. Only use
one when the user asks to keep work off the main tree, or when you deliberately need
concurrent writers.

1. **One task** (the common case) — just run `codex exec` in the repo. Done.

2. **Several write tasks, no rush** — run them **sequentially** in the main tree, one
   `codex exec` after another. Still no worktree; each has the tree and git index to
   itself while it runs.

3. **Genuinely concurrent writers** — the *only* case that needs isolation. Two+
   `codex exec` processes editing the repo at the same time share one working
   directory **and one git index**: their file writes interleave, and their git
   operations collide on `.git/index.lock` ("Another git process seems to be
   running"). Give each its own worktree so it has a private tree + index, then merge.
   Read tasks are exempt — you can fire many `codex exec --sandbox read-only` jobs in
   the main tree at once, since none of them write.

   ```bash
   git worktree add ../hhc-codex-a -b codex/task-a
   ( codex exec -C ../hhc-codex-a --dangerously-bypass-approvals-and-sandbox \
       -m gpt-5.6-sol -c model_reasoning_effort=xhigh \
       --output-last-message /tmp/codex-a.txt "<task A>" )
   # ...task B in ../hhc-codex-b on branch codex/task-b, in parallel...
   git worktree remove ../hhc-codex-a   # after merging
   ```

   Or launch parallel `Agent` subagents with `isolation: "worktree"`, each running
   its own `codex exec`. Split the work so tasks touch disjoint files; overlapping
   edits can still conflict at merge time.

   Caveats worktrees do **not** solve, so account for them:
   - A worktree branches from committed `HEAD` — it does **not** carry the current
     uncommitted working-tree changes. Commit or stash the baseline you want each
     instance to build on first, or the runs start from stale state.
   - Under `--dangerously-bypass-approvals-and-sandbox` the process is unsandboxed:
     it can still reach the parent repo, sibling worktrees, shared `.git` metadata,
     and the network. Worktrees isolate *files*, not the *process*. Give each run a
     tightly scoped task and pin its root with `-C`.

For concurrent writers, keep a short ledger of what each instance owns (task,
cwd/branch, session-id, output
file) so you can reconcile results and resume the right session by id.

## After Codex runs

Codex now has full write access, so it may already have edited files or committed.
**Verify its work independently** — read the diff, run the build/tests, exercise the
change — before reporting it done. Do not treat Codex's own "done" as confirmation;
that is your gate, per this repo's boundaries.
