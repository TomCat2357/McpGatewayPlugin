---
description: List all registered child MCP servers
allowed-tools: mcp__mcp-gateway__list_registered_children
---

List all child MCP servers registered in MCP Gateway.

**No arguments required.**

**Execution steps:**

1. **Retrieve server list:**
   Call mcp__mcp-gateway__list_registered_children (no parameters)

2. **Display the results:**
   - Format as numbered or bulleted list
   - Show total count of registered servers
   - For each server, display:
     - Server name
     - Status indicator (if available)

3. **Provide helpful context:**
   - Total number of registered servers
   - Configuration file location (children_config.json or children_config.toml)
   - Suggest next steps:
     - Check status of specific servers: `/mcp-gateway:get-status <child-name>`
     - Get tools for specific servers: `/mcp-gateway:get-schema <child-name>`
     - Execute tools: `/mcp-gateway:execute-tool <child-name> <tool-name>`

4. **Handle edge cases:**
   - If no servers registered:
     - Explain that children_config may be empty
     - Suggest using `/mcp-gateway:generate-children-config` to create template
     - Point to examples in plugin skill
   - If MCP Gateway not running:
     - Suggest checking .mcp.json configuration
     - Recommend restarting Claude Code
     - Use `/mcp` to verify MCP servers

**Example output format:**

```
Registered child MCP servers:

1. serena
2. context7
3. codegraph
4. filesystem
5. github

Total: 5 servers

Configuration: children_config.json (or children_config.toml)

Next steps:
- Check server status: /mcp-gateway:get-status <server-name>
- Get available tools: /mcp-gateway:get-schema <server-name>
- Execute tool: /mcp-gateway:execute-tool <server-name> <tool-name>
```

**Use cases:**
- Verify configuration loaded correctly
- Check which servers are available
- Get server names for other commands
- Troubleshoot configuration issues
