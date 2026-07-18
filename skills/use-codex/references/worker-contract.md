# Worker contract

Build a complete contract for every new or resumed Codex worker. Do not rely on
implied context; assume the worker cannot see Claude's conversation.

## Use this prompt shape

```text
Assignment: <label and concise task summary>
Task mode: <implementation | review | research>
Working directory: <absolute path>
Starting state: <branch/ref and relevant existing changes>
Runtime: <model> with <reasoning effort>
Execution/access: <sandbox profile and whether network is available>

Goal:
<requested outcome>

Scope and constraints:
<owned files, modules, behavior, repositories, repo instructions, compatibility,
starting constraints, and unrelated user changes that must be preserved>

Permissions:
- GitHub reads: <allowed and relevant targets | forbidden>
- Local repository writes: <allowed scope | forbidden>
- GitHub remote mutations: <forbidden | exact authorized operations>
- Commit, push, destructive actions, or scope expansion: <forbidden unless
  explicitly authorized>

Acceptance checks:
<tests, commands, required evidence, and observable completion criteria>

Perform only the authorized actions. Explore the repository and authorized
GitHub context yourself. When local writes are allowed, make the scoped changes
and test them. When local writes are forbidden, inspect and report without
modifying files. Do not ask Claude to edit files or gather context you can obtain
directly. Preserve unrelated work and report partial results or failures.
```

Authorize only the actions the task needs. Allow scoped edits only when the
contract permits them. Choose `implementation` for an
outcome that produces or repairs changes, `review` to evaluate an existing
change, and `research` for no-fix investigation; classify diagnosis by its
requested outcome. Derive access and all three permissions independently of task
mode.

## Require a structured handoff

Require the Codex final report to contain:

1. concise outcome summary
2. GitHub context consulted and conclusions drawn, or `not applicable`
3. files changed and important diff decisions, or confirmation of no changes
4. tests and checks run with exact results
5. remaining risks, failures, or unresolved questions
6. confirmation that unrelated changes were preserved
7. confirmation that no unauthorized commit, push, destructive action, or
   GitHub remote mutation occurred

Treat an incomplete report as a failed handoff. Preserve its session and
artifacts, inspect the available evidence and tree independently, then issue a
targeted correction when the original scope authorizes one.
