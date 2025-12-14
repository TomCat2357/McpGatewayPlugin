---
description: MCP server の resource を取得して表示する
argument-hint: <resource-name-or-uri> [server-name]
allowed-tools: list_mcp_resources,read_mcp_resource
---

MCP server の resource を取得して表示します。

**引数**
- `$1`：resource 名（推奨）または resource URI（`mcp://...`）（必須）
- `$2`：server 名（任意、無ければ `mcp-gateway`）

**手順**
1. `$1` が無ければ usage を出して終了（必要なら `/mcp-gateway:list-resources`）
2. server 名を決める（`$2` が無ければ `mcp-gateway`）
3. `$1` が `mcp://` で始まるなら、それを `uri` として扱う
4. そうでなければ `list_mcp_resources` を呼び、`name == $1` の resource を探して `uri` を決める
   - 見つからなければ `/mcp-gateway:list-resources $2` を案内して終了
   - 複数ヒットするなら候補（`name`/`uri`）を列挙して終了
5. `read_mcp_resource` を呼ぶ
   - `server`: 決めた server 名
   - `uri`: 決めた uri
6. `contents` を表示（`text` があればそのまま、なければ JSON を表示）

