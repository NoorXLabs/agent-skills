# agent-skills

A collection of agent skills.

Each skill is a directory containing a `SKILL.md` (with `name` + `description` frontmatter) plus any supporting reference files. Your agent reads the `description` of every installed skill and loads the full skill only when a task matches — so installing a skill costs almost nothing until it's actually needed.

## Available skills

| Skill | What it does |
|-------|--------------|
| [`tanstack-cli`](skills/tanstack-cli/) | Uses the TanStack CLI (`@tanstack/cli`) as the source of truth for TanStack docs, libraries, add-ons, scaffolding, and ecosystem info. Replaces the deprecated TanStack MCP server. |
| [`use-codex`](skills/use-codex/) | Makes Claude the orchestrator and acceptance gate while Codex workers explore GitHub, implement and test locally, repair rejected work, and return explicit session-aware reports. |

## Installing

Install with [skills.sh](https://skills.sh).

Add a single skill from this repo:

```sh
bunx skills add https://github.com/NoorXLabs/agent-skills --skill tanstack-cli
```

Or add every skill in the repo:

```sh
bunx skills add NoorXLabs/agent-skills
```

`npx` works in place of `bunx` if you use npm. After installing, restart (or start) your agent so it picks up the new skills.

### Replacing codex-plugin-cc in Claude Code

Do not run `use-codex` and codex-plugin-cc for the same task. The plugin can
launch a second detached job lifecycle and return before Codex finishes, while
`use-codex` keeps one foreground runner responsible for one Codex process group
until completion.

Disable the plugin before using this skill as its replacement:

```sh
claude plugin disable --scope user codex@openai-codex
```

Install the replacement explicitly:

```sh
bunx skills add https://github.com/NoorXLabs/agent-skills --skill use-codex
```

Restart Claude Code, or reload plugins and skills, and confirm the session lists
`use-codex`; do not proceed through a `codex:rescue` or `/codex:status` path.
