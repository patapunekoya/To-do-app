import 'package:core/core.dart';
import '../repositories/todos_repository.dart';

/// ===========================
/// UseCase: ToggleComplete
/// ===========================
/// - Đảo trạng thái hoàn thành của Todo theo id.
/// - Giữ logic nghiệp vụ ở UseCase giúp UI gọn và testable.
class ToggleComplete extends UseCase<void, ToggleCompleteParams> {
  final TodosRepository repo;
  const ToggleComplete(this.repo);

  @override
  Future<Either<Failure, void>> call(ToggleCompleteParams params) async {
    try {
      await repo.toggleComplete(params.id);
      return const Right(null);
    } catch (e, st) {
      return Left(AppFailure('Đổi trạng thái Todo thất bại', cause: e, stack: st));
    }
  }
}

class ToggleCompleteParams {
  final String id;
  const ToggleCompleteParams(this.id);
}
