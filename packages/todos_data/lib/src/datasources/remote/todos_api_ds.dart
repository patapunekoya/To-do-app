import '../../models/todo_model.dart';

/// ===============================================
/// Remote Data Source (placeholder cho Node API)
/// ===============================================
/// - Định nghĩa interface để sau này dễ plug backend vào.
/// - Hiện tại để trống (offline-first); khi có API thì implement.
abstract class TodosRemoteDataSource {
  Future<List<TodoModel>> fetchTodos({required int cursor, required int limit});
  Future<void> createTodo(TodoModel model);
  Future<void> updateTodo(TodoModel model);
  Future<void> deleteTodo(String id);
  Future<void> toggleTodo(String id);
}

/// Bản triển khai giả lập/placeholder (chưa dùng)
class TodosRemoteDataSourceStub implements TodosRemoteDataSource {
  @override
  Future<void> createTodo(TodoModel model) =>
      Future.error(UnimplementedError('Remote API not wired yet'));

  @override
  Future<void> deleteTodo(String id) =>
      Future.error(UnimplementedError('Remote API not wired yet'));

  @override
  Future<List<TodoModel>> fetchTodos({required int cursor, required int limit}) =>
      Future.error(UnimplementedError('Remote API not wired yet'));

  @override
  Future<void> toggleTodo(String id) =>
      Future.error(UnimplementedError('Remote API not wired yet'));

  @override
  Future<void> updateTodo(TodoModel model) =>
      Future.error(UnimplementedError('Remote API not wired yet'));
}
