import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { MemoryStore } from './memory.js';

class KiroMemServer {
  private server: Server;
  private memory: MemoryStore;

  constructor() {
    this.server = new Server(
      {
        name: 'kiro-mem',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );
    
    this.memory = new MemoryStore();
    this.setupHandlers();
  }

  private setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'store_context',
          description: 'Store context information for future sessions',
          inputSchema: {
            type: 'object',
            properties: {
              key: { type: 'string', description: 'Unique identifier for the context' },
              content: { type: 'string', description: 'Context content to store' },
              tags: { type: 'array', items: { type: 'string' }, description: 'Optional tags for categorization' }
            },
            required: ['key', 'content']
          }
        },
        {
          name: 'auto_store_session',
          description: 'Automatically store the current conversation context',
          inputSchema: {
            type: 'object',
            properties: {
              session_id: { type: 'string', description: 'Optional session identifier' },
              tags: { type: 'array', items: { type: 'string' }, description: 'Optional tags for categorization' }
            }
          }
        },
        {
          name: 'restore_session',
          description: 'Restore context from previous sessions',
          inputSchema: {
            type: 'object',
            properties: {
              session_id: { type: 'string', description: 'Specific session to restore' },
              limit: { type: 'number', description: 'Number of recent sessions to show', default: 5 }
            }
          }
        },
        {
          name: 'retrieve_context',
          description: 'Retrieve stored context by key or search by tags',
          inputSchema: {
            type: 'object',
            properties: {
              key: { type: 'string', description: 'Specific key to retrieve' },
              tags: { type: 'array', items: { type: 'string' }, description: 'Search by tags' },
              limit: { type: 'number', description: 'Maximum number of results', default: 10 }
            }
          }
        },
        {
          name: 'list_contexts',
          description: 'List all stored contexts with optional filtering',
          inputSchema: {
            type: 'object',
            properties: {
              limit: { type: 'number', description: 'Maximum number of results', default: 50 }
            }
          }
        },
        {
          name: 'delete_context',
          description: 'Delete a stored context by key',
          inputSchema: {
            type: 'object',
            properties: {
              key: { type: 'string', description: 'Key of context to delete' }
            },
            required: ['key']
          }
        }
      ]
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      if (!args) {
        throw new Error('Missing arguments');
      }

      switch (name) {
        case 'store_context':
          await this.memory.store(args.key as string, args.content as string, (args.tags as string[]) || []);
          return { content: [{ type: 'text', text: `Context stored with key: ${args.key}` }] };

        case 'auto_store_session':
          const sessionId = (args.session_id as string) || `session-${Date.now()}`;
          const sessionContent = `Auto-stored session context at ${new Date().toISOString()}`;
          await this.memory.store(sessionId, sessionContent, (args.tags as string[]) || ['auto-session']);
          return { content: [{ type: 'text', text: `Session auto-stored with key: ${sessionId}` }] };

        case 'restore_session':
          if (args.session_id) {
            const session = await this.memory.retrieve(args.session_id as string);
            return { content: [{ type: 'text', text: session.length > 0 ? JSON.stringify(session[0], null, 2) : 'Session not found' }] };
          } else {
            const autoSessions = await this.memory.getAutoSessions(args.limit as number || 5);
            return { content: [{ type: 'text', text: `Recent auto-captured sessions:\n${JSON.stringify(autoSessions, null, 2)}` }] };
          }

        case 'retrieve_context':
          const results = await this.memory.retrieve(args.key as string, args.tags as string[], args.limit as number);
          return { 
            content: [{ 
              type: 'text', 
              text: results.length > 0 
                ? JSON.stringify(results, null, 2)
                : 'No contexts found'
            }] 
          };

        case 'list_contexts':
          const contexts = await this.memory.list(args.limit as number);
          return { 
            content: [{ 
              type: 'text', 
              text: JSON.stringify(contexts, null, 2)
            }] 
          };

        case 'delete_context':
          const deleted = await this.memory.delete(args.key as string);
          return { 
            content: [{ 
              type: 'text', 
              text: deleted ? `Context deleted: ${args.key}` : `Context not found: ${args.key}`
            }] 
          };

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new KiroMemServer();
server.run().catch(console.error);
