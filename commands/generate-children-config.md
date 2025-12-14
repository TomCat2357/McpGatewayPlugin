---
description: children_config テンプレートを生成する
argument-hint: [output-path]
allowed-tools: Read, Write, AskUserQuestion
---

child 定義ファイル（`children_config.*`）の最小テンプレートを作ります。

**手順**
1. 出力パスを決める（無ければ json/toml を質問して `./children_config.json` or `./children_config.toml`）
2. 既存ファイルがあれば上書き確認（y/n）
3. テンプレートを書き込む
   - JSON：Claude Code 互換の `mcpServers` 形式
   - TOML：Codex 互換の `[mcp-servers.<name>]` 形式

**JSON（最小）**
```json
{ "mcpServers": {} }
```

**TOML（最小）**
```toml
# empty
```

作成後は `/mcp-gateway:add-to-config` で mcp-gateway 側にパスを設定します。
