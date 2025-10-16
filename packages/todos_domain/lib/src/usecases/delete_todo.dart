import 'package:core/core.dart';
import '../repositories/todos_repository.dart';

/// ===================
/// UseCase: DeleteTodo
/// ===================
/// - Xóa một Todo theo id.
class DeleteTodo extends UseCase<void, DeleteTodoParams> {
  final TodosRepository repo;
  const DeleteTodo(this.repo);

  @override
  Future<Either<Failure, void>> call(DeleteTodoParams params) async {
    try {
      await repo.deleteTodo(params.id);
      return const Right(null);
    } catch (e, st) {
      return Left(AppFailure('Xóa Todo thất bại', cause: e, stack: st));
    }
  }
}

class DeleteTodoParams {
  final String id;
  const DeleteTodoParams(this.id);
}
