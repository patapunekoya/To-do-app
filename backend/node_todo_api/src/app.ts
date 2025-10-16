import express, { Request, Response, NextFunction } from "express";
import cors from "cors";
import todosRouter from "./routes/todos.routes";

// ===============
// Khởi tạo Express
// ===============
const app = express();

// Middleware cơ bản
app.use(cors());                // Cho phép gọi từ app Flutter
app.use(express.json());        // Parse JSON body
app.use(express.urlencoded({ extended: true }));

// Health check
app.get("/health", (_req, res) => res.json({ ok: true }));

// Routes
app.use("/todos", todosRouter);

// ===============
// Middleware bắt lỗi tập trung
// ===============
app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
  const status = err?.status ?? 500;
  const payload = {
    error: err?.message ?? "Internal Server Error",
    details: err?.details ?? undefined,
  };
  if (process.env.NODE_ENV !== "production") {
    // log nội bộ khi dev
    console.error("[ERROR]", err);
  }
  res.status(status).json(payload);
});

export default app;
