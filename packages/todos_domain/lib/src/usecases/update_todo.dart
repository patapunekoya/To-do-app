import 'package:core/core.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

/// =======================
/// UseCase: UpdateTodo
/// =======================
/// - Cập nhật một Todo (thường là title).
class UpdateTodo extends UseCase<void, UpdateTodoParams> {
  final TodosRepository repo;
  const UpdateTodo(this.repo);

  @override
  Future<Either<Failure, void>> call(UpdateTodoParams params) async {
    try {
      await repo.updateTodo(params.todo);
      return const Right(null);
    } catch (e, st) {
      return Left(AppFailure('Cập nhật Todo thất bại', cause: e, stack: st));
    }
  }
}

class UpdateTodoParams {
  final Todo todo;
  const UpdateTodoParams(this.todo);
}
