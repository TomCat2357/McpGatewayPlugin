---
description: Get tool and resource schemas from a child MCP server
argument-hint: <child-name>
allowed-tools: mcp__mcp-gateway__get_schema
---

Retrieve tool and resource schemas from a registered child MCP server.

**Argument:**
- $1: Child server name (required)

**Execution steps:**

1. **Validate argument:**
   - If $1 (child server name) is missing:
     - Display error: "Child server name required"
     - Show usage: `/mcp-gateway:get-schema <child-name>`
     - List available servers: Use `/mcp-gateway:list-children`
     - Stop execution

2. **Execute schema retrieval:**
   Call mcp__mcp-gateway__get_schema with parameter:
   - server_id: $1 (child server name)

3. **Format and display the schema:**
   - **Tools section:**
     - List each available tool with:
       - Tool name
       - Description
       - Parameters (name, type, description, required/optional)
     - Format as readable table or structured list
   - **Resources section:**
     - List each available resource with:
       - Resource URI
       - Resource name
       - Description
     - Format as readable list

4. **Provide helpful context:**
   - Total count of tools and resources
   - Highlight required vs optional parameters
   - Show example usage for common tools
   - Suggest next steps:
     - Use `/mcp-gateway:execute-tool` to call tools
     - Reference parameter types when calling tools

5. **Handle errors:**
   - If server not found:
     - List available servers
     - Suggest checking children_config.json / children_config.toml
   - If server not started:
     - Check server status: `/mcp-gateway:get-status $1`
     - Suggest reviewing configuration
   - If schema retrieval fails:
     - Display error message
     - Suggest troubleshooting steps

**Example output format:**

```
Tools for child server "serena":

1. search_code
   Description: Search code using semantic search
   Parameters:
     - query (string, required): Search query
     - case_sensitive (boolean, optional): Case-sensitive search
     - max_results (number, optional): Maximum results to return

2. find_symbol
   Description: Find function or class definitions
   Parameters:
     - symbol (string, required): Symbol name to find
     - type (string, optional): Symbol type (function, class, etc.)

Resources:
  - mcp://serena/workspace - Workspace information
  - mcp://serena/status - Server status

Total: 2 tools, 2 resources

Usage example:
/mcp-gateway:execute-tool serena search_code {"query":"main function"}
```

**Use cases:**
- Discover available tools before first use
- Check parameter requirements before calling tools
- Explore child server capabilities
- Validate tool names and arguments
