import { ITodosRepository } from "../repositories/todos.repo";
import {
  CreateTodoDto,
  UpdateTodoDto,
  PaginationQuery,
  HttpError,
} from "../schemas/todo.schema";

// ========================================
// Service: nơi điều phối logic nghiệp vụ
// ========================================
// - Validate input bằng Zod (ở controller cũng có thể validate sơ bộ)
// - Gọi repository để thao tác dữ liệu
// - Ném HttpError để controller trả mã lỗi đúng

export class TodosService {
  constructor(private readonly repo: ITodosRepository) {}

  async getPaginated(query: PaginationQuery) {
    const items = await this.repo.listPaginated(query.offset, query.limit);
    const total = await this.repo.count();
    return {
      data: items,
      paging: {
        offset: query.offset,
        limit: query.limit,
        total,
        hasMore: query.offset + items.length < total,
      },
    };
  }

  async create(dto: CreateTodoDto) {
    const todo = await this.repo.create(dto.title);
    return todo;
  }

  async update(id: string, dto: UpdateTodoDto) {
    const found = await this.repo.findById(id);
    if (!found) throw new HttpError(404, "Todo không tồn tại");
    const updated = await this.repo.updateTitle(id, dto.title);
    return updated;
  }

  async toggle(id: string) {
    const found = await this.repo.findById(id);
    if (!found) throw new HttpError(404, "Todo không tồn tại");
    return this.repo.toggleComplete(id);
  }

  async delete(id: string) {
    const found = await this.repo.findById(id);
    if (!found) throw new HttpError(404, "Todo không tồn tại");
    await this.repo.delete(id);
    return { ok: true };
  }
}
