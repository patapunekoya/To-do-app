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
│  └─ flutter_todo/                 # App Flutter (UI/Router/DI/Theme)
├─ packages/
│  ├─ core/                         # Cross-cutting: error, usecase base, utils
│  │  ├─ lib/
│  │  │  ├─ src/
│  │  │  │  ├─ either.dart
│  │  │  │  ├─ failure.dart
│  │  │  │  ├─ usecase.dart        # Base UseCase<Input, Output>
│  │  │  │  ├─ di.dart             # get_it registration helpers
│  │  │  │  └─ logger.dart
│  │  │  └─ core.dart
│  ├─ todos_domain/                 # DDD: Domain layer (pure Dart)
│  │  ├─ lib/
│  │  │  ├─ src/
│  │  │  │  ├─ entities/
│  │  │  │  │  └─ todo.dart
│  │  │  │  ├─ value_objects/
│  │  │  │  │  └─ title_vo.dart
│  │  │  │  ├─ repositories/
│  │  │  │  │  └─ todos_repository.dart   # abstract interface
│  │  │  │  └─ usecases/
│  │  │  │     ├─ add_todo.dart
│  │  │  │     ├─ update_todo.dart
│  │  │  │     ├─ toggle_complete.dart
│  │  │  │     ├─ delete_todo.dart
│  │  │  │     └─ get_todos_paginated.dart  # phục vụ “load more”
│  │  │  └─ todos_domain.dart
│  ├─ todos_data/                   # DDD: Infrastructure (data)
│  │  ├─ lib/
│  │  │  ├─ src/
│  │  │  │  ├─ datasources/
│  │  │  │  │  ├─ local/
│  │  │  │  │  │  ├─ hive_adapters.dart
│  │  │  │  │  │  └─ todos_local_ds.dart
│  │  │  │  │  └─ remote/
│  │  │  │  │     └─ todos_api_ds.dart      # để sau sync Node
│  │  │  │  ├─ models/
│  │  │  │  │  └─ todo_model.dart
│  │  │  │  └─ repositories/
│  │  │  │     └─ todos_repository_impl.dart
│  │  │  └─ todos_data.dart
│  └─ todos_application/            # DDD: Application (BLoC, coordinators)
│     ├─ lib/
│     │  ├─ src/
│     │  │  ├─ blocs/
│     │  │  │  └─ todos/
│     │  │  │     ├─ todos_bloc.dart
│     │  │  │     ├─ todos_event.dart
│     │  │  │     └─ todos_state.dart
│     │  │  └─ mappers/             # map Entity <-> UI models nếu cần
│     │  └─ todos_application.dart
└─ backend/node_todo_api/
│  ├─ src/
│  │  ├─ app.ts
│  │  ├─ server.ts
│  │  ├─ routes/
│  │  │  └─ todos.routes.ts
│  │  ├─ controllers/
│  │  │  └─ todos.controller.ts
│  │  ├─ services/
│  │  │  └─ todos.service.ts
│  │  ├─ repositories/
│  │  │  └─ todos.repo.ts          # có thể dùng SQLite/Prisma/Mongo tùy gu
│  │  └─ schemas/
│  │     └─ todo.schema.ts         # validate với zod
│  ├─ package.json
│  └─ tsconfig.json


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
