import 'package:equatable/equatable.dart';

/// Các sự kiện mà UI gửi xuống BLoC.
/// Chia nhỏ theo hành vi để dễ test và maintain.
abstract class TodosEvent extends Equatable {
  const TodosEvent();
  @override
  List<Object?> get props => [];
}

/// Tải trang đầu tiên (offset = 0).
class TodosInitialLoadRequested extends TodosEvent {
  final int limit; // kích thước trang
  const TodosInitialLoadRequested({this.limit = 5});
  @override
  List<Object?> get props => [limit];
}

/// Tải tiếp trang sau (offset tăng dần).
class TodosLoadMoreRequested extends TodosEvent {
  final int limit;
  const TodosLoadMoreRequested({this.limit = 5});
  @override
  List<Object?> get props => [limit];
}

/// Thêm todo mới với title thô từ UI (sẽ validate ở BLoC bằng TitleVO).
class TodosAddRequested extends TodosEvent {
  final String rawTitle;
  const TodosAddRequested(this.rawTitle);
  @override
  List<Object?> get props => [rawTitle];
}

/// Cập nhật title cho một todo có sẵn.
class TodosUpdateRequested extends TodosEvent {
  final String id;
  final String newRawTitle;
  const TodosUpdateRequested({required this.id, required this.newRawTitle});
  @override
  List<Object?> get props => [id, newRawTitle];
}

/// Đổi trạng thái hoàn thành.
class TodosToggleRequested extends TodosEvent {
  final String id;
  const TodosToggleRequested(this.id);
  @override
  List<Object?> get props => [id];
}

/// Xóa một todo.
class TodosDeleteRequested extends TodosEvent {
  final String id;
  const TodosDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

/// Refresh cứng: đưa offset về 0 và load lại.
class TodosRefreshRequested extends TodosEvent {
  final int limit;
  const TodosRefreshRequested({this.limit = 5});
  @override
  List<Object?> get props => [limit];
}
