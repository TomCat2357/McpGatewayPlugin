---
description: child MCP の tool を実行する
argument-hint: <child-name> <tool-name> [tool-args-json] [head_chars=N] [tail_chars=N]
allowed-tools: mcp__mcp-gateway__execute_child_tool
---

MCP Gateway 経由で child の tool を実行します。

**引数**
- `$1`：child 名（必須）
- `$2`：tool 名（必須）
- `$3+`：`tool-args-json`（任意）と `head_chars=N` / `tail_chars=N`（任意）

**手順**
1. `$1` / `$2` が無ければ usage を出して終了（必要なら `/mcp-gateway:list-children` を案内）
2. `$3+` から以下を抽出
   - `tool_args`：JSON オブジェクト（無ければ `{}`）
   - `head_chars` / `tail_chars`：指定があれば値を使う（出力を文字数で短縮）
3. `mcp__mcp-gateway__execute_child_tool` を呼ぶ
   - `child_name`: `$1`
   - `tool_name`: `$2`
   - `tool_args`: 解析した JSON（省略時 `{}`）
   - `head_chars` / `tail_chars`: 任意
4. 成功時は出力を表示。失敗時は `/mcp-gateway:get-status $1` を案内
5. tool 名/引数が不明なら `children_abstract.json`（推奨）→必要なら `/mcp-gateway:get-schema $1`
