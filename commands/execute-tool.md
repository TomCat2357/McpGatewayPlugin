---
description: Execute a tool from a child MCP server
argument-hint: <child-name> <tool-name> [args-json] [head=N] [tail=N]
allowed-tools: mcp__mcp-gateway__execute_child_tool
---

Execute a tool from a registered child MCP server through MCP Gateway.

**Arguments:**
- $1: Child server name (required)
- $2: Tool name to execute (required)
- $3+: Tool arguments as JSON string and optional head/tail parameters (optional)

**Execution steps:**

1. **Validate required arguments:**
   - If $1 (child server name) is missing:
     - Display error: "Child server name required"
     - Show usage: `/mcp-gateway:execute-tool <child-name> <tool-name> [args-json]`
     - List available servers using `/mcp-gateway:list-children`
     - Stop execution
   - If $2 (tool name) is missing:
     - Display error: "Tool name required"
     - Show usage: `/mcp-gateway:execute-tool <child-name> <tool-name> [args-json]`
     - Suggest using `/mcp-gateway:get-schema $1` to list available tools
     - Stop execution

2. **Parse arguments:**
   - Child server name: $1
   - Tool name: $2
   - Remaining arguments ($3 onwards): Parse for:
     - JSON arguments object
     - head=N parameter (optional)
     - tail=N parameter (optional)

   **Example parsing:**
   - Input: `serena search_code {"query":"main"} head=50 tail=20`
   - Parsed: child=serena, tool=search_code, args={"query":"main"}, head=50, tail=20

3. **Execute the tool using MCP:**
   Call mcp__mcp-gateway__execute_child_tool with parameters:
   - server_id: $1 (child server name)
   - tool_name: $2 (tool name)
   - arguments: Parsed JSON object from $3+ (or {} if not provided)
   - head: Parsed head value (optional)
   - tail: Parsed tail value (optional)

4. **Handle the response:**
   - If execution succeeds:
     - Display the tool output
     - Format output appropriately (code blocks for structured data)
     - Show truncation info if head/tail were used
   - If execution fails:
     - Display error message from stderr
     - Suggest troubleshooting steps:
       - Verify child server is running: `/mcp-gateway:get-status $1`
       - Check tool exists: `/mcp-gateway:get-schema $1`
       - Validate arguments match tool schema
       - Check children_config.json / children_config.toml configuration

5. **Provide helpful context:**
   - If output is truncated: Mention actual output size and truncation limits
   - If output is large: Suggest using head/tail parameters
   - If tool execution is slow: Explain child server may be starting

**Examples:**

Execute serena code search:
```
/mcp-gateway:execute-tool serena search_code {"query":"function main"}
```

Execute with output truncation:
```
/mcp-gateway:execute-tool serena search_code {"query":"import"} head=50 tail=20
```

Execute context7 documentation lookup:
```
/mcp-gateway:execute-tool context7 get_documentation {"library_id":"react-18.2.0"}
```

Execute codegraph query:
```
/mcp-gateway:execute-tool codegraph query_graph {"query":"MATCH (n:Function) RETURN n.name","limit":100}
```

**Error handling:**
- Server not found: List available servers
- Tool not found: Show available tools for that server
- Invalid arguments: Display schema requirements
- Connection errors: Check server status and configuration
