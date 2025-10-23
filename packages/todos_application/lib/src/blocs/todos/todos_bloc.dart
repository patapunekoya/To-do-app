import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:todos_domain/todos_domain.dart';

import 'todos_event.dart';
import 'todos_state.dart';

/// BLoC điều phối các UseCase:
/// - GetTodosPaginated để load/ load more
/// - AddTodo, UpdateTodo, ToggleComplete, DeleteTodo
/// Chứa logic nhẹ: validate TitleVO, quản lý offset/hasMore, hợp nhất danh sách.
class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final GetTodosPaginated getTodosPaginated;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final ToggleComplete toggleComplete;
  final DeleteTodo deleteTodo;
  final Logger logger;

  TodosBloc({
    required this.getTodosPaginated,
    required this.addTodo,
    required this.updateTodo,
    required this.toggleComplete,
    required this.deleteTodo,
    required this.logger,
  }) : super(const TodosState()) {
    on<TodosInitialLoadRequested>(_onInitialLoad);
    on<TodosLoadMoreRequested>(_onLoadMore);
    on<TodosAddRequested>(_onAdd);
    on<TodosUpdateRequested>(_onUpdate);
    on<TodosToggleRequested>(_onToggle);
    on<TodosDeleteRequested>(_onDelete);
    on<TodosRefreshRequested>(_onRefresh);
  }

  // Tạo id đơn giản, đủ duy nhất trong phạm vi local.
  String _genId() => DateTime.now().microsecondsSinceEpoch.toString() +
      '-' +
      Random().nextInt(1 << 32).toString();

// Xử lý: tải trang đầu tiên của danh sách Todo.
// Kết quả:

// Nếu thành công → emit state có items, offset, hasMore=true/false.

// Nếu lỗi → emit state status=failure, có thông báo lỗi.
  Future<void> _onInitialLoad(
    TodosInitialLoadRequested event,
    Emitter<TodosState> emit,
  ) async {
    emit(state.copyWith(status: TodosStatus.loading, error: null, offset: 0, limit: event.limit));

    final res = await getTodosPaginated(
      GetTodosPaginatedParams(offset: 0, limit: event.limit),
    );

    res.fold(
      (failure) {
        logger.e('Initial load failed', failure, failure.stack);
        emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      },
      (items) {
        emit(state.copyWith(
          status: TodosStatus.success,
          items: items,
          offset: items.length,
          limit: event.limit,
          hasMore: items.length == event.limit,
          error: null,
        ));
      },
    );
  }

// Xử lý: tải trang kế tiếp (phân trang / “xem thêm”).
// Kết quả:

// Thành công → nối thêm dữ liệu vào state.items.

// Thất bại → báo lỗi, không đổi danh sách hiện có.
  Future<void> _onLoadMore(
    TodosLoadMoreRequested event,
    Emitter<TodosState> emit,
  ) async {
    if (!state.hasMore || state.status == TodosStatus.loading) return;

    emit(state.copyWith(status: TodosStatus.loading, limit: event.limit));
    final res = await getTodosPaginated(
      GetTodosPaginatedParams(offset: state.offset, limit: event.limit),
    );

    res.fold(
      (failure) {
        logger.w('Load more failed: ${failure.message}', failure, failure.stack);
        emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      },
      (more) {
        final combined = [...state.items, ...more];
        final newOffset = state.offset + more.length;
        emit(state.copyWith(
          status: TodosStatus.success,
          items: combined,
          offset: newOffset,
          hasMore: more.length == event.limit,
          error: null,
        ));
      },
    );
  }

// Xử lý: thêm một Todo mới.

// Validate TitleVO.create() trước khi tạo.

// Sinh id, tạo Todo, gọi AddTodo.
// Kết quả:

// Thành công → chèn Todo mới lên đầu danh sách, offset +1.

