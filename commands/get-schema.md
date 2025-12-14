---
description: child の schema（tools/resources）を取得する
argument-hint: <child-name>
allowed-tools: mcp__mcp-gateway__get_schema
---

child の tool / resource schema を取得します（重いので必要なときだけ）。

**引数**
- `$1`：child 名（必須）

**手順**
1. `$1` が無ければ usage を出して終了（必要なら `/mcp-gateway:list-children`）
2. `mcp__mcp-gateway__get_schema` を呼ぶ
   - `child_name`: `$1`
3. 返ってきた `tools` / `resources` を見やすく整形して表示
4. 次の一手として `/mcp-gateway:execute-tool $1 <tool> {...}` を案内
