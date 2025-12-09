---
description: Add MCP Gateway to .mcp.json or .toml configuration
argument-hint: [config-file-path]
allowed-tools: Read, Write, Edit, AskUserQuestion
---

Add MCP Gateway server configuration to the specified configuration file.

**Target file:** $ARGUMENTS

**Steps to execute:**

1. **Determine configuration file path:**
   - If $ARGUMENTS provided: Use that path
   - If not provided: Ask user for the config file path using AskUserQuestion

2. **Check if file exists:**
   - If file exists: Read it to determine format and existing content
   - If file doesn't exist: Create new file with appropriate format

3. **Determine file format:**
   - If extension is `.json`: Use Claude Code format
   - If extension is `.toml`: Use Codex CLI format
   - If unknown: Ask user which format to use

4. **Ask user for children_config path (.json or .toml):**
   Use AskUserQuestion to ask: "What is the absolute path to your children_config file? (.json or .toml)"
   - Provide examples: `/home/user/projects/children_config.json` or `/home/user/projects/children_config.toml`
   - Explain it must be an absolute path

5. **Generate MCP Gateway configuration:**

   **For Claude Code (.mcp.json):**
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
         "[USER_PROVIDED_PATH]"
         ]
       }
     }
   }
   ```

   **For Codex CLI (.toml):**
   ```toml
   [mcp-servers.mcp-gateway]
   command = "uvx"
   args = [
     "--from",
     "git+https://github.com/TomCat2357/MCPgateway",
     "mcp-gateway",
     "--children-config",
     "[USER_PROVIDED_PATH]"
   ]
   ```

6. **Handle existing content:**
   - If file exists with existing mcpServers/mcp-servers section:
     - Add mcp-gateway entry to existing configuration
     - Preserve all existing servers
   - If file exists but empty or doesn't have mcpServers section:
     - Create appropriate structure and add mcp-gateway
   - If file doesn't exist:
     - Create new file with mcp-gateway configuration

7. **Confirm with user before writing:**
   - Display the configuration that will be added
   - Ask user: "Add this MCP Gateway configuration? (y/n)"
   - Only proceed if user confirms

8. **Write the configuration:**
   - Use Write tool for new files
   - Use Edit tool for existing files
   - Ensure proper JSON/TOML formatting

9. **Verify and report:**
   - Confirm configuration was added successfully
   - Show the final file path
   - Remind user to:
     - Create children_config (.json or .toml) at the specified path
     - Use `/mcp-gateway:generate-children-config` to create template
     - Restart Claude Code to load the MCP Gateway server

**Important notes:**
- Always use absolute paths for children_config files
- Validate JSON/TOML syntax before writing
- Handle errors gracefully with clear messages
- Preserve existing configuration without modification
