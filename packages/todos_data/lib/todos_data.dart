/// Barrel file + đăng ký DI cho module todos_data.
/// App layer sẽ import file này, sau đó:
///   registerModuleInitializer(registerTodosDataModule);
/// rồi gọi:
///   await configureCoreDependencies();
library todos_data;


import 'package:get_it/get_it.dart';
import 'package:todos_domain/todos_domain.dart';

import 'src/datasources/local/hive_adapters.dart';
import 'src/datasources/local/todos_local_ds.dart';
import 'src/repositories/todos_repository_impl.dart';

export 'src/datasources/local/todos_local_ds.dart';
export 'src/models/todo_model.dart';
export 'src/repositories/todos_repository_impl.dart';

/// Hàm đăng ký toàn bộ phụ thuộc của data layer vào GetIt.
/// - Khởi tạo Hive + mở box
/// - Bind LocalDataSource
/// - Bind TodosRepository -> TodosRepositoryImpl
Future<void> registerTodosDataModule() async {
  // 1) Init/đăng ký adapter Hive
  await HiveAdapters.initAndRegister();

  // 2) Lấy service locator dùng chung từ core
  final sl = GetIt.instance;

  // 3) Local data source
  if (!sl.isRegistered<TodosLocalDataSource>()) {
    sl.registerLazySingleton<TodosLocalDataSource>(() => TodosLocalDataSourceImpl());
    // mở box ngay để đảm bảo sẵn sàng
    await sl<TodosLocalDataSource>().init();
  }

  // 4) Repository (Domain Abstraction -> Impl)
  if (!sl.isRegistered<TodosRepository>()) {
    sl.registerLazySingleton<TodosRepository>(() => TodosRepositoryImpl(sl()));
  }
}
