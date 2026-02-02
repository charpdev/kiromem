import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import { homedir } from 'os';
export class MemoryStore {
    data = new Map();
    dbPath;
    constructor() {
        const kiroDir = join(homedir(), '.kiro-mem');
        if (!existsSync(kiroDir)) {
            mkdirSync(kiroDir, { recursive: true });
        }
        this.dbPath = join(kiroDir, 'contexts.json');
        this.loadData();
    }
    loadData() {
        if (existsSync(this.dbPath)) {
            try {
                const fileData = readFileSync(this.dbPath, 'utf8');
                const entries = JSON.parse(fileData);
                this.data = new Map(Object.entries(entries));
            }
            catch (error) {
                console.error('Failed to load data:', error);
            }
        }
    }
    saveData() {
        try {
            const dataObj = Object.fromEntries(this.data);
            writeFileSync(this.dbPath, JSON.stringify(dataObj, null, 2));
        }
        catch (error) {
            console.error('Failed to save data:', error);
        }
    }
    async store(key, content, tags = []) {
        const now = new Date().toISOString();
        const entry = {
            key,
            content,
            tags,
            created_at: this.data.has(key) ? this.data.get(key).created_at : now,
            updated_at: now
        };
        this.data.set(key, entry);
        this.saveData();
    }
    async retrieve(key, tags, limit = 10) {
        if (key) {
            const entry = this.data.get(key);
            return entry ? [entry] : [];
        }
        if (tags && tags.length > 0) {
            const results = [];
            for (const entry of this.data.values()) {
                const hasMatchingTag = tags.some(tag => entry.tags.some(entryTag => entryTag.toLowerCase().includes(tag.toLowerCase())));
                if (hasMatchingTag) {
                    results.push(entry);
                }
                if (results.length >= limit)
                    break;
            }
            return results.sort((a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime());
        }
        return [];
    }
    async list(limit = 50) {
        const entries = Array.from(this.data.values())
            .sort((a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime())
            .slice(0, limit);
        return entries;
    }
    async getAutoSessions(limit = 10) {
        const autoSessionsPath = join(homedir(), '.kiro-mem', 'auto-sessions.jsonl');
        if (!existsSync(autoSessionsPath)) {
            return [];
        }
        try {
            const content = readFileSync(autoSessionsPath, 'utf8');
            const lines = content.trim().split('\n').filter(line => line.trim());
            const sessions = lines
                .map(line => {
                try {
                    return JSON.parse(line);
                }
                catch {
                    return null;
                }
            })
                .filter(session => session !== null)
                .slice(-limit) // Get last N sessions
                .reverse(); // Most recent first
            return sessions;
        }
        catch (error) {
            console.error('Failed to read auto-sessions:', error);
            return [];
        }
    }
    async delete(key) {
        const existed = this.data.has(key);
        this.data.delete(key);
        if (existed) {
            this.saveData();
        }
        return existed;
    }
    close() {
        this.saveData();
    }
}
//# sourceMappingURL=memory.js.map