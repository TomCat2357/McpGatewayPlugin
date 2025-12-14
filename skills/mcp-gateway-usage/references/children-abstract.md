# children_abstract.json（トークン節約用メモ）

`children_abstract.json` は、child ごとの「よく使う tool 名」と「最低限の引数形」を短くまとめるための JSON です。  
LLM が `/mcp-gateway:get-schema` を多用しなくても `/mcp-gateway:execute-tool` を組み立てられる状態を目指します。

## 方針

- 1 child あたり 3〜10 tool 程度に絞る（全部は載せない）
- `overview` は 1〜2 行で十分
- `execute_child_tool` は “そのまま実行できる” 形で置く（コピペ可能な形）
- 状態（running など）は不要なら書かない（変化すると差分/トークンが増える）

## 例（最小）

```json
{
  "serena": {
    "description": "コード検索/シンボル探索",
    "execute_via": "mcp-gateway/execute_child_tool",
    "child_name": "serena",
    "tools": [
      {
        "tool_name": "search_code",
        "overview": "全文/セマンティック検索",
        "execute_child_tool": {
          "child_name": "serena",
          "tool_name": "search_code",
          "tool_args": {
            "query": "function main"
          }
        }
      }
    ]
  }
}
```

## 運用のコツ

- child を追加/変更したら、まず `children_abstract.json` を更新する  
  → LLM が「tool 名・引数」をすぐ理解できるため、schema 取得が減る
- 不明点が残る場合のみ `/mcp-gateway:get-schema <child>`（一回だけ）で補完して抽象へ反映する

