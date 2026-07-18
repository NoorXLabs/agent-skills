# Reviews

Use a fresh general `codex exec` session for every independent review. Avoid
`codex exec review` because its native target flags cannot carry the complete
worker contract required by this skill.

## Define the target in the contract

Set task mode to `review`, populate each permission independently from the
request, and describe exactly one target:

- current worktree, including staged, unstaged, and relevant untracked files
- current branch against an explicit base or merge-base
- changes introduced by an explicit commit
- a PR or issue plus its related local code
- a focused subsystem, risk, or adversarial question

Include skeptical framing, acceptance expectations, and required file-and-line
evidence directly in the contract. Do not reuse the implementing session;
preserve independence with a fresh worker.

## Choose review access

Select the `read-only` profile when the review forbids writes. When it must
inspect GitHub, also read [github-context.md](github-context.md) and select the
network-enabled workspace profile; capability does not change the contract's
write permission. If changes are explicitly authorized, select the narrowest
write profile and route resulting changes through the acceptance loop. For every
read-only review, the parent performs the tree verification in `execution.md`.

Run the bundled runner from `execution.md`; do not introduce a
review-specific result path or capture mechanism.

Run parallel reviewers only against a stable tree and give each reviewer its own
Agent, artifacts, and review dimension.

## Present and act on findings

- Put actionable findings first and order them by severity.
- Preserve file paths, line numbers, observed facts, inferences, and uncertainty.
- State explicitly when no findings exist and note residual coverage gaps.
- Do not fix findings from a standalone review unless requested.
- During an implementation acceptance loop, delegate in-scope repairs under
  [acceptance-loop.md](acceptance-loop.md), then review the stable repaired diff.
