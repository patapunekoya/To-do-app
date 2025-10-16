import { z } from "zod";

// =============================
// Zod schema: validate dữ liệu
// =============================

// Entity Todo (server side)
export const TodoSchema = z.object({
  id: z.string().min(1, "id là bắt buộc"),
  title: z.string().trim().min(1, "Tiêu đề không được trống").max(120),
  isCompleted: z.boolean(),
  createdAt: z.coerce.date(), // cho phép string -> Date
});
export type Todo = z.infer<typeof TodoSchema>;

// DTO tạo mới (client không gửi id/createdAt)
export const CreateTodoDto = z.object({
  title: z.string().trim().min(1).max(120),
});
export type CreateTodoDto = z.infer<typeof CreateTodoDto>;

// DTO cập nhật tiêu đề
export const UpdateTodoDto = z.object({
  title: z.string().trim().min(1).max(120),
});
export type UpdateTodoDto = z.infer<typeof UpdateTodoDto>;

// DTO query phân trang offset/limit
export const PaginationQuery = z.object({
  offset: z.coerce.number().int().min(0).default(0),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});
export type PaginationQuery = z.infer<typeof PaginationQuery>;

// Lỗi HTTP chuẩn hóa
export class HttpError extends Error {
  status: number;
  details?: any;
  constructor(status: number, message: string, details?: any) {
    super(message);
    this.status = status;
    this.details = details;
  }
}
