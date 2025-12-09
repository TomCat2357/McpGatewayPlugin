# Advanced Patterns and Best Practices

Advanced usage patterns, optimization strategies, and best practices for MCP Gateway.

## Architecture Patterns

### Gateway as Orchestration Layer

Use MCP Gateway to orchestrate complex multi-server workflows.

**Pattern:**
```
User Request
    ↓
MCP Gateway (Orchestrator)
    ↓
├─→ Serena (Code Search)
├─→ Codegraph (Analysis)
├─→ Context7 (Docs)
└─→ Filesystem (Operations)
    ↓
Aggregated Result
```

**Benefits:**
- Single entry point for multiple services
- Unified error handling
- Session management abstracted
- Simplified client integration

**Implementation:**
```json
{
  "workflow": [
    {"server": "serena", "tool": "search_code", "args": {...}},
    {"server": "codegraph", "tool": "analyze", "args": {...}},
    {"server": "filesystem", "tool": "write_file", "args": {...}}
  ]
}
```

### Layered Service Architecture

Organize child servers by layer:

**Data Layer:**
```json
[
  {"name": "sqlite", ...},
  {"name": "postgres", ...}
]
```

**Logic Layer:**
```json
[
  {"name": "codegraph", ...},
  {"name": "serena", ...}
]
```

**Integration Layer:**
```json
[
  {"name": "github", ...},
  {"name": "slack", ...}
]
```

**Benefits:**
- Clear separation of concerns
- Easier troubleshooting
- Independent scaling
- Modular configuration

### Microservices Gateway

Use MCP Gateway as API gateway for MCP microservices.

**Pattern:**
```
MCP Gateway
    ↓
├─→ Auth Service (MCP)
├─→ Data Service (MCP)
├─→ Analytics Service (MCP)
└─→ Notification Service (MCP)
```

Each service is an independent MCP server with focused responsibilities.

---

## Performance Optimization

### Output Truncation Strategies

Optimize large outputs with strategic truncation.

**Preview Pattern:**
```json
{
  "head": 100,
  "tail": 0
}
```
Get first 100 lines for quick preview.

**Summary Pattern:**
```json
{
  "head": 50,
  "tail": 50
}
```
Get context from start and end.

**Recent Data Pattern:**
```json
{
  "head": 0,
  "tail": 200
}
```
Focus on recent/final results.

**Adaptive Truncation:**
```python
def adaptive_truncate(estimated_size):
    if estimated_size < 1000:
        return {"head": None, "tail": None}  # No truncation
    elif estimated_size < 10000:
        return {"head": 500, "tail": 500}
    else:
        return {"head": 200, "tail": 200}
```

### Session Pooling

Manage sessions efficiently for better performance.

**Keep-Alive Pattern:**
```
1. Execute tool on server A
2. Keep session alive
3. Execute another tool on server A (reuse session)
4. Close when done with server A
```

**Lazy Loading:**
```
1. Start sessions only when needed
2. Close after idle period
3. Restart on next use
```

**Pre-warming:**
```
1. Start common servers at startup
2. Keep sessions alive during work session
3. Close all at end of day
```

### Caching Strategies

Cache results to reduce repeated calls.

**Schema Caching:**
```python
schema_cache = {}

def get_cached_schema(server_id):
    if server_id not in schema_cache:
        schema_cache[server_id] = get_schema(server_id)
    return schema_cache[server_id]
```

**Result Caching:**
```python
from functools import lru_cache

@lru_cache(maxsize=100)
def cached_tool_call(server_id, tool_name, args_hash):
    return execute_child_tool(server_id, tool_name, args)
```

**Invalidation Strategy:**
- Clear cache on configuration changes
- Time-based expiration for dynamic data
- Event-based invalidation for file operations

---

## Error Handling

### Graceful Degradation

Handle server failures gracefully.

**Pattern:**
```python
def robust_search(query):
    try:
        # Try primary search server
        return execute_child_tool("serena", "search_code", {"query": query})
    except ServerError:
        # Fall back to secondary server
        try:
            return execute_child_tool("backup-search", "search", {"query": query})
        except ServerError:
            # Final fallback to simple grep
            return grep_search(query)
```

**Benefits:**
- System remains functional
- User experience maintained
- Automatic failover
- Transparent recovery

### Retry Logic

