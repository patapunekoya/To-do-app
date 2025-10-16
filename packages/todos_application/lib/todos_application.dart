/// Barrel + đăng ký DI cho Application layer.
/// App sẽ gọi:
///   registerModuleInitializer(registerTodosApplicationModule);
/// rồi:
///   await configureCoreDependencies();
library todos_application;

import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:todos_domain/todos_domain.dart';

import 'src/blocs/todos/todos_bloc.dart';
import 'src/blocs/todos/todos_event.dart';
import 'src/blocs/todos/todos_state.dart';

export 'src/blocs/todos/todos_bloc.dart';
export 'src/blocs/todos/todos_event.dart';
export 'src/blocs/todos/todos_state.dart';

/// Đăng ký các UseCase dựa trên TodosRepository (đã bind ở data layer)
/// và đăng ký factory tạo TodosBloc.
/// Bloc thường nên là factory để mỗi màn hình/Scope có thể có instance riêng.
Future<void> registerTodosApplicationModule() async {
  final sl = GetIt.instance;

  // 1) Đảm bảo Repository đã có (được register bởi todos_data)
  assert(sl.isRegistered<TodosRepository>(),
      'TodosRepository chưa được đăng ký. Hãy đảm bảo registerTodosDataModule() chạy trước.');

  // 2) UseCases
  if (!sl.isRegistered<GetTodosPaginated>()) {
    sl.registerLazySingleton<GetTodosPaginated>(() => GetTodosPaginated(sl<TodosRepository>()));
  }
  if (!sl.isRegistered<AddTodo>()) {
    sl.registerLazySingleton<AddTodo>(() => AddTodo(sl<TodosRepository>()));
  }
  if (!sl.isRegistered<UpdateTodo>()) {
    sl.registerLazySingleton<UpdateTodo>(() => UpdateTodo(sl<TodosRepository>()));
  }
  if (!sl.isRegistered<ToggleComplete>()) {
    sl.registerLazySingleton<ToggleComplete>(() => ToggleComplete(sl<TodosRepository>()));
  }
  if (!sl.isRegistered<DeleteTodo>()) {
    sl.registerLazySingleton<DeleteTodo>(() => DeleteTodo(sl<TodosRepository>()));
  }

  // 3) Bloc factory
  if (!sl.isRegistered<TodosBloc>()) {
    sl.registerFactory<TodosBloc>(() => TodosBloc(
          getTodosPaginated: sl<GetTodosPaginated>(),
          addTodo: sl<AddTodo>(),
          updateTodo: sl<UpdateTodo>(),
          toggleComplete: sl<ToggleComplete>(),
          deleteTodo: sl<DeleteTodo>(),
          logger: sl<Logger>(),
        ));
  }
}
