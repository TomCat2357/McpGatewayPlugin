---
description: child セッションを明示的に閉じる
argument-hint: <child-name>
allowed-tools: mcp__mcp-gateway__close_child_session
---

指定 child のセッションを閉じます（通常は不要）。

**引数**
- `$1`：child 名（必須）

**手順**
1. `$1` が無ければ usage を出して終了（必要なら `/mcp-gateway:list-children`）
2. 確認してから実行（y/n）
3. `mcp__mcp-gateway__close_child_session` を呼ぶ
   - `child_name`: `$1`
4. 結果を表示し、必要なら `/mcp-gateway:get-status $1` を案内
