import 'package:hive/hive.dart';
import '../../models/todo_model.dart';

/// =======================================
/// Local Data Source (Hive implementation)
/// =======================================
/// - Chỉ làm việc với TodoModel (data layer), không dính Domain Entity.
/// - Cung cấp API CRUD + phân trang cơ bản dùng offset/limit.
abstract class TodosLocalDataSource {
  Future<void> init();
  Future<List<TodoModel>> getPaginated({required int offset, required int limit});
  Future<void> add(TodoModel model);
  Future<void> update(TodoModel model);
  Future<void> delete(String id);
  Future<void> toggle(String id);
  Future<TodoModel?> getById(String id);
}

class TodosLocalDataSourceImpl implements TodosLocalDataSource {
  static const _boxName = 'todos_box';
  late Box<TodoModel> _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<TodoModel>(_boxName);
  }

  @override
  Future<List<TodoModel>> getPaginated({required int offset, required int limit}) async {
    // Copy ra list để sort theo createdAt giảm dần rồi cắt trang
    final items = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset >= items.length) return const [];
    final end = (offset + limit) > items.length ? items.length : (offset + limit);
    return items.sublist(offset, end);
  }

  @override
  Future<void> add(TodoModel model) async {
    // Dùng id làm key để tránh trùng và update nhanh
    await _box.put(model.id, model);
  }

  @override
  Future<void> update(TodoModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> toggle(String id) async {
    final cur = _box.get(id);
    if (cur != null) {
      await _box.put(id, cur.copyWith(isCompleted: !cur.isCompleted));
    }
  }

  @override
  Future<TodoModel?> getById(String id) async => _box.get(id);
}
