# agent-skills

A collection of agent skills.

Each skill is a directory containing a `SKILL.md` (with `name` + `description` frontmatter) plus any supporting reference files. Your agent reads the `description` of every installed skill and loads the full skill only when a task matches — so installing a skill costs almost nothing until it's actually needed.

## Available skills

| Skill | What it does |
|-------|--------------|
| [`tanstack-cli`](skills/tanstack-cli/) | Uses the TanStack CLI (`@tanstack/cli`) as the source of truth for TanStack docs, libraries, add-ons, scaffolding, and ecosystem info. Replaces the deprecated TanStack MCP server. |

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
