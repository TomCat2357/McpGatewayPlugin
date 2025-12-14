---
description: child の起動状態/エラーを確認する
argument-hint: <child-name>
allowed-tools: mcp__mcp-gateway__get_child_status
---

指定 child の起動状態とエラーを確認します。

**引数**
- `$1`：child 名（必須）

**手順**
1. `$1` が無ければ usage を出して終了（必要なら `/mcp-gateway:list-children`）
2. `mcp__mcp-gateway__get_child_status` を呼ぶ
   - `child_name`: `$1`
3. 結果をそのまま/見やすく整形して表示
4. 次の一手として `/mcp-gateway:execute-tool` または設定修正（`children_config`）を案内
