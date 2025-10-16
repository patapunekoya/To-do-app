import 'package:equatable/equatable.dart';
import 'package:todos_domain/todos_domain.dart';

/// Trạng thái tổng quát để UI render.
enum TodosStatus { idle, loading, success, failure }

class TodosState extends Equatable {
  final TodosStatus status;
  final List<Todo> items;
  final int offset;     // vị trí hiện tại đã load
  final int limit;      // kích thước trang hiện tại
  final bool hasMore;   // còn dữ liệu để load tiếp không
  final String? error;  // thông báo lỗi (nếu có)

  const TodosState({
    this.status = TodosStatus.idle,
    this.items = const [],
    this.offset = 0,
    this.limit = 5,
    this.hasMore = true,
    this.error,
  });

  TodosState copyWith({
    TodosStatus? status,
    List<Todo>? items,
    int? offset,
    int? limit,
    bool? hasMore,
    String? error,
  }) {
    return TodosState(
      status: status ?? this.status,
      items: items ?? this.items,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, offset, limit, hasMore, error];
}
