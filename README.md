<h1 align="center">🧭 Todo-Mini</h1>

<p align="center">
  <b>Fullstack Todo App built with Flutter + Node.js</b><br>
  <sub>Applying Domain-Driven Design (DDD) & Modularization Architecture</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="flutter" />
  <img src="https://img.shields.io/badge/Node.js-20-green?logo=node.js" alt="node" />
  <img src="https://img.shields.io/badge/Architecture-DDD%20%26%20Modular-orange" />
</p>

---

## 🌱 Overview

**Todo-Mini** là dự án demo fullstack nhỏ gọn, áp dụng **Clean Architecture** & **DDD**:  
- 🧩 **Frontend (Flutter)**  
  - Sử dụng **BLoC pattern** để quản lý trạng thái.  
  - Lưu trữ local bằng **Hive**.  
  - Hỗ trợ phân trang **“Load more”** (10 item/lần).  
- ⚙️ **Backend (Node.js + TypeScript)**  
  - REST API với **Express**.  
  - Kiểm tra dữ liệu bằng **Zod**.  
  - Áp dụng **Service–Repository pattern** dễ mở rộng.

---

## 🏗️ Project Structure

```plaintext
todo-mini/
├─ apps/
│  └─ flutter_todo/            # Flutter frontend (BLoC, UI, DI)
├─ packages/
│  ├─ core/                    # Shared utilities, logger, Either, UseCase base
│  ├─ todos_domain/            # Domain entities, value objects, repositories, usecases
│  ├─ todos_data/              # Data layer (Hive local, repository impl)
│  └─ todos_application/       # Application layer (BLoC, DI)
└─ backend/
   └─ node_todo_api/           # Node.js API (Express + TypeScript + Zod)
⚙️ Setup & Run
🖥️ Backend
bash
Sao chép mã
cd backend/node_todo_api
npm install
npm run dev
# => Server chạy tại http://localhost:3000
API Endpoints

Method	Endpoint	Description
GET	/todos?offset=0&limit=10	Lấy danh sách Todo có phân trang
POST	/todos	Tạo Todo mới
PUT	/todos/:id	Cập nhật tiêu đề
PATCH	/todos/:id/toggle	Đánh dấu hoàn thành
DELETE	/todos/:id	Xóa Todo

📱 Flutter App
bash
Sao chép mã
cd apps/flutter_todo
flutter pub get
flutter run
Tính năng:

Thêm / sửa / xóa / toggle công việc.

Load 10 item/lần – bấm “Xem thêm” để tải thêm.

Lưu cục bộ bằng Hive.

Có thể đồng bộ backend Node qua API.

🧠 Technologies
Layer	Tech Stack
Frontend	Flutter, Dart, BLoC, Hive
Backend	Node.js, TypeScript, Express, Zod
Architecture	Domain-Driven Design, Modularization
Utilities	GetIt, Equatable, Logger, Build Runner

📦 Folder Highlights (Flutter)
plaintext
Sao chép mã
packages/core/lib/src/
├─ either.dart       # Wrapper Either<L, R>
├─ failure.dart      # Base error class
├─ usecase.dart      # Abstract UseCase<Input, Output>
├─ di.dart           # Global service locator (GetIt)
├─ logger.dart       # Simple logger for debug
🧩 Key Features
✅ Clean architecture (Domain / Data / Application / UI).
✅ State management bằng BLoC.
✅ Local storage Hive.
✅ Pagination "Load more".
✅ Node.js REST API (Express + Zod).
✅ Dễ mở rộng, rõ ràng theo module.
```
---
## 🧪App Demo
<img width="357" height="801" alt="TodoApp" src="https://github.com/user-attachments/assets/13bd2806-cd31-486d-a1d8-8528cd547218" />
