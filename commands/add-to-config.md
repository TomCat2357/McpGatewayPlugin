---
description: MCP Gateway を .mcp.json / .toml に追加する
argument-hint: [config-file-path]
allowed-tools: Read, Write, Edit, AskUserQuestion
---

指定ファイルに `mcp-gateway`（Parent MCP server）の設定を追記/更新します。

**対象ファイル**: `$ARGUMENTS`（省略時は質問）

**手順**
1. 設定対象ファイルのパスを決める
   - `$ARGUMENTS` が無ければ `AskUserQuestion` で質問:
     - 「設定ファイルのパスを教えてください（Claude Code: `.mcp.json` / Codex CLI: `.toml`）」
2. 形式を判定（ユーザーに “どの環境か” は聞かない）
   - 拡張子が `.toml` → Codex CLI 形式（TOML）
   - 拡張子が `.json` → Claude Code 形式（JSON）
   - それ以外は、ユーザーに「`.mcp.json` か `.toml` を指定してほしい」旨を伝えて終了
3. 実行環境（Windows / WSL）の扱いを “質問せず” に判断する
   - 以降でユーザーから受け取るパス表記が `C:\\...` / `D:\\...` のような Windows 形式なら Windows として扱う
   - `/...` や `/mnt/...` のような POSIX 形式なら WSL/Linux として扱う
   - 以降の `--children-config` / `--children-abstract` に入れる値は、その判断結果に合わせた「実行環境から見える絶対パス」を採用する
4. `--children-config` の場所（絶対パス）を質問する（必須）
   - `AskUserQuestion`:
     - 「`--children-config` に指定する `children_config.(json|toml)` の絶対パスはどこですか？」
5. `--children-abstract` の場所（絶対パス）を質問する（推奨）
   - `AskUserQuestion`:
     - 「`--children-abstract` に指定する `children_abstract.json` の絶対パスはどこですか？（未使用なら空欄でOK）」
6. `mcp-gateway` の起動コマンドを質問する（設定に存在しない場合のみ）
   - 既存設定に `mcp-gateway` があれば `command` は保持し、`args` だけ更新する
   - 無ければ `AskUserQuestion`:
     - 「`mcp-gateway` を起動するコマンド名（またはフルパス）を教えてください（例: `mcp-gateway`）」
7. 追加/更新する設定を提示し、y/n で確認してから書き込み
   - 既に `--children-config` / `--children-abstract` が入っている場合は値を置換（重複させない）

**追加/更新する設定（Claude Code / `.mcp.json`）**
- `mcpServers.mcp-gateway.args` に `--children-config` と（任意で）`--children-abstract` を入れる
- `mcpServers.mcp-gateway.command` が無ければユーザー回答で設定する

例（`children_abstract.json` も使う場合）:
```json
{
  "mcpServers": {
    "mcp-gateway": {
      "command": "mcp-gateway",
      "args": [
        "--children-config",
        "/absolute/path/to/children_config.json",
        "--children-abstract",
        "/absolute/path/to/children_abstract.json"
      ]
    }
  }
}
```

**追加/更新する設定（Codex CLI / `.toml`）**
- `[mcp-servers.mcp-gateway]` の `args` に `--children-config` と（任意で）`--children-abstract` を入れる
- `command` が無ければユーザー回答で設定する

例（`children_abstract.json` も使う場合）:
```toml
[mcp-servers.mcp-gateway]
command = "mcp-gateway"
args = [
  "--children-config",
  "/absolute/path/to/children_config.toml",
  "--children-abstract",
  "/absolute/path/to/children_abstract.json",
]
```

**注意**
- `--children-config` / `--children-abstract` は「mcp-gateway を起動する環境（WSL/Windows）から見える絶対パス」
- WSL で動かすなら `/mnt/c/...` も “WSLから見えるパス” として有効（Windows の `C:\\...` とは別物なので混ぜない）
