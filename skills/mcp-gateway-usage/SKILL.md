---
name: MCP Gateway Usage
description: This skill should be used when the user asks about "MCP Gateway", "managing multiple MCP servers", "execute_child_tool", "children_config.json/children_config.toml", "child server configuration", "unified MCP access", "get_schema from child servers", "list registered children", or mentions integrating serena, context7, codegraph, or other child MCP servers through a gateway.
version: 0.1.0
---

# MCP Gateway Usage

## Overview

MCP Gateway is a parent MCP (Model Context Protocol) server that manages multiple child MCP servers and provides unified access to their tools and resources. Instead of configuring each MCP server separately in Claude Code, configure MCP Gateway once and let it handle session management, tool execution, and schema retrieval across all child servers.

**Core benefits:**
- **Unified interface**: Access tools from multiple child servers through a single gateway
- **Session management**: Automatic startup, persistent sessions, and cleanup
- **Output control**: Optional truncation with head/tail parameters
- **Centralized configuration**: Manage all child servers in one config file

**Available tools:**
- `execute_child_tool` - Execute tools from child servers with optional output truncation
- `get_schema` - Retrieve tool and resource schemas from child servers
- `list_registered_children` - List all available child servers
- `get_child_status` - Check startup status and errors
- `close_child_session` - Explicitly terminate child sessions

## Installation

### Prerequisites

