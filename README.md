# Kiro Memory MCP Server

A Model Context Protocol (MCP) server that provides persistent memory storage for Kiro CLI sessions with automatic context capture.

## Features

- Store context information with keys and tags
- Retrieve contexts by key or search by tags
- List all stored contexts
- Delete contexts
- **Auto-storage hooks** - Automatically capture session context
- JSON-based storage in `~/.kiro-mem/contexts.json`
- Session logging in `~/.kiro-mem/auto-sessions.jsonl`

## Installation

### Quick Install (Recommended)
```bash
./install.sh
```

This script will:
- Build the project
- Create/update your Kiro CLI agent configuration
- Add the MCP server to your default agent
- Set up proper tool permissions
- **Optionally configure auto-storage hooks**

### Install with Auto-Storage Hooks
```bash
ENABLE_HOOKS=y ./install.sh
```

### Manual Install
```bash
npm install
npm run build

# Then manually add to ~/.kiro/agents/default.json:
{
  "mcpServers": {
    "kiro-mem": {
      "command": "node",
      "args": ["/path/to/kiro-mem/dist/index.js"]
    }
  },
  "allowedTools": ["@kiro-mem/*"],
  "hooks": [
    {
      "event": "Stop",
      "command": "/path/to/kiro-mem/hooks/auto-store.sh",
      "description": "Auto-store session context after each response"
    }
  ]
}
```

### Uninstall
```bash
./uninstall.sh
```

## Usage

After installation, start Kiro CLI and the tools will be automatically available:

```bash
kiro-cli chat
```

Verify the MCP server is loaded:
```bash
/mcp
```

Available tools:
- `store_context` - Store information for future sessions
- `auto_store_session` - Automatically store current conversation context
- `restore_session` - Restore context from previous sessions
- `retrieve_context` - Search stored contexts by key or tags  
- `list_contexts` - View all stored contexts
- `delete_context` - Remove stored contexts

## Tools

### store_context
Store context information for future sessions.
- `key` (required): Unique identifier
- `content` (required): Context content
- `tags` (optional): Array of tags for categorization

### auto_store_session
Automatically store current conversation context.
- `session_id` (optional): Session identifier (auto-generated if not provided)
- `tags` (optional): Array of tags for categorization

### restore_session
Restore context from previous sessions.
- `session_id` (optional): Specific session to restore
- `limit` (optional): Number of recent sessions to show (default: 5)

### retrieve_context
Retrieve stored context by key or search by tags.
- `key` (optional): Specific key to retrieve
- `tags` (optional): Array of tags to search by
- `limit` (optional): Maximum results (default: 10)

### list_contexts
List all stored contexts.
- `limit` (optional): Maximum results (default: 50)

### delete_context
Delete a stored context.
- `key` (required): Key of context to delete

## Auto-Storage Hooks

When enabled, hooks automatically capture session context:

### Hook Features
- **Automatic Triggering**: Runs after each assistant response
- **Session Logging**: Creates unique session IDs with timestamps
- **Working Directory Tracking**: Captures current working directory
- **No Manual Intervention**: Works transparently in background

### Hook Data Storage
- **Manual contexts**: `~/.kiro-mem/contexts.json`
- **Auto-captured sessions**: `~/.kiro-mem/auto-sessions.jsonl`

### Viewing Auto-Captured Sessions
```bash
cat ~/.kiro-mem/auto-sessions.jsonl
```

## Example Usage

```bash
# Install with auto-storage hooks
ENABLE_HOOKS=y ./install.sh

# Start Kiro CLI
kiro-cli chat

# Manual storage
> Use store_context to save "project setup complete" with key "setup-status"

# Auto-storage (happens automatically after each response)
# Check auto-captured sessions
> Use restore_session to see recent auto-captured sessions

# Retrieve contexts
> Use retrieve_context with tags ["setup", "project"]

# List all contexts
> Use list_contexts to see all stored information
```
# kiromem
