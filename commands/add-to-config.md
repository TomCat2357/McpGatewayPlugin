---
description: MCP Gateway を .mcp.json / .toml に追加する
argument-hint: [config-file-path]
allowed-tools: Read, Write, Edit, AskUserQuestion
---

指定ファイルに `mcp-gateway` サーバー設定を追記します。

**対象ファイル**: `$ARGUMENTS`（省略時は質問）

**手順**
1. 対象パスを決める（無ければ質問）
2. 拡張子で形式を判定（`.json` / `.toml`）
3. ユーザーに絶対パスを確認して質問
   - `children_config`（`.json` / `.toml`）
   - `children_abstract.json`（推奨）
4. 追加する設定を提示し、y/n で確認してから書き込み

**追加する設定（概要）**
- `.mcp.json`：`mcpServers.mcp-gateway.args` に `--children-config` と `--children-abstract` を入れる
- `.toml`：`[mcp-servers.mcp-gateway]` の `args` に同様に入れる

**注意**
- パスは「mcp-gateway を起動する環境（WSL/Windows）から見える絶対パス」
