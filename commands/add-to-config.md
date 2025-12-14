---
description: MCP Gateway を Claude Code（~/.claude.json）/ Codex CLI（.toml）に追加する
argument-hint: [config-file-path]
allowed-tools: Read, Write, Edit, AskUserQuestion
---

指定ファイルに `mcp-gateway`（Parent MCP server）の設定を追記/更新します。

**対象ファイル**: `$ARGUMENTS`（省略時はプラグインスコープから自動選択）

**手順**
1. 設定対象ファイルのパスを決める（ユーザーには質問しない）
   - `$ARGUMENTS` があればそれを使う
   - 無ければ、プラグインスコープに合わせて自動選択する
     - `~/.claude.json` が存在する → Claude Code（ユーザースコープ）として `~/.claude.json`
     - それ以外で `~/.codex/config.toml` が存在する → Codex CLI（ユーザースコープ）として `~/.codex/config.toml`
     - どちらも無い → 対象ファイルが特定できないため終了（`$ARGUMENTS` で明示してもらう）
2. 形式を判定（ユーザーに “どの環境か” は聞かない）
   - 拡張子が `.toml` → Codex CLI 形式（TOML）
   - 拡張子が `.json` → Claude Code 形式（JSON、既定は `~/.claude.json`）
   - それ以外は、ユーザーに「`~/.claude.json` か `.toml` を指定してほしい」旨を伝えて終了
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
6. `mcp-gateway` の起動設定は `uvx` 固定で追記/更新する（質問しない）
   - `uvx` で `git+https://github.com/TomCat2357/MCPgateway` から `mcp-gateway` を起動する
   - Python は `3.12` を指定する（`uvx --python 3.12`）
7. 追加/更新する設定を提示し、y/n で確認してから書き込み
   - 既に `--children-config` / `--children-abstract` が入っている場合は値を置換（重複させない）
   - `--children-abstract` が空欄の場合は、`--children-abstract` 自体を `args` に入れない

**追加/更新する設定（Claude Code / `~/.claude.json`）**
- `~/.claude.json` の「該当スコープ」配下の `mcpServers.mcp-gateway.command` は `uvx`
- `~/.claude.json` の「該当スコープ」配下の `mcpServers.mcp-gateway.args` は以下を含む（`--children-abstract` は任意）
  - `--python` `3.12`
  - `--from` `git+https://github.com/TomCat2357/MCPgateway`
  - `mcp-gateway`
  - `--children-config` `<ABSOLUTE_PATH>`
  - （任意）`--children-abstract` `<ABSOLUTE_PATH>`

例（`mcpServers` ブロックの中身、`children_abstract.json` も使う場合）:
```json
{
  "mcp-gateway": {
    "command": "uvx",
    "args": [
      "--python",
      "3.12",
      "--from",
      "git+https://github.com/TomCat2357/MCPgateway",
      "mcp-gateway",
      "--children-config",
      "/absolute/path/to/children_config.json",
      "--children-abstract",
      "/absolute/path/to/children_abstract.json"
    ]
  }
}
```

**追加/更新する設定（Codex CLI / `.toml`）**
- Codex CLI の `config.toml` は通常 `mcp_servers`（アンダースコア）形式
- `[mcp_servers.mcp-gateway]` の `command` は `uvx`
- `args` は以下を含む（`--children-abstract` は任意）
  - `--python` `3.12`
  - `--from` `git+https://github.com/TomCat2357/MCPgateway`
  - `mcp-gateway`
  - `--children-config` `<ABSOLUTE_PATH>`
  - （任意）`--children-abstract` `<ABSOLUTE_PATH>`

例（`children_abstract.json` も使う場合）:
```toml
[mcp_servers.mcp-gateway]
command = "uvx"
args = [
  "--python",
  "3.12",
  "--from",
  "git+https://github.com/TomCat2357/MCPgateway",
  "mcp-gateway",
  "--children-config",
  "/absolute/path/to/children_config.toml",
  "--children-abstract",
  "/absolute/path/to/children_abstract.json",
]
```

**注意**
- Claude Code と Codex CLI の設定ファイルは別物（Claude Code は `~/.claude.json`、Codex CLI は `~/.codex/config.toml`）
- `--children-config` / `--children-abstract` は「mcp-gateway を起動する環境（WSL/Windows）から見える絶対パス」
- WSL で動かすなら `/mnt/c/...` も “WSLから見えるパス” として有効（Windows の `C:\\...` とは別物なので混ぜない）
