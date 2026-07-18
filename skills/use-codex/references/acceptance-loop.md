# Acceptance loop

Use this module only after a Codex worker changes the repository. Keep the
verdict with Claude and every repair with Codex.

## Inspect independently

Wait for terminal worker status. Then inspect the available artifacts and tree
to determine whether the handoff is complete, partial, or missing. Have Claude:

1. inspect `git status`, staged and unstaged diffs, and relevant untracked files
2. compare the implementation with the original scope and acceptance criteria
3. read enough surrounding code to evaluate correctness and integration
4. run proportionate independent tests, lint, typecheck, build, or reproduction
   commands after every implementation or repair; if no runnable check exists,
   document why and perform the strongest available static verification
5. check for unrelated changes and unauthorized commits, pushes, destructive
   actions, or GitHub remote mutations

Treat the worker's report as evidence, not proof.

## Issue a verdict

Choose one outcome:

- **Approve** only when the diff is scoped, acceptance checks pass, the report is
  complete, and residual risks are acceptable.
- **Reject with comments** when the implementation is repairable within the
  original scope.
- **Escalate** when a correction requires new authority or a material scope
  change, including when missing user intent or external state makes either
  necessary.

For rejection, send the worker concrete feedback containing the observed
problem, file and line or behavior, expected result, and the check that will
prove the repair. Do not prescribe an implementation unless the design choice is
part of the acceptance requirement.

Apply the resume rule in [execution.md](execution.md). Even when
eligible, start fresh when independence, a different approach, or clean context
matters.

Treat the original implementation request as authorization for repair iterations
inside its scope. Do not interrupt the user for each rejection. Ask only when a
repair needs new authority or materially changes the requested outcome.

After each repair, repeat the full inspection against the combined current diff.
Keep Claude as the final acceptance gate even when a fresh Codex reviewer is
also used.
