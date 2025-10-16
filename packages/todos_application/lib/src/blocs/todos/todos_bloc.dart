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
