# Concurrent Codex runs

Use concurrency only for independent work. Give each foreground Codex process
one Claude background Agent. Keep reconciliation with the parent Claude.

## Select isolation by access pattern

| Runs | Same checkout? | Rule |
|---|---:|---|
| Reader + reader | Yes, if the tree is stable | Run in parallel |
| Writer + reader | No reliable stable view | Sequence them or review a separate snapshot |
| Writer + writer | No | Run sequentially or use separate worktrees |

Prefer one writer plus readers sequenced afterward or isolated on separate
snapshots to avoid merge work and keep the final verification boundary clear.

## Run concurrent writers safely

Give each writer:

- a distinct worktree and branch based on the exact intended ref
- disjoint file or module ownership
- its own background Agent, cwd, artifacts, and Codex session ID
- explicit acceptance and verification checks

Verify the baseline inside every worktree. Remember that a new worktree omits the
parent checkout's uncommitted changes and that Claude Code may select a different
default base. When the exact base matters, create the worktree explicitly from
that ref and pass its absolute cwd to the Agent.

Do not commit or stash user changes merely to prepare concurrency. If there is no
authorized clean baseline that contains the required starting state, fall back to
sequential runs in the main checkout.

Treat worktrees as working-file and index isolation, not process isolation. Pin
each Codex cwd with `-C` or the Agent working directory and keep the prompt
tightly scoped. Remember that full-access Codex can reach the parent repo,
sibling worktrees, shared git metadata, and the network.

## Reconcile before reporting

Maintain the ledger from
[background-orchestration.md](background-orchestration.md), including ownership
and branch for every run. Wait for all required completion notifications, then:

1. Reject or resolve overlapping changes deliberately.
2. Assign a Codex integration worker to integrate completed branches one at a
   time and resolve source conflicts. Do not have Claude author the integration
   or let an unassigned worker merge another worker's branch.
3. Have Claude inspect the combined diff after each integration.
4. Run tests and checks against the combined result, not only each isolated branch.
5. Remove worktrees only after their results are integrated or intentionally
   discarded and recovery is no longer needed.

Have Claude coordinate and accept the combined result without writing or
resolving it.
