# MCP Gateway Plugin

Claude Code / Codex CLI から MCP Gateway を使いやすくするためのプラグインです。

## できること

- `/mcp-gateway:add-to-config`：`.mcp.json` / `.toml` に mcp-gateway 設定を追記
- `/mcp-gateway:generate-children-config`：`children_config.*` の最小テンプレート生成
- `/mcp-gateway:generate-children-abstract`：`children_abstract.json` の最小テンプレート生成
- `/mcp-gateway:list-children`：child 一覧
- `/mcp-gateway:execute-tool`：child tool 実行（`head_chars`/`tail_chars` でトークン節約）
- `/mcp-gateway:get-status`：child 状態
- `/mcp-gateway:get-schema`：child schema（必要時のみ）
- `/mcp-gateway:close-session`：child セッション終了（通常不要）

## 重要（トークン節約）

`children_abstract.json` を用意し、よく使う child tool の引数形を短くまとめておくと、`get-schema` の頻度を減らせます。  
詳細は `skills/mcp-gateway-usage/references/children-abstract.md`。

## 設定のポイント

- mcp-gateway 起動引数に `--children-config` と `--children-abstract` を指定する（どちらも絶対パス）
- その環境（WSL/Windows）から見えるパスであること
