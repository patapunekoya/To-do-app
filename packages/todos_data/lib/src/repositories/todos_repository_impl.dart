import 'package:todos_domain/todos_domain.dart';
import '../datasources/local/todos_local_ds.dart';
import '../models/todo_model.dart';

/// ============================================
/// Repository Impl (Data Layer implements Domain)
/// ============================================
/// - Thực thi TodosRepository (ở domain) dựa trên LocalDataSource.
/// - Nhiệm vụ: map giữa Entity (Domain) và Model (Data).
class TodosRepositoryImpl implements TodosRepository {
  final TodosLocalDataSource local;
  // Có thể thêm remote sau này: final TodosRemoteDataSource remote;

  TodosRepositoryImpl(this.local);

  @override
  Future<List<Todo>> getTodosPaginated(int offset, int limit) async {
    final list = await local.getPaginated(offset: offset, limit: limit);
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    await local.add(TodoModel.fromEntity(todo));
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await local.update(TodoModel.fromEntity(todo));
  }

  @override
  Future<void> deleteTodo(String id) => local.delete(id);

  @override
  Future<void> toggleComplete(String id) => local.toggle(id);
}
