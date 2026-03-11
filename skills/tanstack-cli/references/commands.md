# TanStack CLI Command Reference

## Table of Contents

1. [tanstack create](#tanstack-create)
2. [tanstack add](#tanstack-add)
3. [tanstack doc](#tanstack-doc)
4. [tanstack search-docs](#tanstack-search-docs)
5. [tanstack libraries](#tanstack-libraries)
6. [tanstack ecosystem](#tanstack-ecosystem)
7. [tanstack pin-versions](#tanstack-pin-versions)
8. [tanstack addon](#tanstack-addon)
9. [tanstack starter](#tanstack-starter)

---

## tanstack create

Create a new TanStack application. By default creates a TanStack Start app with SSR.

```sh
tanstack create [project-name] [options]
```

### Options

| Flag | Description |
|---|---|
| `--framework <name>` | Framework to use (e.g. `React`, `Solid`) |
| `--add-ons <ids>` | Comma-separated add-on IDs to include |
| `--router-only` | Create a Router-only SPA (no SSR, no Start) |
| `--toolchain <name>` | Linting/formatting toolchain (`eslint`, `biome`) |
| `--deployment <target>` | Deployment target (`vercel`, `netlify`, `cloudflare`, etc.) |
| `--package-manager <pm>` | Package manager (`npm`, `pnpm`, `yarn`, `bun`, `deno`) |
| `--template <url-or-name>` | Use a starter template (URL or built-in name) |
| `--starter <url-or-path>` | Use a starter preset JSON |
| `--no-examples` | Skip example route/component generation |
| `--interactive` | Force interactive mode for add-on selection |
| `-y` | Accept all defaults (non-interactive) |
| `--list-add-ons` | List available add-ons (does not create a project) |
| `--addon-details <id>` | Show details for a specific add-on (does not create a project) |
| `--json` | Output as JSON (for agent/programmatic consumption) |
| `--git` / `--no-git` | Initialize git repository (default: true) |

### Introspection Mode (no project created)

These flags query add-on metadata without scaffolding anything — ideal for agent discovery:

```sh
# List all available add-ons as JSON
tanstack create --list-add-ons --framework React --json

# Get detailed info on one add-on (dependencies, conflicts, configurable options)
tanstack create --addon-details drizzle --framework React --json
```

### Examples

```sh
tanstack create my-app -y
tanstack create my-app --add-ons clerk,drizzle,tanstack-query
tanstack create my-app --router-only --toolchain eslint --no-examples
tanstack create my-app --template https://example.com/template.json
tanstack create my-app --template ecommerce
```

---

## tanstack add

Add add-ons to an existing project. Run from the project root.

```sh
tanstack add <addon-id> [addon-id...] [options]
```

### Options

| Flag | Description |
|---|---|
| `--framework <name>` | Target framework |
| `--json` | Output as JSON |

### Examples

```sh
tanstack add clerk drizzle
tanstack add tanstack-query sentry
```

---

## tanstack doc

Fetch a TanStack documentation page by library and path. Returns the full content of the doc page.

```sh
tanstack doc <library> <path> [options]
```

### Options

| Flag | Description |
|---|---|
| `--docs-version <version>` | Documentation version (e.g. `v5`) |
| `--json` | Output as JSON |

### Arguments

- `<library>` — The TanStack library ID (e.g. `router`, `query`, `start`, `table`, `form`, `virtual`, `store`, `db`, `ai`, `pacer`, `hotkeys`, `devtools`, `cli`)
- `<path>` — The doc page path within that library (e.g. `framework/react/guide/data-loading`, `framework/react/overview`)

### Examples

```sh
tanstack doc router framework/react/guide/data-loading
tanstack doc query framework/react/overview --docs-version v5 --json
tanstack doc start framework/react/guide/server-functions --json
```

### Tips

- Use `tanstack search-docs` first if you don't know the exact path
- The path structure typically follows: `framework/<framework>/guide/<topic>` or `framework/<framework>/reference/<api>`
- Use `tanstack libraries --json` to get valid library IDs

---

## tanstack search-docs

Search TanStack documentation across libraries.

```sh
tanstack search-docs "<query>" [options]
```

### Options

| Flag | Description |
|---|---|
| `--library <id>` | Limit search to a specific library |
| `--framework <name>` | Filter by framework (e.g. `react`, `solid`) |
| `--json` | Output as JSON |

### Examples

```sh
tanstack search-docs "server functions" --library start --json
tanstack search-docs loaders --library router --framework react --json
tanstack search-docs "mutations" --library query --json
tanstack search-docs "virtual scroll" --library virtual --json
```

---

## tanstack libraries

List all TanStack libraries with metadata (versions, descriptions, docs links).

```sh
tanstack libraries [options]
```

### Options

| Flag | Description |
|---|---|
| `--json` | Output as JSON |

### Example

```sh
tanstack libraries --json
```

---

## tanstack ecosystem

List ecosystem partner recommendations (auth providers, databases, ORMs, deployment targets, etc.).

```sh
tanstack ecosystem [options]
```

### Options

| Flag | Description |
|---|---|
| `--json` | Output as JSON |

### Example

```sh
tanstack ecosystem --json
```

---

## tanstack pin-versions

Pin TanStack package versions to avoid conflicts. Removes `^` from version ranges for TanStack packages and adds any missing peer dependencies.

```sh
tanstack pin-versions
```

Run from the project root. Useful after upgrading or when encountering version mismatch issues.

---

## tanstack addon

Create and manage custom add-ons.

```sh
tanstack addon init [name]
```

Creates a `.add-on/` folder with `info.json` and `assets/`. See the "Creating Add-ons" docs for the full authoring guide.

---

## tanstack starter

Create reusable project starters (preset configurations).

```sh
# Initialize starter from current project
tanstack starter init

# Compile starter after editing starter-info.json
tanstack starter compile
```

### Workflow

1. Create a project with your desired setup: `tanstack create my-preset --add-ons clerk,drizzle,sentry`
2. Initialize: `cd my-preset && tanstack starter init`
3. Edit `starter-info.json` (name, description, banner)
4. Compile: `tanstack starter compile`
5. Use: `tanstack create new-app --starter ./starter.json`

---

## Global Notes

- **`--json` flag**: Available on all introspection/query commands. Always use it when parsing output programmatically.
- **Global install**: The CLI is installed globally via bun (`bun add -g @tanstack/cli`). Run commands directly as `tanstack <command>`.
- **Visual builder**: For interactive visual setup, direct users to https://tanstack.com/builder
- **Framework support**: React is the default and most complete. Solid is also supported. Always specify `--framework` when querying framework-specific data.
