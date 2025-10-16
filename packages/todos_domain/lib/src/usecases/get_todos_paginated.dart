import 'package:core/core.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

/// ================================
/// UseCase: GetTodosPaginated
/// ================================
/// - Trả về danh sách Todo có phân trang theo offset/limit.
/// - Phục vụ cơ chế "load more" ở UI.
/// - Repo đảm bảo thứ tự (thường sort theo createdAt giảm dần).
class GetTodosPaginated extends UseCase<List<Todo>, GetTodosPaginatedParams> {
  final TodosRepository repo;
  const GetTodosPaginated(this.repo);

  @override
  Future<Either<Failure, List<Todo>>> call(GetTodosPaginatedParams params) async {
    try {
      final items = await repo.getTodosPaginated(params.offset, params.limit);
      return Right(items);
    } catch (e, st) {
      return Left(AppFailure('Tải danh sách Todo thất bại', cause: e, stack: st));
    }
  }
}

class GetTodosPaginatedParams {
  final int offset; // vị trí bắt đầu
  final int limit;  // số lượng mỗi trang
  const GetTodosPaginatedParams({required this.offset, required this.limit});
}
