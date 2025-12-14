---
description: 登録済み child 一覧を表示する
allowed-tools: mcp__mcp-gateway__list_registered_children
---

MCP Gateway に登録された child 一覧を表示します。

**手順**
1. `mcp__mcp-gateway__list_registered_children` を呼ぶ（引数なし）
2. child 名を列挙して表示（件数も併記）
3. 次の一手として `/mcp-gateway:get-status <child>` と `/mcp-gateway:execute-tool <child> <tool> {...}` を案内
