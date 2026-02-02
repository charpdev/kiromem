interface ContextEntry {
    key: string;
    content: string;
    tags: string[];
    created_at: string;
    updated_at: string;
}
export declare class MemoryStore {
    private data;
    private dbPath;
    constructor();
    private loadData;
    private saveData;
    store(key: string, content: string, tags?: string[]): Promise<void>;
    retrieve(key?: string, tags?: string[], limit?: number): Promise<ContextEntry[]>;
    list(limit?: number): Promise<ContextEntry[]>;
    getAutoSessions(limit?: number): Promise<any[]>;
    delete(key: string): Promise<boolean>;
    close(): void;
}
export {};
//# sourceMappingURL=memory.d.ts.map