MCP Gateway requires the following:
- Python package manager: [uv](https://github.com/astral-sh/uv)
- Git for cloning the repository

### Installation Methods

**Method 1: Direct installation with uvx (recommended)**

Use uvx to run MCP Gateway directly from GitHub without cloning. Point `--children-config` to either a JSON or TOML config file:

```bash
uvx --from git+https://github.com/TomCat2357/MCPgateway mcp-gateway --children-config /path/to/children_config.json
```

This method is ideal for production use and simplifies deployment.

**Method 2: Local development**

Clone and install for development or customization:

```bash
git clone https://github.com/TomCat2357/MCPgateway
cd MCPgateway
uv sync
```

Run locally:

```bash
uv run mcp-gateway --children-config /path/to/children_config.toml
```

### Verify Installation

Test that MCP Gateway is accessible:

```bash
uvx --from git+https://github.com/TomCat2357/MCPgateway mcp-gateway --help
```

Expected output shows available command-line options including `--children-config` and `--children-abstract`.

## Configuration

### MCP Gateway Configuration

Configure MCP Gateway in Claude Code or Codex CLI configuration files. Use the plugin commands for automated setup:

- `/mcp-gateway:add-to-config` - Add MCP Gateway to .mcp.json or .toml files

**Claude Code (.mcp.json) example:**

```json
{
  "mcpServers": {
    "mcp-gateway": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/TomCat2357/MCPgateway",
        "mcp-gateway",
        "--children-config",
        "/absolute/path/to/children_config.json"
      ]
    }
  }
}
```

**Codex CLI (.toml) example:**

```toml
[mcp-servers.mcp-gateway]
command = "uvx"
args = [
  "--from",
  "git+https://github.com/TomCat2357/MCPgateway",
  "mcp-gateway",
  "--children-config",
  "/absolute/path/to/children_config.json"
]
```

**Critical notes:**
- Use absolute paths for `children_config.json` or `children_config.toml`
- The path must be accessible from Claude Code's working directory
- For local development, use `uv run mcp-gateway` instead of `uvx`

### Children Configuration

Create `children_config.json` **or** `children_config.toml` to define child MCP servers. Use the plugin command for template generation:

- `/mcp-gateway:generate-children-config` - Generate children_config template (JSON or TOML)

**Basic structure (choose JSON or TOML):**

```json
[
  {
    "name": "server-name",
    "command": "executable",
    "args": ["arg1", "arg2"],
    "env": {
      "ENV_VAR": "value"
    }
  }
]
```

```toml
[[children]]
name = "server-name"
command = "executable"
args = ["arg1", "arg2"]

[children.env]
ENV_VAR = "value"
```

**Field descriptions:**
- `name` (required): Unique identifier for the child server
- `command` (required): Executable command (npx, python, node, etc.)
- `args` (required): Array of command arguments
- `env` (optional): Environment variables for the child server

**Example with serena (both formats):**

```json
[
  {
    "name": "serena",
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-serena"],
    "env": {}
  }
]
```

```toml
[[children]]
name = "serena"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-serena"]

[children.env]
# Optional: SERENA_WORKSPACE = "${HOME}/projects"
```

For complete working examples with multiple child servers, see `examples/children_config_*.json` and `examples/children_config_*.toml`.

## Usage Patterns

### Executing Child Tools

Use `execute_child_tool` to invoke tools from child servers:

```
/mcp-gateway:execute-tool <child_name> <tool_name> [args_json]
```

**Parameters:**
- `child_name`: Name of the child server (from children_config.json / children_config.toml)
- `tool_name`: Tool to execute on the child server
- `args_json`: JSON object with tool arguments (optional)
- `head`: Number of lines from start to include (optional)
- `tail`: Number of lines from end to include (optional)

**Example: Search code with serena**

```
/mcp-gateway:execute-tool serena search_code '{"query": "function main", "case_sensitive": false}'
```

**Example: With output truncation**

```
/mcp-gateway:execute-tool serena search_code '{"query": "import", "head": 50, "tail": 20}'
```

This returns first 50 and last 20 lines of output, useful for large result sets.

### Retrieving Schemas

Get tool and resource schemas from child servers:

```
/mcp-gateway:get-schema <child_name>
```

**Returns:**
- Available tools with their parameters
- Available resources with their URIs
- Schema definitions for complex types

**Example:**

```
/mcp-gateway:get-schema serena
```

Use this to discover what tools and resources each child server provides.

### Listing Child Servers

View all registered child servers:

```
/mcp-gateway:list-children
```

**Returns:**
- Names of all configured child servers
- Configuration status for each server

### Checking Server Status

Check if a child server started successfully:

```
/mcp-gateway:get-status <child_name>
```

**Returns:**
- Startup success/failure status
- Error messages if startup failed
- Connection state

**Example:**

```
/mcp-gateway:get-status serena
```

Use this to troubleshoot child server startup issues.

### Session Management

Explicitly close child server sessions:

```
/mcp-gateway:close-session <child_name>
```

**Use cases:**
- Free resources after intensive operations
- Reset child server state
- Force reconnection

**Note:** MCP Gateway manages sessions automatically. Explicit closure is rarely needed.

## Workflow Examples

### Initial Setup Workflow

1. Install MCP Gateway (uvx or local clone)
2. Generate children configuration template:
   ```
   /mcp-gateway:generate-children-config
   ```
3. Edit `children_config.json` or `children_config.toml` to add child servers
4. Add MCP Gateway to Claude Code configuration:
   ```
   /mcp-gateway:add-to-config .mcp.json
   ```
5. Restart Claude Code to load MCP Gateway
6. Verify child servers:
   ```
   /mcp-gateway:list-children
   ```

### Adding a New Child Server

1. Open `children_config.json` or `children_config.toml`
2. Add new server entry with name, command, args, env
3. Restart Claude Code
4. Verify server is registered:
   ```
   /mcp-gateway:list-children
   ```
5. Check startup status:
   ```
   /mcp-gateway:get-status <new_server_name>
   ```
6. Get available tools:
   ```
   /mcp-gateway:get-schema <new_server_name>
   ```

### Troubleshooting Child Server

1. Check server status:
   ```
   /mcp-gateway:get-status <child_name>
   ```
2. Review error messages in status output
3. Verify configuration in `children_config.json` / `children_config.toml`:
   - Command is correct and accessible
   - Arguments are properly formatted
   - Environment variables are set
4. Close session and retry:
   ```
   /mcp-gateway:close-session <child_name>
   ```
5. Restart Claude Code to reload configuration

## Debug Mode

Enable debug output for troubleshooting:

```bash
DEBUG_MCP=1 uvx --from git+https://github.com/TomCat2357/MCPgateway mcp-gateway --children-config children_config.toml
```

Or add to environment in configuration:

```json
{
  "mcpServers": {
    "mcp-gateway": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/TomCat2357/MCPgateway", "mcp-gateway", "--children-config", "/path/to/children_config.json"],
      "env": {
        "DEBUG_MCP": "1"
      }
    }
  }
}
```

Use the .toml path in `--children-config` if your child configuration is in TOML.

Debug mode provides detailed logging of:
- Child server startup sequences
- Tool execution requests and responses
- Session management operations
- Error conditions and stack traces

## Additional Resources

### Reference Files

For detailed documentation, consult:
- **`references/tool-reference.md`** - Complete tool API reference with all parameters
- **`references/child-servers.md`** - Guide to popular child MCP servers
- **`references/advanced-patterns.md`** - Advanced usage patterns and best practices

### Example Files

Working configuration examples in `examples/`:
- **`children_config_basic.json`** - Simple single-server setup
- **`children_config_basic.toml`** - Simple single-server setup (TOML)
- **`children_config_serena.json`** - Serena code search configuration
- **`children_config_context7.json`** - Context7 documentation configuration
- **`children_config_codegraph.json`** - Codegraph analysis configuration
- **`children_config_multi.json`** - Multi-server configuration with serena, context7, codegraph
- **`children_config_multi.toml`** - Multi-server configuration (TOML)

### Scripts

Utility scripts in `scripts/`:
- **`validate-config.sh`** - Validate children_config.json / children_config.toml structure

## Best Practices

### Configuration Management

- Use absolute paths in `children_config` references
- Store `children_config.json` / `children_config.toml` in version control
- Document environment variables in README
- Use descriptive names for child servers

### Tool Execution

- Use `get_schema` before calling unfamiliar tools
- Apply `head`/`tail` parameters for large outputs
- Check `get_status` when tools fail unexpectedly
- Close sessions explicitly when changing configurations

### Debugging

- Enable `DEBUG_MCP=1` for troubleshooting
- Check `get_child_status` for startup errors
- Verify child server commands work in terminal
- Test child servers individually before adding to gateway

### Performance

- Keep child servers lightweight
- Close unused sessions to free resources
- Use output truncation for large results
- Restart gateway periodically for long-running sessions

## Common Issues

**Child server fails to start:**
- Verify command is in PATH or use absolute path
- Check arguments are correctly formatted (JSON array or TOML array)
- Ensure environment variables are set correctly
- Review `get_child_status` error messages

**Tool execution fails:**
- Confirm tool exists with `get_schema`
- Validate arguments match schema requirements
- Check child server is running with `get_status`
- Review child server documentation for tool usage

**Configuration not loading:**
- Use absolute paths for `children_config.json` / `children_config.toml`
- Restart Claude Code after configuration changes
- Verify JSON/TOML syntax in both config files
- Check file permissions and accessibility

**Output truncation issues:**
- Adjust `head` and `tail` values as needed
- Consider processing output in chunks
- Use schema to understand expected output size
- Review child server output format

For additional troubleshooting and advanced patterns, see `references/advanced-patterns.md`.
