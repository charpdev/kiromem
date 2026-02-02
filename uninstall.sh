#!/usr/bin/env bash

set -e

echo "🗑️  Uninstalling Kiro Memory MCP Server..."

AGENTS_DIR="$HOME/.kiro/agents"
AGENT_FILE="$AGENTS_DIR/default.json"

if [ ! -f "$AGENT_FILE" ]; then
    echo "❌ No default agent configuration found at $AGENT_FILE"
    exit 1
fi

echo "📝 Removing kiro-mem from agent configuration..."

# Create backup
cp "$AGENT_FILE" "$AGENT_FILE.backup.$(date +%s)"

# Use Node.js to remove the MCP server from existing config
node -e "
    const fs = require('fs');
    const config = JSON.parse(fs.readFileSync('$AGENT_FILE', 'utf8'));
    
    // Remove kiro-mem server
    if (config.mcpServers && config.mcpServers['kiro-mem']) {
        delete config.mcpServers['kiro-mem'];
        
        // Remove empty mcpServers object
        if (Object.keys(config.mcpServers).length === 0) {
            delete config.mcpServers;
        }
    }
    
    // Remove from allowedTools
    if (config.allowedTools) {
        config.allowedTools = config.allowedTools.filter(tool => tool !== '@kiro-mem/*');
        
        // Remove empty allowedTools array
        if (config.allowedTools.length === 0) {
            delete config.allowedTools;
        }
    }
    
    fs.writeFileSync('$AGENT_FILE', JSON.stringify(config, null, 2));
"

echo "✅ Uninstallation complete!"
echo ""
echo "📝 Note: Stored contexts remain in ~/.kiro-mem/contexts.db"
echo "   To remove all data: rm -rf ~/.kiro-mem/"
echo ""
echo "🔄 Restart Kiro CLI to apply changes"
