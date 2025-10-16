import { randomUUID } from "crypto";
import { Todo } from "../schemas/todo.schema";

// ===============================
// Repository interface + in-memory
// ===============================

export interface ITodosRepository {
  listPaginated(offset: number, limit: number): Promise<Todo[]>;
  count(): Promise<number>;
  findById(id: string): Promise<Todo | null>;
  create(title: string): Promise<Todo>;
  updateTitle(id: string, title: string): Promise<Todo>;
  toggleComplete(id: string): Promise<Todo>;
  delete(id: string): Promise<void>;
}

/**
 * InMemoryTodosRepository
 * - Lưu trong RAM (Map), đủ cho demo/dev.
 * - Sau này thay bằng Prisma/Mongo/SQLite chỉ cần implement lại interface này.
 */
export class InMemoryTodosRepository implements ITodosRepository {
  private store = new Map<string, Todo>();

  async listPaginated(offset: number, limit: number): Promise<Todo[]> {
    // sort theo createdAt desc để giống app Flutter
    const all = Array.from(this.store.values()).sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
    );
    return all.slice(offset, offset + limit);
  }

  async count(): Promise<number> {
    return this.store.size;
  }

  async findById(id: string): Promise<Todo | null> {
    return this.store.get(id) ?? null;
  }

  async create(title: string): Promise<Todo> {
    const todo: Todo = {
      id: randomUUID(),
      title,
      isCompleted: false,
      createdAt: new Date(),
    };
    this.store.set(todo.id, todo);
    return todo;
  }

  async updateTitle(id: string, title: string): Promise<Todo> {
    const cur = this.store.get(id);
    if (!cur) throw new Error("Not found");
    const updated: Todo = { ...cur, title };
    this.store.set(id, updated);
    return updated;
  }

  async toggleComplete(id: string): Promise<Todo> {
    const cur = this.store.get(id);
    if (!cur) throw new Error("Not found");
    const updated: Todo = { ...cur, isCompleted: !cur.isCompleted };
    this.store.set(id, updated);
    return updated;
  }

  async delete(id: string): Promise<void> {
    this.store.delete(id);
  }
}
