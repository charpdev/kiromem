#!/usr/bin/env bash

# Hook script to automatically store session context
# This runs after each assistant response (Stop hook)

# Read hook event from stdin
HOOK_DATA=$(cat)

# Extract current working directory
CWD=$(echo "$HOOK_DATA" | grep -o '"cwd":"[^"]*"' | cut -d'"' -f4)

# Generate session context
SESSION_ID="auto-$(date +%Y%m%d-%H%M%S)"
TIMESTAMP=$(date -Iseconds)
CONTEXT_CONTENT="Auto-stored session context from $CWD at $TIMESTAMP"

# Create the kiro-mem directory if it doesn't exist
KIRO_MEM_DIR="$HOME/.kiro-mem"
mkdir -p "$KIRO_MEM_DIR"

# Store in JSONL format for auto-sessions
echo "{\"session_id\":\"$SESSION_ID\",\"content\":\"$CONTEXT_CONTENT\",\"timestamp\":\"$TIMESTAMP\",\"cwd\":\"$CWD\"}" >> "$KIRO_MEM_DIR/auto-sessions.jsonl"

echo "Auto-stored session: $SESSION_ID in $CWD" >&2

exit 0
