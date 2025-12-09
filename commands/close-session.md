---
description: Explicitly terminate a child server session
argument-hint: <child-name>
allowed-tools: mcp__mcp-gateway__close_child_session
---

Explicitly close the session for a specific child MCP server.

**Argument:**
- $1: Child server name (required)

**Execution steps:**

1. **Validate argument:**
   - If $1 (child server name) is missing:
     - Display error: "Child server name required"
     - Show usage: `/mcp-gateway:close-session <child-name>`
     - List available servers: `/mcp-gateway:list-children`
     - Stop execution

2. **Confirm action with user:**
   - Explain what closing the session will do:
     - Terminates the child server process
     - Frees system resources
     - Clears server state
     - Next tool call will restart the server
   - Ask: "Close session for '$1'? (y/n)"
   - Only proceed if user confirms

3. **Close the session:**
   Call mcp__mcp-gateway__close_child_session with parameter:
   - server_id: $1 (child server name)

4. **Display result:**
   - If successful:
     - Display: "✓ Session closed for '$1'"
     - Show uptime (if available)
     - Note that resources have been freed
   - If failed:
     - Display error message
     - Suggest possible causes:
       - Server wasn't running
       - Server already stopped
       - Connection error

5. **Provide guidance:**
   - Explain session auto-management:
     - MCP Gateway manages sessions automatically
     - Manual closure rarely needed
     - Sessions persist across tool calls for efficiency
   - Suggest when to use manual closure:
     - Before configuration changes
     - When server becomes unresponsive
     - To free system resources
     - When resetting server state
     - For troubleshooting persistent errors

6. **Next steps:**
   - If user needs to change configuration:
     - Edit children_config.json / children_config.toml
     - Restart Claude Code
   - If user wants to use server again:
     - Next tool call will restart it automatically
   - If troubleshooting:
     - Check status after closure: `/mcp-gateway:get-status $1`

**Example output (success):**

```
Session closed for "serena"

Details:
  Server: serena
  Status: closed
  Uptime: 15 minutes 32 seconds
  Resources freed: ✓

Note: MCP Gateway automatically manages sessions. Manual closure is typically only needed when:
  - Changing configuration files
  - Server becomes unresponsive
  - Freeing system resources
  - Troubleshooting persistent errors

Next tool execution for "serena" will automatically restart the server.
```

**Example output (already stopped):**

```
Session for "serena" is already closed or was not running.

No action taken.

To verify server state:
  /mcp-gateway:get-status serena

To use the server:
  /mcp-gateway:execute-tool serena <tool-name> [args]
  (Server will start automatically)
```

**When to use:**
- Before editing children_config.json / children_config.toml
- Server not responding to tool calls
- Need to free memory/CPU resources
- Resetting server state after errors
- Testing configuration changes

**When NOT to use:**
- Normal operation (auto-management is sufficient)
- Between related tool calls (unnecessary overhead)
- Server working correctly (no benefit to closure)
