# Child MCP Servers Guide

Comprehensive guide to popular child MCP servers that can be managed through MCP Gateway.

## Overview

This guide covers commonly used child MCP servers, their capabilities, configuration, and integration patterns with MCP Gateway.

---

## Serena - Code Search and Symbol Lookup

Serena provides semantic code search, symbol lookup, and file operations across codebases.

### Capabilities

- **Code search**: Semantic search with natural language queries
- **Symbol lookup**: Find function/class definitions
- **File operations**: Read, write, and modify files
- **Context retrieval**: Get code context around symbols

### Configuration

```json
{
  "name": "serena",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-serena"],
  "env": {
    "SERENA_WORKSPACE": "/path/to/workspace"
  }
}
```

### Key Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `SERENA_WORKSPACE` | Root directory for code search | Optional |

### Common Tools

**search_code**
```json
{
  "query": "function to handle user authentication",
  "case_sensitive": false,
  "max_results": 50
}
```

**find_symbol**
```json
{
  "symbol": "UserAuthenticator",
  "type": "class"
}
```

**read_file**
```json
{
  "path": "src/auth/authenticator.py",
  "line_start": 10,
  "line_end": 50
}
```

### Use Cases

- Finding code examples
- Locating function definitions
- Understanding code structure
- Refactoring assistance
- Documentation generation

### Best Practices

- Set `SERENA_WORKSPACE` to project root
- Use semantic queries for better results
- Combine with `head`/`tail` for large codebases
- Cache common searches

---

## Context7 - Library Documentation

Context7 provides library and package documentation retrieval with intelligent caching.

### Capabilities

- **Library ID resolution**: Resolve package names to documentation IDs
- **Documentation retrieval**: Fetch docs for specific libraries
- **Version-specific docs**: Get documentation for specific versions
- **API reference**: Detailed API documentation

### Configuration

```json
{
  "name": "context7",
  "command": "npx",
  "args": ["-y", "@context7/mcp-server"],
  "env": {
    "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
  }
}
```

### Key Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `CONTEXT7_API_KEY` | API key for Context7 service | Yes |

### Common Tools

**resolve_library_id**
```json
{
  "library_name": "react",
  "version": "18.2.0"
}
```

**get_documentation**
```json
{
  "library_id": "react-18.2.0",
  "section": "hooks"
}
```

**search_docs**
```json
{
  "query": "useState hook examples",
  "library": "react"
}
```

### Use Cases

- Learning new libraries
- Finding API usage examples
- Checking deprecated features
- Version migration guides
- Best practices research

### Best Practices

- Store `CONTEXT7_API_KEY` in environment, not config
- Resolve library IDs before getting docs
- Cache documentation locally when possible
- Specify versions for consistent results

---

## Codegraph - Code Graph Analysis

Codegraph provides code graph queries, dependency analysis, and GraphRAG search capabilities.

### Capabilities

- **Graph queries**: Cypher-like queries on code structure
- **Dependency analysis**: Track dependencies and imports
- **Call graph**: Function call relationships
- **GraphRAG search**: Graph-enhanced retrieval augmented generation

### Configuration

```json
{
  "name": "codegraph",
  "command": "python",
  "args": ["-m", "codegraph.server"],
  "env": {
    "CODEGRAPH_ROOT": "/path/to/codebase",
    "CODEGRAPH_DB": "/path/to/graph.db"
  }
}
```

### Key Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `CODEGRAPH_ROOT` | Root directory to analyze | Yes |
| `CODEGRAPH_DB` | Graph database path | Optional |

### Common Tools

**query_graph**
```json
{
  "query": "MATCH (f:Function)-[:CALLS]->(g:Function) WHERE f.name='main' RETURN g.name",
  "limit": 100
}
```

**find_dependencies**
```json
{
  "module": "auth.py",
  "depth": 2
}
```

**analyze_calls**
```json
{
  "function": "process_request",
  "direction": "both"
}
```

### Use Cases

- Understanding code architecture
- Finding circular dependencies
- Analyzing impact of changes
- Visualizing code structure
- Refactoring planning

### Best Practices

- Index codebase before queries
- Use graph database for large codebases
- Limit query depth for performance
- Cache common graph patterns

---

## Filesystem - File Operations

Standard filesystem MCP server for file operations.

### Configuration

```json
{
  "name": "filesystem",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", "/allowed/path"],
  "env": {}
}
```

### Key Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| Path argument | Allowed directory path | Yes |

### Common Tools

**read_file**
```json
{
  "path": "config.json"
}
```

**write_file**
```json
{
  "path": "output.txt",
  "content": "File contents"
}
```

**list_directory**
```json
{
  "path": "src/",
  "recursive": true
}
```

### Use Cases

- Reading configuration files
- Writing generated code
- Directory traversal
- File system operations

### Best Practices

- Restrict to specific directories
- Validate paths before operations
- Use absolute paths
- Handle file encoding properly

---

## SQLite - Database Operations

SQLite MCP server for database queries and management.

### Configuration

```json
{
  "name": "sqlite",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sqlite", "/path/to/database.db"],
  "env": {}
}
```

### Common Tools

**query**
```json
{
  "sql": "SELECT * FROM users WHERE active = 1",
  "params": []
}
```

**execute**
```json
{
  "sql": "INSERT INTO users (name, email) VALUES (?, ?)",
  "params": ["John Doe", "john@example.com"]
}
```

**get_schema**
```json
{
  "table": "users"
}
```

### Use Cases