Implement intelligent retry for transient failures.

**Exponential Backoff:**
```python
import time

def retry_with_backoff(func, max_retries=3):
    for attempt in range(max_retries):
        try:
            return func()
        except TransientError as e:
            if attempt == max_retries - 1:
                raise
            wait_time = 2 ** attempt
            time.sleep(wait_time)
```

**Selective Retry:**
```python
RETRYABLE_ERRORS = ["TIMEOUT", "CONNECTION_LOST", "SERVER_BUSY"]

def should_retry(error):
    return error.code in RETRYABLE_ERRORS

def smart_retry(func):
    try:
        return func()
    except ServerError as e:
        if should_retry(e):
            time.sleep(1)
            return func()
        raise
```

### Circuit Breaker

Prevent cascading failures with circuit breaker pattern.

**Implementation:**
```python
class CircuitBreaker:
    def __init__(self, threshold=5, timeout=60):
        self.failure_count = 0
        self.threshold = threshold
        self.timeout = timeout
        self.state = "closed"  # closed, open, half-open
        self.last_failure_time = None

    def call(self, func):
        if self.state == "open":
            if time.time() - self.last_failure_time > self.timeout:
                self.state = "half-open"
            else:
                raise CircuitOpenError()

        try:
            result = func()
            self.on_success()
            return result
        except Exception as e:
            self.on_failure()
            raise

    def on_success(self):
        self.failure_count = 0
        self.state = "closed"

    def on_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        if self.failure_count >= self.threshold:
            self.state = "open"
```

**Usage:**
```python
serena_breaker = CircuitBreaker()

def safe_search(query):
    return serena_breaker.call(
        lambda: execute_child_tool("serena", "search_code", {"query": query})
    )
```

---

## Security Patterns

### Environment Variable Management

Securely manage sensitive credentials.

**Never hardcode:**
```json
// DON'T DO THIS
{
  "env": {
    "API_KEY": "sk-1234567890abcdef"
  }
}
```

**Use environment variables:**
```json
// DO THIS
{
  "env": {
    "API_KEY": "${API_KEY}"
  }
}
```

**Load from secure storage:**
```bash
# In shell startup file
export API_KEY=$(security find-generic-password -a ${USER} -s api_key -w)
```

**Use .env files (gitignored):**
```bash
# .env
API_KEY=sk-1234567890abcdef
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
```

```bash
# Load in shell
set -a
source .env
set +a
```

### Least Privilege

Configure child servers with minimal permissions.

**File Access:**
```json
{
  "name": "filesystem",
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "/specific/allowed/path"  // Not /
  ]
}
```

**Database Access:**
```json
{
  "name": "sqlite",
  "env": {
    "DB_MODE": "readonly"  // Read-only when possible
  }
}
```

**API Scopes:**
```json
{
  "name": "github",
  "env": {
    "GITHUB_TOKEN": "${GITHUB_READONLY_TOKEN}"  // Limited scope token
  }
}
```

### Input Validation

Validate inputs before passing to child servers.

**Sanitize Paths:**
```python
import os

def safe_path(user_path, allowed_dir):
    # Resolve to absolute path
    abs_path = os.path.abspath(user_path)
    abs_allowed = os.path.abspath(allowed_dir)

    # Check if within allowed directory
    if not abs_path.startswith(abs_allowed):
        raise SecurityError("Path outside allowed directory")

    return abs_path
```

**Validate Queries:**
```python
def safe_sql_query(query):
    # Block dangerous operations
    dangerous_keywords = ["DROP", "DELETE", "TRUNCATE", "ALTER"]
    query_upper = query.upper()

    for keyword in dangerous_keywords:
        if keyword in query_upper:
            raise SecurityError(f"Dangerous operation: {keyword}")

    return query
```

**Sanitize Arguments:**
```python
def sanitize_args(args):
    # Remove potentially dangerous fields
    dangerous_keys = ["__proto__", "constructor", "prototype"]

    for key in dangerous_keys:
        if key in args:
            del args[key]

    return args
```

---

## Monitoring and Observability

### Health Checks

Implement health monitoring for child servers.

