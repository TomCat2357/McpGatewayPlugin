# MCP Gateway Plugin for Claude Code

A comprehensive Claude Code plugin for managing [MCP Gateway](https://github.com/TomCat2357/MCPgateway) - a parent MCP server that manages multiple child MCP servers with unified tool access.

## Overview

MCP Gateway is a parent MCP server that acts as a gateway to manage multiple child MCP servers (like serena, context7, codegraph, etc.). This plugin provides:

- **Skills**: Comprehensive guide on MCP Gateway installation, configuration, and usage
- **Commands**: Slash commands to interact with MCP Gateway tools
- **Easy Setup**: Commands to add MCP Gateway to your Claude Code or Codex CLI configuration

## Features

### Commands

- `/mcp-gateway:add-to-config` - Add MCP Gateway to .mcp.json or .toml configuration files
- `/mcp-gateway:execute-tool` - Execute tools from child MCP servers
- `/mcp-gateway:get-schema` - Retrieve tool and resource schemas from child servers
- `/mcp-gateway:list-children` - List all registered child servers
- `/mcp-gateway:get-status` - Check startup status and errors of child servers
- `/mcp-gateway:close-session` - Explicitly terminate child server sessions
- `/mcp-gateway:generate-children-config` - Generate children_config template (.json or .toml)

### Skills

- **mcp-gateway-usage**: Automatically activated when you ask about MCP Gateway, provides guidance on installation, configuration, and tool usage

## Prerequisites

- [uv](https://github.com/astral-sh/uv) - Python package installer
- MCP Gateway repository: `git clone https://github.com/TomCat2357/MCPgateway`
- Claude Code CLI

## Installation

### Option 1: From GitHub (Recommended for distribution)

```bash
claude plugin install https://github.com/yourusername/mcp-gateway-plugin
```

### Option 2: Local Development

1. Clone this repository:
```bash
git clone https://github.com/yourusername/mcp-gateway-plugin.git
cd mcp-gateway-plugin
```

2. Use with Claude Code:
```bash
cc --plugin-dir /path/to/mcp-gateway-plugin
```

Or copy to your project's `.claude-plugin/` directory:
```bash
cp -r mcp-gateway-plugin /your/project/.claude-plugin/
```

## Quick Start

1. **Install MCP Gateway**:
```bash
git clone https://github.com/TomCat2357/MCPgateway
cd MCPgateway
uv sync
```

2. **Add to your configuration**:
```bash
# In Claude Code
/mcp-gateway:add-to-config .mcp.json
```

3. **Generate children configuration**:
```bash
/mcp-gateway:generate-children-config
```

4. **Edit children_config.json or children_config.toml** to add your child servers (serena, context7, etc.)

5. **Use MCP Gateway tools**:
```bash
/mcp-gateway:list-children
/mcp-gateway:execute-tool serena search_code "function main"
```

## Usage Examples

See the `skills/mcp-gateway-usage/examples/` directory for detailed configuration examples including:
- serena (code search)
- context7 (library documentation)
- codegraph (code graph analysis)

## Configuration

### MCP Gateway Setup

The plugin helps you configure MCP Gateway in two formats:

**Claude Code (.mcp.json)**:
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
        "/path/to/children_config.json"
      ]
    }
  }
}
```

**Codex CLI (.toml)**:
```toml
[mcp-servers.mcp-gateway]
command = "uvx"
args = [
  "--from",
  "git+https://github.com/TomCat2357/MCPgateway",
  "mcp-gateway",
  "--children-config",
  "/path/to/children_config.json"
]
```

### Children Configuration

Create `children_config.json` **or** `children_config.toml` to define your child MCP servers:

**JSON (array of servers)**
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

**TOML (array of tables)**
```toml
[[children]]
name = "serena"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-serena"]

[children.env]
SERENA_WORKSPACE = "${HOME}/projects"
```

Use `/mcp-gateway:generate-children-config` to create a template in either format.

## Documentation

For detailed documentation on MCP Gateway:
- GitHub: https://github.com/TomCat2357/MCPgateway
- MCP Protocol: https://modelcontextprotocol.io

## License

MIT

## Contributing

Contributions are welcome! Please open issues or submit pull requests.

## Author

Created for use with Claude Code and MCP Gateway.
