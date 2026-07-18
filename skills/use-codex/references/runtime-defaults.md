# Runtime defaults

Edit only this file to change the skill's fallback runtime selection.

- `default_model`: `gpt-5.6-sol`
- `default_reasoning_effort`: `xhigh`

Resolve both values independently for every new run:

1. Use a model or reasoning effort explicitly supplied in the current request.
2. Otherwise use the corresponding fallback above.

For a resume, reuse the recorded model and effort exactly. If either must change,
start a new session instead of resuming.

Pass both resolved values to the bundled runner as `--model <model>` and
`--effort <effort>`; it performs the fixed CLI translation. Treat both as opaque
runtime inputs. Do not rewrite, upgrade, downgrade, infer one from the other, or
retry an explicit-value error with a fallback.

Resolve both values in the parent before launching a background Agent. Put both
literal values in the wrapper contract; do not let the wrapper choose defaults.
