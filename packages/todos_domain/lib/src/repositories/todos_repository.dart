import '../entities/todo.dart';

/// =======================================
/// Repository (Domain Interface - Abstraction)
/// =======================================
/// - Domain chỉ định nghĩa "hợp đồng" (interface) cần thiết cho nghiệp vụ.
/// - Data/Infrastructure layer sẽ implement chi tiết (Hive/Isar/HTTP...).
/// - Application/UseCase chỉ làm việc với Abstraction này để tách phụ thuộc.
///
/// Lợi ích:
/// - Dễ test (mock Repo).
/// - Dễ thay đổi hạ tầng lưu trữ mà không ảnh hưởng domain/application.
abstract class TodosRepository {
  /// Lấy danh sách Todo có phân trang (offset/limit) để phục vụ "load more".
  Future<List<Todo>> getTodosPaginated(int offset, int limit);

  /// Thêm 1 Todo.
  Future<void> addTodo(Todo todo);

  /// Cập nhật 1 Todo (chủ yếu là title).
  Future<void> updateTodo(Todo todo);

  /// Xóa 1 Todo theo id.
  Future<void> deleteTodo(String id);

  /// Đổi trạng thái hoàn thành theo id.
  Future<void> toggleComplete(String id);
}
