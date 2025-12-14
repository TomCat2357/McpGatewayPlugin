---
description: children_abstract.json の最小テンプレートを生成する
argument-hint: [output-path]
allowed-tools: Read, Write, AskUserQuestion
---

`children_abstract.json` を作成します（child tool の要約。トークン節約に有効）。

**手順**
1. 出力パスを決める（無ければ `./children_abstract.json`）
2. 既存ファイルがあれば上書き確認（y/n）
3. `{}` を書き込む

必要になったら `skills/mcp-gateway-usage/references/children-abstract.md` の形で追記する。
