# Troubleshooting（最小）

## child が起動しない

- `/mcp-gateway:get-status <child>` のエラーを見る
- `children_config.(json|toml)` の `command` / `args` を見直す
  - WSL と Windows/PowerShell でコマンド名や PATH が違う場合がある
  - 動作確認は「その環境のターミナル」で行う

## WSL / Windows でパスが噛み合わない

- mcp-gateway が WSL 側で動いているなら、`--children-config` / `--children-abstract` も WSL から見えるパスにする
- mcp-gateway が Windows 側で動いているなら、Windows から見えるパスにする

## tool が見つからない / 引数が違う

- まず `children_abstract.json` を確認（古いなら更新）
- それでも不明なら `/mcp-gateway:get-schema <child>` を一度だけ実行して確認

## 出力が長すぎる

- `/mcp-gateway:execute-tool ... head_chars=N tail_chars=N` を使って文字数で短縮する
