import { Router } from "express";
import { TodosController } from "../controllers/todos.controller";
import { TodosService } from "../services/todos.service";
import { InMemoryTodosRepository } from "../repositories/todos.repo";

// ===========================
// Wiring tạm tại router layer
// ===========================
// Với dự án lớn, có thể tách DI ra riêng (typedi, tsyringe...)
// Ở đây để đơn giản: new Repo -> new Service -> new Controller

const repo = new InMemoryTodosRepository();
const service = new TodosService(repo);
const controller = new TodosController(service);

const router = Router();

// GET /todos?offset=0&limit=20
router.get("/", controller.list);

// POST /todos  { "title": "Học DDD" }
router.post("/", controller.create);

// PUT /todos/:id  { "title": "Học DDD siêu cấp" }
router.put("/:id", controller.update);

// PATCH /todos/:id/toggle
router.patch("/:id/toggle", controller.toggle);

// DELETE /todos/:id
router.delete("/:id", controller.remove);

export default router;
