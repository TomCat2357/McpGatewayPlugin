# MCP Gateway Tool Reference

Complete API reference for all MCP Gateway tools.

## execute_child_tool

Execute a tool from a registered child MCP server.

### Signature

```
execute_child_tool(server_id: string, tool_name: string, arguments: object, head?: number, tail?: number)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `server_id` | string | Yes | Name of the child server (from children_config.json / children_config.toml) |
| `tool_name` | string | Yes | Name of the tool to execute on the child server |
| `arguments` | object | Yes | Tool-specific arguments as JSON object |
| `head` | number | No | Number of output lines to include from start |
| `tail` | number | No | Number of output lines to include from end |

### Return Value

Returns the output from the child server tool execution. If `head` or `tail` parameters are provided, output is truncated accordingly.

**Success response:**
```json
{
  "result": "Tool execution output...",
  "status": "success"
}
```

**Error response:**
```json
{
  "error": "Error message",
  "status": "failed"
}
```

### Examples

**Basic execution:**
```json
{
  "server_id": "serena",
  "tool_name": "search_code",
  "arguments": {
    "query": "function main",
    "case_sensitive": false
  }
}
```

**With output truncation:**
```json
{
  "server_id": "serena",
  "tool_name": "search_code",
  "arguments": {
    "query": "import"
  },
  "head": 50,
  "tail": 20
}
```

Returns first 50 lines and last 20 lines of output.

**Complex arguments:**
```json
{
  "server_id": "codegraph",
  "tool_name": "query_graph",
  "arguments": {
    "query": "MATCH (n:Function) RETURN n.name",
    "limit": 100
  }
}
```

### Use Cases

- **Code search**: Search across codebases using serena
- **Documentation lookup**: Retrieve library docs with context7
- **Graph queries**: Analyze code structure with codegraph
- **Data retrieval**: Fetch data from any child MCP server
- **Large output handling**: Use head/tail for manageable results

### Error Handling

Common errors and solutions:

**"Server not found"**
- Server name doesn't match children_config file
- Check available servers with `list_registered_children`

**"Tool not found"**
- Tool doesn't exist on child server
- Use `get_schema` to list available tools

**"Invalid arguments"**
- Arguments don't match tool schema
- Check schema with `get_schema` for required parameters

**"Server not started"**
- Child server failed to start
- Check `get_child_status` for startup errors

---

## get_schema

Retrieve tool and resource schemas from a child MCP server.

### Signature

```
get_schema(server_id: string)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `server_id` | string | Yes | Name of the child server |

### Return Value

Returns schema information including available tools and resources.

**Response structure:**
```json
{
  "tools": [
    {
      "name": "tool_name",
      "description": "Tool description",
      "parameters": {
        "type": "object",
        "properties": {
          "param1": {
            "type": "string",
            "description": "Parameter description"
          }
        },
        "required": ["param1"]
      }
    }
  ],
  "resources": [
    {
      "uri": "resource://uri",
      "name": "resource_name",
      "description": "Resource description"
    }
  ]
}
```

### Examples

**Get serena schema:**
```json
{
  "server_id": "serena"
}
```

**Expected output:**
```json
{
  "tools": [
    {
      "name": "search_code",
      "description": "Search code using semantic search",
      "parameters": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "Search query"
          },
          "case_sensitive": {
            "type": "boolean",
            "description": "Case-sensitive search"
          }
        },
        "required": ["query"]
      }
    }
  ]
}
```

### Use Cases

- **Tool discovery**: Find what tools a child server provides
- **Parameter validation**: Check required and optional parameters
- **Resource exploration**: Discover available resources
- **Documentation**: Understand tool capabilities
- **Integration planning**: Identify tools for specific tasks

### Best Practices

- Call `get_schema` before first use of unfamiliar child servers
- Cache schema information for repeated tool calls
- Review parameter descriptions for correct usage
- Check required parameters before calling tools

---

## list_registered_children

List all registered child MCP servers.

### Signature