// Thất bại → báo lỗi validation hoặc lỗi thêm.
  Future<void> _onAdd(
    TodosAddRequested event,
    Emitter<TodosState> emit,
  ) async {
    // Validate title bằng VO ở domain
    final titleOr = TitleVO.create(event.rawTitle);
    if (titleOr.isLeft) {
      final failure = titleOr.leftOrNull!;
      emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      return;
    }
    final titleVO = titleOr.rightOrNull!;

    final todo = Todo(
      id: _genId(),
      title: titleVO.value,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final res = await addTodo(AddTodoParams(todo));
    res.fold(
      (failure) {
        logger.e('Add todo failed', failure, failure.stack);
        emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      },
      (_) {
        // Thêm vào đầu list để thấy ngay, vì ta sort createdAt desc.
        final updated = [todo, ...state.items];
        emit(state.copyWith(
          status: TodosStatus.success,
          items: updated,
          offset: state.offset + 1,
          error: null,
        ));
      },
    );
  }

// Xử lý: sửa tiêu đề Todo.

// Validate title mới, tìm Todo theo id, cập nhật bằng copyWith().
// Kết quả:

// Thành công → cập nhật lại danh sách (thay thế phần tử).

// Thất bại → emit lỗi validation hoặc lỗi cập nhật.
  Future<void> _onUpdate(
    TodosUpdateRequested event,
    Emitter<TodosState> emit,
  ) async {
    final titleOr = TitleVO.create(event.newRawTitle);
    if (titleOr.isLeft) {
      final failure = titleOr.leftOrNull!;
      emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      return;
    }
    final newTitle = titleOr.rightOrNull!.value;

    final idx = state.items.indexWhere((e) => e.id == event.id);
    if (idx < 0) return;

    final updatedTodo = state.items[idx].copyWith(title: newTitle);
    final res = await updateTodo(UpdateTodoParams(updatedTodo));

    res.fold(
      (failure) {
        logger.w('Update todo failed: ${failure.message}', failure, failure.stack);
        emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      },
      (_) {
        final newList = [...state.items]..[idx] = updatedTodo;
        emit(state.copyWith(status: TodosStatus.success, items: newList, error: null));
      },
    );
  }

// Xử lý: đổi trạng thái hoàn thành (isCompleted).
// Kết quả:

// Thành công → đảo trạng thái trong danh sách (true ↔ false).

// Thất bại → không đổi, báo lỗi.
  Future<void> _onToggle(
    TodosToggleRequested event,
    Emitter<TodosState> emit,
  ) async {
    final idx = state.items.indexWhere((e) => e.id == event.id);
    if (idx < 0) return;

    final res = await toggleComplete(ToggleCompleteParams(event.id));
    res.fold(
      (failure) {
        logger.w('Toggle todo failed: ${failure.message}', failure, failure.stack);
        emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      },
      (_) {
        final old = state.items[idx];
        final toggled = old.copyWith(isCompleted: !old.isCompleted);
        final newList = [...state.items]..[idx] = toggled;
        emit(state.copyWith(status: TodosStatus.success, items: newList, error: null));
      },
    );
  }

// Xử lý: xóa Todo theo id.
// Kết quả:

// Thành công → loại bỏ Todo khỏi danh sách, offset -1.

// Thất bại → emit lỗi.
  Future<void> _onDelete(
    TodosDeleteRequested event,
    Emitter<TodosState> emit,
  ) async {
    final res = await deleteTodo(DeleteTodoParams(event.id));
    res.fold(
      (failure) {
        logger.w('Delete todo failed: ${failure.message}', failure, failure.stack);
        emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      },
      (_) {
        final newList = state.items.where((e) => e.id != event.id).toList();
        emit(state.copyWith(
          status: TodosStatus.success,
          items: newList,
          offset: state.offset > 0 ? state.offset - 1 : 0,
          error: null,
        ));
      },
    );
  }

// Xử lý: tải lại toàn bộ danh sách từ đầu.
// Kết quả:

// Thành công → danh sách mới, offset và hasMore reset.

// Thất bại → báo lỗi, không đổi dữ liệu cũ.
  Future<void> _onRefresh(
    TodosRefreshRequested event,
    Emitter<TodosState> emit,
  ) async {
    emit(state.copyWith(status: TodosStatus.loading, offset: 0, limit: event.limit, error: null));
    final res = await getTodosPaginated(
      GetTodosPaginatedParams(offset: 0, limit: event.limit),
    );

    res.fold(
      (failure) {
        logger.e('Refresh failed', failure, failure.stack);
        emit(state.copyWith(status: TodosStatus.failure, error: failure.message));
      },
      (items) {
        emit(state.copyWith(
          status: TodosStatus.success,
          items: items,
          offset: items.length,
          hasMore: items.length == event.limit,
          error: null,
        ));
      },
    );
  }
}
