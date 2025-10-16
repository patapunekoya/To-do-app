import 'either.dart';
import 'failure.dart';

/// Chuẩn hóa signature của UseCase để dễ DI và test.
/// Thực thi trả về Either<Failure, T>.
abstract class UseCase<T, P> {
  const UseCase();
  Future<Either<Failure, T>> call(P params);
}

/// Không có tham số.
class NoParams {
  const NoParams();
}

/// UseCase cho stream nếu cần realtime (không bắt buộc dùng).
abstract class StreamUseCase<T, P> {
  const StreamUseCase();
  Stream<Either<Failure, T>> call(P params);
}
