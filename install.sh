#!/usr/bin/env bash

set -e

echo "🚀 Installing Kiro Memory MCP Server..."

# Get the absolute path to the project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_PATH="$PROJECT_DIR/dist/index.js"

# Build the project
echo "📦 Building project..."
npm install
npm run build

# Verify build output exists
if [ ! -f "$DIST_PATH" ]; then
    echo "❌ Build failed: $DIST_PATH not found"
    exit 1
fi

# Create Kiro agents directory
AGENTS_DIR="$HOME/.kiro/agents"
AGENT_FILE="$AGENTS_DIR/default.json"

echo "📁 Creating agents directory..."
mkdir -p "$AGENTS_DIR"

# Check if default agent already exists
if [ -f "$AGENT_FILE" ]; then
    echo "⚠️  Default agent already exists at $AGENT_FILE"
    echo "   Adding kiro-mem MCP server to existing configuration..."
    
    # Create backup
    cp "$AGENT_FILE" "$AGENT_FILE.backup.$(date +%s)"
    
    # Use Node.js to merge the MCP server into existing config
    node -e "
        const fs = require('fs');
        let config;
        
        try {
            config = JSON.parse(fs.readFileSync('$AGENT_FILE', 'utf8'));
        } catch (e) {
            console.error('Invalid JSON in agent file, creating new config');
            config = { description: 'Default agent with kiro-mem MCP server' };
        }
        
        // Add name field if missing
        if (!config.name) {
            config.name = 'default';
        }
        
        // Initialize mcpServers if it doesn't exist
        if (!config.mcpServers) {
            config.mcpServers = {};
        }
        
        // Add kiro-mem server
        config.mcpServers['kiro-mem'] = {
            command: 'node',
            args: ['$DIST_PATH']
        };
        
        // Add to allowedTools if it exists, otherwise create it
        if (!config.allowedTools) {
            config.allowedTools = [];
        }
        
        // Add kiro-mem tools if not already present
        if (!config.allowedTools.includes('@kiro-mem/*')) {
            config.allowedTools.push('@kiro-mem/*');
        }
        
        fs.writeFileSync('$AGENT_FILE', JSON.stringify(config, null, 2));
    "
else
    echo "📝 Creating new default agent configuration..."
    cat > "$AGENT_FILE" << EOF
{
  "name": "default",
  "description": "Default agent with kiro-mem MCP server",
  "mcpServers": {
    "kiro-mem": {
      "command": "node",
      "args": ["$DIST_PATH"]
    }
  },
  "allowedTools": ["@kiro-mem/*"],
  "hooks": {
    "stop": [
      {
        "command": "$PROJECT_DIR/hooks/auto-store.sh"
      }
    ]
  }
}
EOF
fi

# Check for auto-storage hooks option
if [ "$ENABLE_HOOKS" = "y" ] || [ "$ENABLE_HOOKS" = "Y" ]; then
    echo "📋 Adding auto-storage hooks..."
    
    # Add hooks to the agent configuration
    node -e "
        const fs = require('fs');
        let config;
        
        try {
            config = JSON.parse(fs.readFileSync('$AGENT_FILE', 'utf8'));
        } catch (e) {
            console.error('Invalid JSON in agent file');
            process.exit(1);
        }
        
        // Add hooks object if it doesn't exist
        if (!config.hooks) {
            config.hooks = {};
        }
        
        // Add stop hooks array if it doesn't exist
        if (!config.hooks.stop) {
            config.hooks.stop = [];
        }
        
        // Add auto-storage hook
        const hookExists = config.hooks.stop.some(hook => 
            hook.command && hook.command.includes('auto-store.sh')
        );
        
        if (!hookExists) {
            config.hooks.stop.push({
                command: '$PROJECT_DIR/hooks/auto-store.sh'
            });
        }
        
        fs.writeFileSync('$AGENT_FILE', JSON.stringify(config, null, 2));
    "
    
    echo "✅ Auto-storage hooks enabled!"
else
    echo "🔧 To enable auto-storage hooks, run: ENABLE_HOOKS=y ./install.sh"
fi

echo "✅ Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Start Kiro CLI: kiro-cli chat"
echo "   2. Verify MCP server is loaded: /mcp"
echo "   3. Use the tools:"
echo "      > Use store_context to save information"
echo "      > Use retrieve_context to search contexts"
echo "      > Use list_contexts to view all stored data"
echo ""
if [ "$ENABLE_HOOKS" = "y" ] || [ "$ENABLE_HOOKS" = "Y" ]; then
    echo "🤖 Auto-storage hooks are enabled - sessions will be automatically captured!"
    echo "📂 Manual contexts: ~/.kiro-mem/contexts.json"
    echo "📋 Auto-sessions: ~/.kiro-mem/auto-sessions.jsonl"
else
    echo "📂 Data will be stored in: ~/.kiro-mem/contexts.json"
fi
echo "⚙️  Agent config: $AGENT_FILE"
