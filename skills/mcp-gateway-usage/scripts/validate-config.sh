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

servers = None
if isinstance(data, list):
    servers = data
elif isinstance(data, dict):
    for key in ("children", "servers", "config", "entries"):
        value = data.get(key)
        if isinstance(value, list):
            servers = value
            break

if servers is None:
    sys.stderr.write("Error: TOML config must provide an array of tables (e.g., [[children]]).\n")
    sys.exit(1)

for idx, entry in enumerate(servers):
    if not isinstance(entry, dict):
        sys.stderr.write(f"Error: Entry {idx + 1} is not a table/object.\n")
        sys.exit(1)

with open(output_path, "w", encoding="utf-8") as f:
    json.dump(servers, f)
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

# Check if it's an array
if [ "$(jq 'type' "$VALIDATION_TARGET")" != '"array"' ]; then
    echo "Error: Configuration must be an array of server entries"
    exit 1
fi

# Validate each server entry
server_count=$(jq 'length' "$VALIDATION_TARGET")
echo "Found $server_count server(s)"

for i in $(seq 0 $((server_count - 1))); do
    echo ""
    echo "Validating server $((i + 1))..."

    # Check required fields
    name=$(jq -r ".[$i].name // empty" "$VALIDATION_TARGET")
    command=$(jq -r ".[$i].command // empty" "$VALIDATION_TARGET")
    args=$(jq -r ".[$i].args // empty" "$VALIDATION_TARGET")

    if [ -z "$name" ]; then
        echo "  Error: Missing 'name' field"
        exit 1
    fi
    echo "  Name: $name"

    if [ -z "$command" ]; then
        echo "  Error: Missing 'command' field"
        exit 1
    fi
    echo "  Command: $command"

    if [ -z "$args" ]; then
        echo "  Error: Missing 'args' field"
        exit 1
    fi

    # Check if args is an array
    if [ "$(jq ".[$i].args | type" "$VALIDATION_TARGET")" != '"array"' ]; then
        echo "  Error: 'args' must be an array"
        exit 1
    fi
    echo "  Args: $(jq -c ".[$i].args" "$VALIDATION_TARGET")"

    # Check env (optional but must be object if present)
    if jq -e ".[$i].env" "$VALIDATION_TARGET" > /dev/null 2>&1; then
        if [ "$(jq ".[$i].env | type" "$VALIDATION_TARGET")" != '"object"' ]; then
            echo "  Error: 'env' must be an object"
            exit 1
        fi
        echo "  Env: $(jq -c ".[$i].env" "$VALIDATION_TARGET")"
    else
        echo "  Env: (not specified)"
    fi

    # Check if command exists
    if ! command -v "$command" &> /dev/null; then
        echo "  Warning: Command '$command' not found in PATH"
    else
        echo "  ✓ Command found: $(command -v "$command")"
    fi
done

echo ""
echo "✓ Configuration validation passed!"
echo ""
echo "Summary:"
echo "  Total servers: $server_count"
echo "  Configuration file: $CONFIG_FILE"
