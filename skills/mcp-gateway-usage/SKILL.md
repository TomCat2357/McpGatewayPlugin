---
name: MCP Gateway Usage
description: MCP Gateway / children_config / children_abstract / execute_child_tool の基本に答えるときに使う。
version: 0.2.0
---

# MCP Gateway（基本）

MCP Gateway は複数の child MCP server をまとめて管理し、1つの窓口から tool を実行します。

## 最小構成

- `children_config.(json|toml)`：child 定義
- `children_abstract.json`：child の tool 要約（スキーマ取得を減らすため推奨）

メモ: `children_config.json` は `{"mcpServers": { ... }}` 形式が基本。

## セットアップ（推奨ルート）

- 設定追加：`/mcp-gateway:add-to-config`（`.mcp.json` または `.toml`）
- テンプレ生成：`/mcp-gateway:generate-children-config`
- 追加で用意：`/mcp-gateway:generate-children-abstract`（推奨）

## 使い方（最小）

1) child 一覧：`/mcp-gateway:list-children`  
2) tool 実行：`/mcp-gateway:execute-tool <child> <tool> [tool_args_json] [head_chars=N] [tail_chars=N]`

メモ:
- `tool_args_json` は JSON オブジェクト（省略時は `{}`）。
- `head_chars` / `tail_chars` は「文字数」で出力を短縮（トークン節約）。

## 子toolの調べ方（トークン節約）

1) まず `children_abstract.json` の該当 child だけ読む  
2) 不明点が残る場合のみ `/mcp-gateway:get-schema <child>` を使う

## WSL / PowerShell 差異（最低限）

- `--children-config` / `--children-abstract` は「実行環境から見える絶対パス」を指定する
- child の `command` は環境により差が出るため、動かない場合は `get-status` のエラーに従って修正する

## 詳細（必要なときだけ）

- `references/children-abstract.md`：`children_abstract.json` の運用（推奨）
- `references/troubleshooting.md`：起動/実行のよくある問題
