---
name: tanstack-cli
description: Use the TanStack CLI as the authoritative source of truth for anything TanStack-related. Trigger this skill whenever the user asks about TanStack libraries (Router, Start, Query, Table, Form, Virtual, Store, DB, AI, Pacer, Hotkeys, Devtools), scaffolding TanStack projects, TanStack add-ons/integrations (auth, database, deployment, ORM, styling), searching TanStack documentation, or building with TanStack Start/Router. Also trigger when the user mentions tanstack create, tanstack add, tanstack doc, tanstack search-docs, TanStack CLI, TanStack MCP, or asks about available TanStack integrations, ecosystem partners, or how to set up a TanStack project. This skill replaces the deprecated TanStack MCP server — always use CLI commands instead. Even if the question seems simple (e.g. "how do I add Clerk to my TanStack app"), use this skill because the CLI provides the canonical, up-to-date answer.
---

# TanStack CLI — Agent Skill

The TanStack CLI (`@tanstack/cli`) is the single source of truth for TanStack documentation, library metadata, add-ons, project scaffolding, and ecosystem info. The old `tanstack mcp` command has been removed — all workflows go through direct CLI commands.

**Answer TanStack questions from CLI output, not training data alone.** Training data may reference outdated APIs, removed features, or old package names. When CLI output conflicts with what you "know", the CLI wins. Append `--json` on introspection commands for machine-readable output built for agent parsing.

## Prerequisites

The CLI is installed globally — run `tanstack <command>` directly. If reinstall is needed: `bun add -g @tanstack/cli`. For install, project-creation, or runtime failures, see `references/troubleshooting.md`.

## Command Routing

Match the user's intent to a command below, then read `references/commands.md` for the exact flags, options, and examples before running it.

| User intent | Command |
|---|---|
| How do I do X with Router/Start/Query/etc? | `tanstack search-docs` to locate, then `tanstack doc <library> <path>` for full content |
| What add-ons/integrations exist? | `tanstack create --list-add-ons --framework <React\|Solid> --json` |
| Tell me about the X add-on | `tanstack create --addon-details <id> --framework <React\|Solid> --json` |
| Create/scaffold a project | `tanstack create <name> [--add-ons …] [flags]` |
| Add X to an existing project | `tanstack add <id...>` |
| Build/manage a custom add-on | `tanstack add-on init` / `tanstack add-on compile` |
| Create/manage a project template | `tanstack template init` / `tanstack template compile` |
| What libraries exist / latest versions? | `tanstack libraries --json` |
| What ecosystem partners exist? | `tanstack ecosystem --json` |
| Pin my TanStack versions | `tanstack pin-versions` |
| Scaffold from an edge/Worker runtime | Programmatic `@tanstack/create/worker` API |

## Canonical docs workflow

Most documentation questions follow search → fetch:

```sh
tanstack search-docs "data loading" --library router --framework react --json
tanstack doc router framework/react/guide/data-loading --json
```

## Critical Rules

1. **Never use `tanstack mcp`** — it was removed from the CLI. Redirect any old MCP references using `references/mcp-migration.md`.
2. **Use `--json` for programmatic access** — available on introspection commands and designed for agent consumption.
3. **Pass `--framework` when querying add-ons** — add-ons are framework-specific (`React` is the default, `Solid` is also supported), so results differ by framework.
4. **`tanstack doc` is the primary docs tool** — it fetches full page content by library + path. Run `tanstack search-docs` first if you don't know the path.
5. **Trust the CLI over training data** — on any conflict, the CLI output is canonical.

## Reference Files

- `references/commands.md` — full command reference: every command, all flags, `tanstack create` examples, programmatic/Worker (`@tanstack/create/worker`) generation, and the `.tanstack.json` config format.
- `references/mcp-migration.md` — mapping from each removed MCP tool to its CLI equivalent, plus the recommended JSON-based agent workflow.
- `references/troubleshooting.md` — installation, project-creation, and runtime fixes; MCP-removal notes; and what to include when reporting issues.
