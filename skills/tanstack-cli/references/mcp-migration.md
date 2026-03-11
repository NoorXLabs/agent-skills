# MCP Migration Reference

The `tanstack mcp` command was removed in CLI v0.52.0. All agent workflows now use direct CLI commands with `--json` output.

## Command Mapping

| Old MCP Tool | New CLI Command |
|---|---|
| `listTanStackAddOns` | `tanstack create --list-add-ons --framework <f> --json` |
| `getAddOnDetails` | `tanstack create --addon-details <id> --framework <f> --json` |
| `createTanStackApplication` | `tanstack create <name> --framework <f> --add-ons <a,b> -y` |
| `addAddOnToProject` | `tanstack add <id1> <id2>` |
| `tanstack_list_libraries` | `tanstack libraries --json` |
| `tanstack_doc` | `tanstack doc <library> <path> --json` |
| `tanstack_search_docs` | `tanstack search-docs "<query>" --json` |
| `tanstack_ecosystem` | `tanstack ecosystem --json` |

## Key Differences

1. **No server process** — CLI commands are stateless. Run them directly, parse the JSON output, and move on. No persistent connection needed.
2. **`--json` flag replaces MCP protocol** — all structured output comes via `--json` on stdout.
3. **`--framework` is often required** — add-on queries need a framework to return accurate compatibility data.
4. **Global install** — the CLI is installed globally. Run commands directly as `tanstack <command>`.

## Third-Party MCP Wrapper

If a user specifically needs MCP protocol support (e.g. for Claude Desktop or Cursor), a community wrapper exists at `@g7aro/tanstack-mcp` which spawns the CLI under the hood and exposes the old MCP tool interface. However, for agent skills, direct CLI invocation is simpler and avoids the extra dependency.

## Common Mistakes

- **Using `tanstack mcp start`** — This command no longer exists. It will fail.
- **Referencing old MCP tool names in code** — Replace with CLI equivalents from the mapping table above.
- **Not passing `--framework`** — Add-on availability and details are framework-specific. Omitting it may return incomplete or incorrect data.
- **Using `--integrations` instead of `--add-ons`** — The flag was renamed. Use `--add-ons`.