- Database queries
- Data analysis
- Schema exploration
- Data migration

### Best Practices

- Use parameterized queries
- Limit result sets
- Back up before modifications
- Handle transactions properly

---

## GitHub - Repository Operations

GitHub MCP server for repository management and operations.

### Configuration

```json
{
  "name": "github",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_TOKEN": "${GITHUB_TOKEN}"
  }
}
```

### Key Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `GITHUB_TOKEN` | GitHub personal access token | Yes |

### Common Tools

**create_issue**
```json
{
  "repo": "owner/repo",
  "title": "Issue title",
  "body": "Issue description"
}
```

**list_pull_requests**
```json
{
  "repo": "owner/repo",
  "state": "open"
}
```

**get_file_contents**
```json
{
  "repo": "owner/repo",
  "path": "README.md",
  "ref": "main"
}
```

### Use Cases

- Issue management
- Pull request operations
- Repository exploration
- Code review automation

### Best Practices

- Store token securely in environment
- Use fine-grained tokens
- Respect rate limits
- Cache repository data

---

## Puppeteer - Browser Automation

Puppeteer MCP server for web automation and scraping.

### Configuration

```json
{
  "name": "puppeteer",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
  "env": {}
}
```

### Common Tools

**navigate**
```json
{
  "url": "https://example.com"
}
```

**screenshot**
```json
{
  "selector": "#main-content",
  "path": "screenshot.png"
}
```

**extract_content**
```json
{
  "selector": "article",
  "attribute": "textContent"
}
```

### Use Cases

- Web scraping
- Automated testing
- Screenshot generation
- Content extraction

### Best Practices

- Handle timeouts appropriately
- Clean up browser instances
- Respect robots.txt
- Use headless mode for efficiency

---

## Slack - Team Communication

Slack MCP server for messaging and channel operations.

### Configuration

```json
{
  "name": "slack",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-slack"],
  "env": {
    "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}"
  }
}
```

### Key Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `SLACK_BOT_TOKEN` | Slack bot token | Yes |

### Common Tools

**send_message**
```json
{
  "channel": "#general",
  "text": "Message text"
}
```

**list_channels**
```json
{
  "types": "public_channel,private_channel"
}
```

**get_thread**
```json
{
  "channel": "#general",
  "thread_ts": "1234567890.123456"
}
```

### Use Cases

- Notifications
- Team updates
- Chat automation
- Status reporting

### Best Practices

- Use thread replies for context
- Respect channel permissions
- Format messages with markdown
- Handle rate limits

---

## Custom Child Servers

### Creating Custom Servers

Any MCP-compliant server can be used as a child server:

**Requirements:**
- Implements MCP protocol
- Supports stdio or SSE transport
- Provides tool/resource schemas
- Handles JSON-RPC correctly

**Configuration template:**
```json
{
  "name": "custom-server",
  "command": "command-to-run",
  "args": ["arg1", "arg2"],
  "env": {
    "ENV_VAR": "value"
  }
}
```

### Testing Custom Servers

Before adding to children_config.json / children_config.toml:

1. Test server independently
2. Verify MCP compliance
3. Check tool schemas
4. Test error handling
5. Document requirements

### Integration Checklist

- [ ] Server starts successfully
- [ ] Tools have complete schemas
- [ ] Error messages are clear
- [ ] Environment variables documented
- [ ] Timeouts configured appropriately
- [ ] Resource cleanup works
- [ ] Concurrent access handled

---

## Multi-Server Patterns

### Complementary Servers

Combine servers for enhanced capabilities:

**Code Analysis Stack:**
```json
[
  {"name": "serena", ...},      // Code search
  {"name": "codegraph", ...},   // Graph analysis
  {"name": "filesystem", ...}   // File operations
]
```

**Documentation Workflow:**
```json
[
  {"name": "context7", ...},    // Library docs
  {"name": "github", ...},      // Repository access
  {"name": "puppeteer", ...}    // Web scraping
]
```

**Data Pipeline:**
```json
[
  {"name": "sqlite", ...},      // Database
  {"name": "filesystem", ...},  // File I/O
  {"name": "slack", ...}        // Notifications
]
```

### Workflow Orchestration

Use MCP Gateway to orchestrate multi-server workflows:

1. **Search with serena** → Find relevant code
2. **Analyze with codegraph** → Understand dependencies
3. **Document with context7** → Get library docs
4. **Update with filesystem** → Write changes
5. **Notify with slack** → Alert team

### Resource Management

With multiple servers:

- Monitor total resource usage
- Close unused sessions
- Stagger intensive operations
- Cache results across servers
- Use output truncation

---

## Troubleshooting

### Server Won't Start

**Check command availability:**
```bash
which npx  # or python, node, etc.
```

**Test command manually:**
```bash
npx -y @modelcontextprotocol/server-serena
```

**Verify environment variables:**
```bash
echo $GITHUB_TOKEN
```

### Tool Execution Fails

**Get schema first:**
```
/mcp-gateway:get-schema server-name
```

**Check server status:**
```
/mcp-gateway:get-status server-name
```

**Review error messages:**
- stderr output in status
- Tool-specific error codes
- MCP protocol errors

### Performance Issues

**Reduce active servers:**
- Close unused sessions
- Split into multiple configs
- Use on-demand activation

**Optimize queries:**
- Use output truncation
- Limit result sets
- Cache common queries

**Monitor resources:**
- Check CPU usage
- Monitor memory
- Track process count

---

For complete configuration examples with these child servers, see the `examples/` directory.
