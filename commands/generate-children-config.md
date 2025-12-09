---
description: Generate children_config template file (.json or .toml)
argument-hint: [output-path]
allowed-tools: Read, Write, AskUserQuestion
---

Generate a children_config template file (JSON or TOML) for configuring child MCP servers.

**Argument:**
- $ARGUMENTS: Output file path (optional, defaults to ./children_config.json)

**Execution steps:**

1. **Determine output path:**
   - If $ARGUMENTS provided: Use that path
   - If not provided:
     - Ask user which format to use: "Generate JSON or TOML children_config? (json/toml)"
     - Default path based on choice: `./children_config.json` or `./children_config.toml`
   - If provided path has no extension: Ask user whether to save as `.json` or `.toml` and append the extension

2. **Check if file already exists:**
   - If file exists at target path:
     - Display warning: "File already exists at [path]"
     - Ask user: "Overwrite existing file? (y/n)"
     - If user says no: Stop execution
     - If user says yes: Continue to step 3

3. **Ask user about template type:**
   Use AskUserQuestion to ask: "Which template would you like to generate?"
   - Options:
     - "Empty template (just structure)"
     - "Single server example (serena)"
     - "Multi-server example (serena, context7, codegraph)"
     - "Custom (I'll specify servers)"

4. **Generate appropriate template (match chosen format):**

   **JSON templates**
   - Empty:
     ```json
     []
     ```
   - Single server (serena):
     ```json
     [
       {
         "name": "serena",
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-serena"],
         "env": {
           "SERENA_WORKSPACE": "${HOME}/projects"
         }
       }
     ]
     ```
   - Multi-server:
     ```json
     [
       {
         "name": "serena",
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-serena"],
         "env": {
           "SERENA_WORKSPACE": "${HOME}/projects"
         }
       },
       {
         "name": "context7",
         "command": "npx",
         "args": ["-y", "@context7/mcp-server"],
         "env": {
           "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
         }
       },
       {
         "name": "codegraph",
         "command": "python",
         "args": ["-m", "codegraph.server"],
         "env": {
           "CODEGRAPH_ROOT": "${PWD}",
           "CODEGRAPH_DB": "${HOME}/.codegraph/graph.db"
         }
       }
     ]
     ```

   **TOML templates** (array of tables under `children`)
   - Empty:
     ```toml
     # children_config.toml
     ```
   - Single server (serena):
     ```toml
     [[children]]
     name = "serena"
     command = "npx"
     args = ["-y", "@modelcontextprotocol/server-serena"]

     [children.env]
     SERENA_WORKSPACE = "${HOME}/projects"
     ```
   - Multi-server:
     ```toml
     [[children]]
     name = "serena"
     command = "npx"
     args = ["-y", "@modelcontextprotocol/server-serena"]

     [children.env]
     SERENA_WORKSPACE = "${HOME}/projects"

     [[children]]
     name = "context7"
     command = "npx"
     args = ["-y", "@context7/mcp-server"]

     [children.env]
     CONTEXT7_API_KEY = "${CONTEXT7_API_KEY}"

     [[children]]
     name = "codegraph"
     command = "python"
     args = ["-m", "codegraph.server"]

     [children.env]
     CODEGRAPH_ROOT = "${PWD}"
     CODEGRAPH_DB = "${HOME}/.codegraph/graph.db"
     ```

   **Option 4: Custom**
   - Ask user for each server they want to add:
     - Server name
     - Command
     - Arguments (as array)
     - Environment variables (optional)
   - Build JSON array or TOML array-of-tables based on selected format

5. **Write the template file:**
   - Use Write tool to create file at specified path
   - Ensure proper formatting:
     - JSON: 2-space indentation
     - TOML: Keep sections grouped per `[[children]]`

6. **Provide guidance:**
   - Display file location
   - Explain the structure:
     - `name`: Unique identifier for child server
     - `command`: Executable command (npx, python, node, etc.)
     - `args`: Array of command-line arguments
     - `env`: Environment variables (optional)
   - Show example servers for reference
   - Point to plugin skill for detailed documentation
   - Suggest next steps:
     - Edit file to add/modify servers
     - Reference examples in plugin: `skills/mcp-gateway-usage/examples/`
     - Add to MCP configuration: `/mcp-gateway:add-to-config`
     - Validate configuration: Use plugin script if available

7. **Display helpful reminders:**
   - Environment variables can use shell syntax: ${VAR_NAME}
   - Paths should be absolute when possible
   - Server names must be unique
   - Command must be in PATH or use absolute path
   - Test commands in terminal before adding

**Example output:**

```
Created children_config template at: ./children_config.json

Template structure:
[
  {
    "name": "server-name",          # Unique identifier
    "command": "command-to-run",    # Executable (npx, python, etc.)
    "args": ["arg1", "arg2"],       # Command arguments
    "env": {                        # Environment variables (optional)
      "VAR_NAME": "value"
    }
  }
]

Example servers included:
  - serena (code search)
  - context7 (documentation)
  - codegraph (graph analysis)

Next steps:
  1. Review and customize the configuration
  2. Set required environment variables
  3. Add to MCP configuration: /mcp-gateway:add-to-config .mcp.json
  4. Restart Claude Code
  5. Verify servers: /mcp-gateway:list-children

For more examples, see: skills/mcp-gateway-usage/examples/
```

For TOML output, present the created path (e.g., `./children_config.toml`) and remind the user the entries are written under repeated `[[children]]` tables.

**Common server configurations:**

Reference the plugin skill examples:
- `children_config_basic.json` / `children_config_basic.toml` - Simple setup
- `children_config_serena.json` - Code search
- `children_config_context7.json` - Documentation
- `children_config_codegraph.json` - Graph analysis
- `children_config_multi.json` / `children_config_multi.toml` - Multiple servers

**Validation:**
- Ensure valid JSON/TOML syntax
- Check all required fields present
- Verify command paths are correct
- Validate environment variable references
