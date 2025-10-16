import { Request, Response, NextFunction } from "express";
import { TodosService } from "../services/todos.service";
import {
  CreateTodoDto,
  UpdateTodoDto,
  PaginationQuery,
} from "../schemas/todo.schema";

// ========================================
// Controller: nhận req, validate, gọi service
// ========================================
// - Không chứa logic lưu trữ
// - Trả JSON rõ ràng

export class TodosController {
  constructor(private readonly service: TodosService) {}

  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = PaginationQuery.safeParse(req.query);
      if (!parsed.success) {
        return res.status(400).json({ error: "Query không hợp lệ", details: parsed.error.flatten() });
      }
      const result = await this.service.getPaginated(parsed.data);
      res.json(result);
    } catch (err) {
      next(err);
    }
  };

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = CreateTodoDto.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({ error: "Body không hợp lệ", details: parsed.error.flatten() });
      }
      const todo = await this.service.create(parsed.data);
      res.status(201).json(todo);
    } catch (err) {
      next(err);
    }
  };

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = req.params.id;
      const parsed = UpdateTodoDto.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({ error: "Body không hợp lệ", details: parsed.error.flatten() });
      }
      const todo = await this.service.update(id, parsed.data);
      res.json(todo);
    } catch (err) {
      next(err);
    }
  };

  toggle = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = req.params.id;
      const todo = await this.service.toggle(id);
      res.json(todo);
    } catch (err) {
      next(err);
    }
  };

  remove = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = req.params.id;
      const result = await this.service.delete(id);
      res.json(result);
    } catch (err) {
      next(err);
    }
  };
}
