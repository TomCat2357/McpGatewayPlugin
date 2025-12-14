---
description: MCP server の resource 一覧を表示する
argument-hint: [server-name]
allowed-tools: list_mcp_resources
---

MCP server が公開している resource 一覧を表示します。

**引数**
- `$1`：server 名（任意、無ければ `mcp-gateway`）

**手順**
1. server 名を決める（`$1` が無ければ `mcp-gateway`）
2. `list_mcp_resources` を呼ぶ
   - `server`: 決めた server 名
3. 返ってきた resource を `name` / `uri` / `mimeType` / `description` で整形して表示（件数も併記）
4. 次の一手として `/mcp-gateway:get-resource <resource-name> [server-name]` を案内

