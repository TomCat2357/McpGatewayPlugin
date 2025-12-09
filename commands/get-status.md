---
description: Check startup status and errors for a child MCP server
argument-hint: <child-name>
allowed-tools: mcp__mcp-gateway__get_child_status
---

Check the startup status and any errors for a specific child MCP server.

**Argument:**
- $1: Child server name (required)

**Execution steps:**

1. **Validate argument:**
   - If $1 (child server name) is missing:
     - Display error: "Child server name required"
     - Show usage: `/mcp-gateway:get-status <child-name>`
     - List available servers: `/mcp-gateway:list-children`
     - Stop execution

2. **Retrieve server status:**
   Call mcp__mcp-gateway__get_child_status with parameter:
   - server_id: $1 (child server name)

3. **Analyze and display status:**
   - **If status is "running":**
     - Display: "✓ Server is running successfully"
     - Show startup time (if available)
     - Show process ID (if available)
     - Suggest next steps:
       - Get available tools: `/mcp-gateway:get-schema $1`
       - Execute tools: `/mcp-gateway:execute-tool $1 <tool-name>`

   - **If status is "failed":**
     - Display: "✗ Server startup failed"
     - Show error message
     - Show stderr output (if available)
     - Provide troubleshooting guidance based on error:
       - Command not found → Check command is installed and in PATH
       - Permission denied → Check file permissions
       - Module not found → Install required dependencies
       - Env var missing → Set required environment variables
     - Show children_config entry (JSON or TOML) for this server
     - Suggest fixes

   - **If status is "starting":**
     - Display: "⟳ Server is starting..."
     - Suggest waiting and retrying
     - Note that first startup may take longer

   - **If status is "stopped":**
     - Display: "○ Server is stopped"
     - Explain server was explicitly stopped
     - Suggest restarting if needed

4. **Provide diagnostic information:**
   - Command being executed
   - Arguments passed to command
   - Environment variables set
   - Configuration from children_config file

5. **Suggest remediation steps:**
   - For "command not found": Show how to install the command
   - For permission errors: Show how to fix permissions
   - For dependency errors: Show how to install dependencies
   - For env var errors: Show how to set environment variables

**Example output format (success):**

```
Status for "serena":
✓ Server is running successfully

Details:
  Status: running
  Startup time: 2024-01-15 10:30:00
  Process ID: 12345
  Uptime: 5 minutes

Next steps:
  - Get available tools: /mcp-gateway:get-schema serena
  - Execute tool: /mcp-gateway:execute-tool serena search_code {"query":"main"}
```

**Example output format (failure):**

```
Status for "broken-server":
✗ Server startup failed

Error: Command not found: broken_command

Stderr output:
  /bin/sh: broken_command: command not found

Configuration from children_config (JSON example):
  {
    "name": "broken-server",
    "command": "broken_command",
    "args": ["-arg"],
    "env": {}
  }

Troubleshooting:
  1. Verify "broken_command" is installed
  2. Check command is in PATH: which broken_command
  3. Install if missing: npm install -g broken_command
  4. Update children_config.json / children_config.toml with correct command path
  5. Restart Claude Code after fixing configuration
```

**Use cases:**
- Troubleshoot tool execution failures
- Verify server configuration
- Diagnose startup problems
- Monitor server health
- Debug connection issues