```
list_registered_children()
```

### Parameters

None.

### Return Value

Returns array of registered child server names.

**Response structure:**
```json
{
  "children": ["serena", "context7", "codegraph"]
}
```

### Examples

**List all children:**
```json
{}
```

**Expected output:**
```json
{
  "children": ["serena", "context7", "codegraph"],
  "count": 3
}
```

### Use Cases

- **Configuration verification**: Confirm children_config.json / children_config.toml loaded correctly
- **Server discovery**: See what child servers are available
- **Debugging**: Verify server names before tool execution
- **Status checks**: Identify which servers to query

### Best Practices

- Run after adding new servers to the children configuration file
- Use to verify server names before calling other tools
- Helpful when troubleshooting "server not found" errors

---

## get_child_status

Check startup status and errors for a child MCP server.

### Signature

```
get_child_status(server_id: string)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `server_id` | string | Yes | Name of the child server |

### Return Value

Returns startup status and any error messages.

**Success response:**
```json
{
  "server_id": "serena",
  "status": "running",
  "startup_time": "2024-01-15T10:30:00Z"
}
```

**Error response:**
```json
{
  "server_id": "serena",
  "status": "failed",
  "error": "Command not found: npx",
  "stderr": "Full error output..."
}
```

### Examples

**Check server status:**
```json
{
  "server_id": "serena"
}
```

**Successful startup:**
```json
{
  "server_id": "serena",
  "status": "running",
  "startup_time": "2024-01-15T10:30:00Z",
  "pid": 12345
}
```

**Failed startup:**
```json
{
  "server_id": "broken_server",
  "status": "failed",
  "error": "Command not found",
  "stderr": "/bin/sh: broken_command: command not found"
}
```

### Use Cases

- **Troubleshooting**: Diagnose why tools aren't working
- **Configuration validation**: Verify commands and arguments
- **Monitoring**: Check server health
- **Debugging**: Get detailed error messages

### Common Status Values

| Status | Meaning | Action |
|--------|---------|--------|
| `running` | Server started successfully | Ready for tool calls |
| `failed` | Server startup failed | Check error and stderr |
| `starting` | Server is starting | Wait and retry |
| `stopped` | Server was explicitly stopped | Restart if needed |

### Error Diagnosis

**Command not found:**
- Verify command is in PATH or use absolute path
- Install required dependencies
- Check spelling in children_config.json / children_config.toml

**Permission denied:**
- Check file permissions on command
- Verify execute permissions
- Run with appropriate user

**Module not found:**
- Install required npm/pip packages
- Verify package names in arguments
- Check virtual environment activation

**Environment variable errors:**
- Set required environment variables in config
- Verify variable names and values
- Check for typos in env object

---

## close_child_session

Explicitly terminate a child server session.

### Signature

```
close_child_session(server_id: string)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `server_id` | string | Yes | Name of the child server |

### Return Value

Returns confirmation of session closure.

**Response structure:**
```json
{
  "server_id": "serena",
  "status": "closed",
  "message": "Session closed successfully"
}
```

### Examples

**Close session:**
```json
{
  "server_id": "serena"
}
```

**Expected output:**
```json
{
  "server_id": "serena",
  "status": "closed",
  "uptime": "00:15:32"
}
```

### Use Cases

- **Resource cleanup**: Free memory and processes
- **Configuration changes**: Close before updating config
- **State reset**: Clear child server state
- **Error recovery**: Reset after errors
- **Debugging**: Force reconnection

### When to Use

**Use close_session when:**
- Changing children_config configuration (.json or .toml)
- Child server becomes unresponsive
- Need to free system resources
- Resetting server state is required
- Troubleshooting persistent errors

**Don't use close_session when:**
- Normal tool execution (sessions auto-managed)
- Between related tool calls (unnecessary overhead)
- Server is working correctly
- Just for "cleanup" (automatic on exit)

### Best Practices

- Close sessions before configuration changes
- Use sparingly; auto-management is sufficient for most cases
- Close before restart when troubleshooting
- Document why manual closure is needed

