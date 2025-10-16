import 'package:hive/hive.dart';
import 'package:todos_domain/todos_domain.dart';

part 'todo_model.g.dart';

/// ===============================
/// Data Model: TodoModel (Hive)
/// ===============================
/// - Đại diện bản ghi lưu trong local DB (Hive).
/// - Có thể khác Domain Entity nếu cần tối ưu storage.
/// - Chứa mapper toEntity/fromEntity để tách Data ↔ Domain.
@HiveType(typeId: 1)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final DateTime createdAt;

  // BỎ const ở đây
  TodoModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  TodoModel copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return TodoModel(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  Todo toEntity() => Todo(
        id: id,
        title: title,
        isCompleted: isCompleted,
        createdAt: createdAt,
      );

  static TodoModel fromEntity(Todo e) => TodoModel(
        id: e.id,
        title: e.title,
        isCompleted: e.isCompleted,
        createdAt: e.createdAt,
      );
}