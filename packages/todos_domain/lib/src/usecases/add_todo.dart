import 'package:core/core.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

/// ====================
/// UseCase: AddTodo
/// ====================
/// - Dùng để thêm 1 Todo mới.
/// - Quy ước UseCase: nhận Params và trả Either<Failure, Output>.
/// - Ở đây Output là void (thành công/không), Failure để bubble lên UI.
class AddTodo extends UseCase<void, AddTodoParams> {
  final TodosRepository repo;
  const AddTodo(this.repo);

  @override
  Future<Either<Failure, void>> call(AddTodoParams params) async {
    try {
      await repo.addTodo(params.todo);
      return const Right(null);
    } catch (e, st) {
      return Left(AppFailure('Thêm Todo thất bại', cause: e, stack: st));
    }
  }
}

/// Tham số vào cho UseCase.
/// - Tách params để dễ mở rộng về sau (ví dụ thêm source, metadata...).
class AddTodoParams {
  final Todo todo;
  const AddTodoParams(this.todo);
}
