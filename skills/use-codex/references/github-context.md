# GitHub context

Use this module for any authorized GitHub investigation during implementation,
review, or research. Give remote exploration to Codex, not Claude.

## Separate the permissions

State all three permissions independently in the worker contract:

| Capability | Normal implementation default |
|---|---|
| Read GitHub context | Allowed when relevant |
| Write the local repository | Allowed within assigned scope |
| Mutate GitHub remotely | Forbidden unless explicitly authorized |

Treat a sandbox as a filesystem and network capability boundary, not a GitHub
read-versus-write boundary. Remember that full access or network-enabled
`workspace-write` permits authenticated `gh` calls and makes remote mutations
technically possible. Keep the contract as the authorization boundary. Use an
isolated read-only GitHub credential or environment for mechanical enforcement.

## Explore with `gh`

Use the existing authenticated `gh` CLI without displaying tokens or reading
credential files. Prefer targeted commands such as:

- `gh repo view`
- `gh pr list`, `gh pr view`, `gh pr diff`, and `gh pr checks`
- `gh issue list` and `gh issue view`
- `gh run list` and `gh run view`
- `gh api --method GET ...` for REST reads
- `gh api graphql` with a `query` document, never a `mutation`
- `git fetch` when remote refs are required and the contract permits local git
  metadata changes

Discover information available from GitHub or the repository directly instead
of asking Claude to perform that exploration. Record the repository, PRs,
issues, runs, comments, commits, and URLs that materially informed the work.

Do not use mutating operations such as `gh pr create`, `merge`, `close`,
`reopen`, `edit`, `comment`, or `review`; corresponding issue or discussion
mutations; workflow dispatch; release creation; non-query GraphQL; REST methods
other than `GET`; `git push`; or branch deletion unless the user explicitly
authorized that exact class of remote change.

Avoid `gh pr checkout` or branch switching in a dirty primary checkout. Inspect
with `gh pr diff`, fetch an explicit ref, or use a dedicated worktree when the
remote branch itself is required.

## Report the evidence

Populate handoff items 2 and 7 from [worker-contract.md](worker-contract.md) with
the repository and identifiers examined, stable URLs for material context,
conclusions, authentication or missing-context failures, and exact authorized
remote mutations or none. Never expose secrets or reproduce large bodies.