**Health Check Pattern:**
```python
def health_check_all():
    children = list_registered_children()
    health_status = {}

    for child in children:
        try:
            status = get_child_status(child)
            health_status[child] = {
                "status": status["status"],
                "healthy": status["status"] == "running"
            }
        except Exception as e:
            health_status[child] = {
                "status": "error",
                "healthy": False,
                "error": str(e)
            }

    return health_status
```

**Periodic Monitoring:**
```python
import schedule

def monitor_servers():
    health = health_check_all()
    unhealthy = [name for name, status in health.items() if not status["healthy"]]

    if unhealthy:
        send_alert(f"Unhealthy servers: {unhealthy}")

schedule.every(5).minutes.do(monitor_servers)
```

### Logging

Structured logging for debugging and analysis.

**Tool Call Logging:**
```python
import logging
import json

logger = logging.getLogger("mcp_gateway")

def log_tool_call(server_id, tool_name, args, result, duration):
    log_entry = {
        "timestamp": time.time(),
        "server": server_id,
        "tool": tool_name,
        "args_hash": hash(json.dumps(args)),
        "success": result.get("status") == "success",
        "duration_ms": duration * 1000
    }
    logger.info(json.dumps(log_entry))
```

**Error Logging:**
```python
def log_error(server_id, error, context):
    log_entry = {
        "timestamp": time.time(),
        "level": "error",
        "server": server_id,
        "error_type": type(error).__name__,
        "error_message": str(error),
        "context": context
    }
    logger.error(json.dumps(log_entry))
```

### Metrics Collection

Track key metrics for optimization.

**Metrics to Track:**
- Tool call latency
- Success/failure rates
- Server uptime
- Resource usage
- Cache hit rates

**Implementation:**
```python
from collections import defaultdict

metrics = {
    "calls": defaultdict(int),
    "failures": defaultdict(int),
    "latency": defaultdict(list)
}

def record_call(server_id, tool_name, duration, success):
    key = f"{server_id}.{tool_name}"
    metrics["calls"][key] += 1
    if not success:
        metrics["failures"][key] += 1
    metrics["latency"][key].append(duration)

def get_metrics_summary():
    summary = {}
    for key in metrics["calls"]:
        total_calls = metrics["calls"][key]
        failures = metrics["failures"][key]
        latencies = metrics["latency"][key]

        summary[key] = {
            "total_calls": total_calls,
            "failure_rate": failures / total_calls if total_calls > 0 else 0,
            "avg_latency": sum(latencies) / len(latencies) if latencies else 0,
            "p95_latency": sorted(latencies)[int(len(latencies) * 0.95)] if latencies else 0
        }

    return summary
```

---

## Advanced Configuration

### Dynamic Configuration

Load configuration dynamically based on context.

**Environment-Based Config:**
```python
import os

def get_config():
    env = os.environ.get("ENVIRONMENT", "development")

    if env == "production":
        return load_config("children_config_prod.toml")
    else:
        return load_config("children_config_dev.json")
```

**User-Specific Config:**
```python
def get_user_config(user_id):
    base_config = load_config("children_config_base.json")
    user_config = load_config(f"children_config_{user_id}.json")

    # Merge configurations
    return {**base_config, **user_config}
```

**Feature Flags:**
```python
def get_enabled_servers():
    all_servers = load_config("children_config.toml")
    feature_flags = load_feature_flags()

    return [
        server for server in all_servers
        if feature_flags.get(f"enable_{server['name']}", True)
    ]
```

### Configuration Validation

Validate configuration before loading.

**Schema Validation:**
```python
import jsonschema

CONFIG_SCHEMA = {
    "type": "array",
    "items": {
        "type": "object",
        "required": ["name", "command", "args"],
        "properties": {
            "name": {"type": "string"},
            "command": {"type": "string"},
            "args": {"type": "array"},
            "env": {"type": "object"}
        }
    }
}

def validate_config(config):
    try:
        jsonschema.validate(config, CONFIG_SCHEMA)
        return True
    except jsonschema.ValidationError as e:
        print(f"Invalid configuration: {e}")
        return False
```

**Custom Validation:**
```python
def validate_server_config(server):
    # Check command exists
    if not shutil.which(server["command"]):
        raise ValidationError(f"Command not found: {server['command']}")

    # Check for required env vars
    for env_var in server.get("required_env", []):
        if env_var not in os.environ:
            raise ValidationError(f"Missing environment variable: {env_var}")

    # Validate name uniqueness
    if server["name"] in seen_names:
        raise ValidationError(f"Duplicate server name: {server['name']}")

    return True
```

