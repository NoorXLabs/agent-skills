---
name: tanstack-cli
description: Use the TanStack CLI as the authoritative source of truth for anything TanStack-related. Trigger this skill whenever the user asks about TanStack libraries (Router, Start, Query, Table, Form, Virtual, Store, DB, AI, Pacer, Hotkeys, Devtools), scaffolding TanStack projects, TanStack add-ons/integrations (auth, database, deployment, ORM, styling), searching TanStack documentation, or building with TanStack Start/Router. Also trigger when the user mentions tanstack create, tanstack add, tanstack doc, tanstack search-docs, TanStack CLI, TanStack MCP, or asks about available TanStack integrations, ecosystem partners, or how to set up a TanStack project. This skill replaces the deprecated TanStack MCP server — always use CLI commands instead. Even if the question seems simple (e.g. "how do I add Clerk to my TanStack app"), use this skill because the CLI provides the canonical, up-to-date answer.
---

# TanStack CLI — Agent Skill

The TanStack CLI (`@tanstack/cli`) is the single source of truth for TanStack documentation, library metadata, add-on details, project scaffolding, and ecosystem information. The old `tanstack mcp` command has been removed — all agent workflows now go through direct CLI commands.

**Every answer about TanStack should be informed by CLI output, not by training data alone.** Training data may reference outdated APIs, removed features, or old package names. The CLI reflects the current state of TanStack.

## Prerequisites

The TanStack CLI is installed globally. Run commands directly:

```sh
tanstack <command>
```

If reinstallation is ever needed: `bun add -g @tanstack/cli`

## Core Workflow

When the user asks a TanStack question, follow this decision tree:

1. **"How do I do X with TanStack Router/Start/Query/etc?"** → Run `tanstack search-docs` and/or `tanstack doc` to get authoritative documentation content. Present the result.
2. **"What add-ons/integrations are available?"** → Run `tanstack create --list-add-ons --json` to get the current list.
3. **"Tell me about the X add-on"** → Run `tanstack create --addon-details <id> --json` to get dependencies, conflicts, options.
4. **"Create/scaffold a project"** → Use `tanstack create` with appropriate flags.
5. **"Add X to my existing project"** → Use `tanstack add <id>`.
6. **"What TanStack libraries exist?"** → Run `tanstack libraries --json`.
7. **"What ecosystem partners are available?"** → Run `tanstack ecosystem --json`.
8. **"Pin my TanStack versions"** → Run `tanstack pin-versions`.

Always append `--json` when you need machine-readable output for parsing. The JSON output is designed for agent consumption.

## Command Reference

Read `references/commands.md` for the full CLI command reference with all flags and options.

## Critical Rules

1. **Never use `tanstack mcp`** — it was removed in v0.52.0. Any references to it in older docs or threads are outdated.
2. **Always use `--json` for programmatic access** — this flag is available on introspection commands and returns structured data.
3. **Use `--framework` when relevant** — add-ons are framework-specific. Default is React but Solid is also supported. Always pass the framework flag when querying add-ons to get accurate results.
4. **The `tanstack doc` command is your primary docs tool** — it fetches full documentation page content by library and path. Use `tanstack search-docs` first if you don't know the exact path.
5. **Prefer CLI output over training data** — if there's a conflict between what the CLI returns and what you "know", trust the CLI.

## Example Agent Workflows

### User asks: "How do I set up data loading in TanStack Router?"

```sh
# First, search for relevant docs
tanstack search-docs "data loading" --library router --framework react --json

# Then fetch the full doc page
tanstack doc router framework/react/guide/data-loading --json
```

### User asks: "What auth options does TanStack support?"

```sh
# List all add-ons and filter for auth category
tanstack create --list-add-ons --framework React --json

# Get details on a specific auth add-on
tanstack create --addon-details clerk --framework React --json
tanstack create --addon-details better-auth --framework React --json
```

### User asks: "Create a new TanStack Start app with Clerk, Drizzle, and Query"

```sh
tanstack create my-app --add-ons clerk,drizzle,tanstack-query -y
```

### User asks: "Add Sentry to my existing TanStack project"

```sh
tanstack add sentry
```

### User asks: "What version of TanStack Query is latest?"

```sh
tanstack libraries --json
```

## MCP Migration Reference

If the user or their tooling references the old MCP server, redirect them to CLI equivalents. See `references/mcp-migration.md` for the full mapping table.
