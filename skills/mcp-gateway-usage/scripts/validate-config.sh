#!/bin/bash
# Validate children_config.json / children_config.toml structure

set -euo pipefail

CONFIG_FILE="${1:-children_config.json}"
TMP_JSON=""

cleanup() {
    if [ -n "$TMP_JSON" ] && [ -f "$TMP_JSON" ]; then
        rm -f "$TMP_JSON"
    fi
}
trap cleanup EXIT

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "Validating $CONFIG_FILE..."

if [[ "$CONFIG_FILE" == *.toml ]]; then
    TMP_JSON="$(mktemp)"
    if ! python - "$CONFIG_FILE" "$TMP_JSON" <<'PY'
import json
import sys

config_path, output_path = sys.argv[1], sys.argv[2]

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:
    try:
        import tomli as tomllib  # Backport
    except ModuleNotFoundError:
        sys.stderr.write("Error: tomllib/tomli is required to parse TOML. Install tomli or use Python 3.11+.\n")
        sys.exit(1)

with open(config_path, "rb") as f:
    data = tomllib.load(f)

def normalize_to_mcp_servers(obj):
    # New format (recommended)
    for key in ("mcpServers", "mcp_servers", "mcp-servers"):
        value = obj.get(key)
        if isinstance(value, dict):
            return value

    # Legacy format: [[children]] with name field
    children = obj.get("children")
    if isinstance(children, list):
        servers = {}
        for idx, entry in enumerate(children):
            if not isinstance(entry, dict):
                raise ValueError(f"Entry {idx + 1} is not a table/object.")
            name = entry.get("name")
            if not isinstance(name, str) or not name:
                raise ValueError(f"Entry {idx + 1} is missing 'name'.")
            server = dict(entry)
            server.pop("name", None)
            servers[name] = server
        return servers

    raise ValueError("TOML must define either [mcp-servers.<name>] (recommended) or [[children]] (legacy).")


try:
    if isinstance(data, dict):
        mcp_servers = normalize_to_mcp_servers(data)
    else:
        raise ValueError("TOML root must be a table/object.")
except Exception as e:
    sys.stderr.write(f"Error: {e}\n")
    sys.exit(1)

with open(output_path, "w", encoding="utf-8") as f:
    json.dump({"mcpServers": mcp_servers}, f, ensure_ascii=False)
PY
    then
        exit 1
    fi
    VALIDATION_TARGET="$TMP_JSON"
else
    VALIDATION_TARGET="$CONFIG_FILE"
fi

# Check if file is valid JSON
if ! jq empty "$VALIDATION_TARGET" 2>/dev/null; then
    echo "Error: Invalid JSON syntax"
    exit 1
fi

# Extract server map (supports new and legacy shapes)
SERVER_MAP="$(jq -c '
  if type == "object" and (.mcpServers? | type == "object") then .mcpServers
  elif type == "array" then (map(select(type=="object" and (.name? | type=="string"))) | map({(.name): (del(.name))}) | add) // {}
  elif type == "object" then .
  else {}
  end
' "$VALIDATION_TARGET")"

server_count="$(printf '%s' "$SERVER_MAP" | jq 'keys | length')"
echo "Found $server_count server(s)"

if [ "$server_count" -eq 0 ]; then
    echo ""
    echo "✓ Configuration is valid (no servers configured yet)"
    echo ""
    echo "Summary:"
    echo "  Total servers: 0"
    echo "  Configuration file: $CONFIG_FILE"
    exit 0
fi

while IFS= read -r name; do
    echo ""
    echo "Validating server: $name"

    command="$(printf '%s' "$SERVER_MAP" | jq -r --arg n "$name" '.[$n].command // empty')"
    if [ -z "$command" ] || [ "$command" = "null" ]; then
        echo "  Error: Missing 'command' field"
        exit 1
    fi
    echo "  Command: $command"

    if [ "$(printf '%s' "$SERVER_MAP" | jq -r --arg n "$name" '.[$n].args | type')" != "array" ]; then
        echo "  Error: 'args' must be an array"
        exit 1
    fi
    echo "  Args: $(printf '%s' "$SERVER_MAP" | jq -c --arg n "$name" '.[$n].args')"

    if [ "$(printf '%s' "$SERVER_MAP" | jq -r --arg n "$name" '.[$n] | has("env")')" = "true" ]; then
        if [ "$(printf '%s' "$SERVER_MAP" | jq -r --arg n "$name" '.[$n].env | type')" != "object" ]; then
            echo "  Error: 'env' must be an object"
            exit 1
        fi
        echo "  Env: $(printf '%s' "$SERVER_MAP" | jq -c --arg n "$name" '.[$n].env')"
    else
        echo "  Env: (not specified)"
    fi

    if ! command -v "$command" &> /dev/null; then
        echo "  Warning: Command '$command' not found in PATH"
    else
        echo "  ✓ Command found: $(command -v "$command")"
    fi
done < <(printf '%s' "$SERVER_MAP" | jq -r 'keys[]')

echo ""
echo "✓ Configuration validation passed!"
echo ""
echo "Summary:"
echo "  Total servers: $server_count"
echo "  Configuration file: $CONFIG_FILE"