### Hot Reloading

Reload configuration without restarting.

**File Watcher:**
```python
import watchdog.observers
import watchdog.events

class ConfigReloader(watchdog.events.FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path.endswith(("children_config.json", "children_config.toml")):
            reload_config()

def watch_config():
    event_handler = ConfigReloader()
    observer = watchdog.observers.Observer()
    observer.schedule(event_handler, path=".", recursive=False)
    observer.start()
```

---

## Testing Strategies

### Integration Testing

Test MCP Gateway with child servers.

**Test Pattern:**
```python
import unittest

class MCPGatewayTests(unittest.TestCase):
    def setUp(self):
        # Start test child servers
        self.servers = start_test_servers()

    def tearDown(self):
        # Clean up
        for server in self.servers:
            close_child_session(server)

    def test_tool_execution(self):
        result = execute_child_tool(
            "test-server",
            "test-tool",
            {"arg": "value"}
        )
        self.assertEqual(result["status"], "success")

    def test_error_handling(self):
        with self.assertRaises(ToolNotFoundError):
            execute_child_tool("test-server", "nonexistent-tool", {})
```

### Mock Servers

Create mock MCP servers for testing.

**Simple Mock:**
```python
class MockMCPServer:
    def __init__(self, name):
        self.name = name
        self.tools = {}

    def register_tool(self, name, handler):
        self.tools[name] = handler

    def execute_tool(self, name, args):
        if name not in self.tools:
            raise ToolNotFoundError(name)
        return self.tools[name](args)
```

**Usage:**
```python
mock_server = MockMCPServer("test-server")
mock_server.register_tool("echo", lambda args: args)

result = mock_server.execute_tool("echo", {"message": "hello"})
assert result["message"] == "hello"
```

### Load Testing

Test performance under load.

**Concurrent Requests:**
```python
import concurrent.futures

def load_test(num_requests=100):
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [
            executor.submit(execute_child_tool, "serena", "search_code", {"query": f"test{i}"})
            for i in range(num_requests)
        ]

        results = [f.result() for f in futures]
        success_count = sum(1 for r in results if r["status"] == "success")

        print(f"Success rate: {success_count}/{num_requests}")
```

---

## Migration Patterns

### From Direct MCP to Gateway

Migrate from direct MCP server usage to MCP Gateway.

**Before (Multiple .mcp.json entries):**
```json
{
  "mcpServers": {
    "serena": {...},
    "context7": {...},
    "codegraph": {...}
  }
}
```

**After (Single gateway entry):**
```json
{
  "mcpServers": {
    "mcp-gateway": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/TomCat2357/MCPgateway", "mcp-gateway", "--children-config", "/path/to/children_config.toml"]
    }
  }
}
```

**Migration Steps:**
1. Create children_config.json or children_config.toml from existing .mcp.json
2. Add gateway entry to .mcp.json
3. Test gateway with one child server
4. Migrate remaining servers
5. Remove old direct entries
6. Update tool calls to use gateway

### Gradual Rollout

Roll out gateway gradually for safety.

**Phase 1: Parallel Operation**
- Run gateway alongside direct connections
- Test with non-critical servers

**Phase 2: Partial Migration**
- Move less critical servers to gateway
- Keep critical servers direct

**Phase 3: Full Migration**
- Move all servers to gateway
- Remove direct connections

**Phase 4: Optimization**
- Fine-tune configuration
- Optimize performance
- Add monitoring

---

## Best Practices Summary

### Configuration
- Use environment variables for secrets
- Validate configuration before loading
- Document all environment variables
- Use absolute paths consistently

### Performance
- Implement caching strategies
- Use output truncation
- Manage sessions efficiently
- Monitor resource usage

### Security
- Apply least privilege principle
- Validate all inputs
- Never hardcode credentials
- Use secure credential storage

### Reliability
- Implement retry logic
- Use circuit breakers
- Monitor server health
- Log errors comprehensively

### Testing
- Write integration tests
- Use mock servers for unit tests
- Perform load testing
- Validate configurations

### Operations
- Monitor metrics continuously
- Set up health checks
- Implement graceful degradation
- Plan for scaling

---

For practical examples implementing these patterns, see the `examples/` directory.