---

## Resource URIs

MCP Gateway provides resource URIs for metadata access.

### mcp://server_summary

Get summary information about MCP Gateway configuration.

**Returns:**
- Total number of child servers
- Active sessions count
- Configuration file path
- Gateway version

### mcp://children_servers

Get detailed information about all child servers.

**Returns:**
- Server names and status
- Configuration details
- Session information
- Available tools count

**Example access:**
```json
{
  "uri": "mcp://server_summary"
}
```

**Response:**
```json
{
  "total_children": 3,
  "active_sessions": 2,
  "config_path": "/path/to/children_config.toml",
  "version": "1.0.0"
}
```

---

## Advanced Parameters

### Output Truncation

Control output size with `head` and `tail` parameters.

**Head only:**
```json
{
  "head": 100
}
```
Returns first 100 lines.

**Tail only:**
```json
{
  "tail": 50
}
```
Returns last 50 lines.

**Both:**
```json
{
  "head": 50,
  "tail": 50
}
```
Returns first 50 and last 50 lines with "..." separator.

**Use cases:**
- Large search results (use head for preview)
- Log files (use tail for recent entries)
- Long outputs (use both for context)
- Token management (limit output size)

### Arguments Object

The `arguments` parameter accepts any valid JSON object matching the tool's schema.

**Simple arguments:**
```json
{
  "arguments": {
    "query": "search term"
  }
}
```

**Complex nested objects:**
```json
{
  "arguments": {
    "filters": {
      "file_type": "python",
      "max_results": 50
    },
    "options": {
      "case_sensitive": false,
      "regex": true
    }
  }
}
```

**Arrays:**
```json
{
  "arguments": {
    "files": ["file1.py", "file2.py"],
    "exclude": ["test_*.py"]
  }
}
```

Always consult the child server's schema with `get_schema` to understand expected argument structure.

---

## Error Codes

Common error codes and their meanings:

| Code | Message | Solution |
|------|---------|----------|
| `SERVER_NOT_FOUND` | Server not registered | Check server name, verify children_config.json / children_config.toml |
| `TOOL_NOT_FOUND` | Tool doesn't exist | Use get_schema to list tools |
| `INVALID_ARGS` | Arguments invalid | Check schema for required parameters |
| `SERVER_FAILED` | Server startup failed | Check get_child_status for details |
| `TIMEOUT` | Execution timeout | Increase timeout or optimize query |
| `SESSION_ERROR` | Session management error | Close and restart session |

---

## Performance Considerations

### Session Management

- Sessions persist across tool calls (more efficient)
- Explicit closure needed only when changing config
- Gateway handles cleanup automatically

### Output Size

- Use `head`/`tail` to limit large outputs
- Consider token limits in Claude Code
- Process large results in chunks

### Concurrent Access

- Gateway prevents concurrent access conflicts with locking
- Multiple tool calls queue automatically
- No need to manage concurrency manually

### Resource Usage

- Each child server is a separate process
- Close unused servers to free resources
- Monitor system resources with many child servers

---

## Integration Patterns

### Discovery Pattern

1. `list_registered_children()` - Find available servers
2. `get_schema(server_id)` - Get tools for each server
3. Select appropriate tool for task
4. `execute_child_tool()` - Run tool

### Validation Pattern

1. `get_child_status(server_id)` - Verify server is running
2. `get_schema(server_id)` - Get parameter requirements
3. Validate arguments against schema
4. `execute_child_tool()` - Execute with valid arguments

### Debugging Pattern

1. `get_child_status(server_id)` - Check for errors
2. Review stderr output
3. Fix configuration issue
4. `close_child_session(server_id)` - Reset
5. Restart and verify

### Cleanup Pattern

1. Complete tool operations
2. `close_child_session(server_id)` - Free resources
3. Update configuration if needed
4. Restart Claude Code

---

For usage examples and configuration templates, see the `examples/` directory.
