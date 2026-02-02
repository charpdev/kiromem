#!/usr/bin/env bash

# Example usage of the Kiro Memory MCP Server

echo "=== Kiro Memory MCP Server Example ==="
echo ""

echo "1. Install the MCP server:"
echo "   ./install.sh"
echo ""

echo "2. Start Kiro CLI:"
echo "   kiro-cli chat"
echo ""

echo "3. Verify MCP server is loaded:"
echo "   /mcp"
echo ""

echo "4. Example commands in Kiro CLI:"
echo ""
echo "   # Store a context"
echo '   > Use store_context with key "project-setup" and content "Completed initial setup with TypeScript and SQLite"'
echo ""
echo "   # Store with tags"
echo '   > Use store_context with key "api-config" content "API endpoint: https://api.example.com" and tags ["config", "api"]'
echo ""
echo "   # Retrieve by key"
echo '   > Use retrieve_context with key "project-setup"'
echo ""
echo "   # Search by tags"
echo '   > Use retrieve_context with tags ["config"]'
echo ""
echo "   # List all contexts"
echo '   > Use list_contexts'
echo ""
echo "   # Delete a context"
echo '   > Use delete_context with key "project-setup"'
echo ""

echo "The contexts are stored in ~/.kiro-mem/contexts.db"
echo "Agent configuration is in ~/.kiro/agents/default.json"
