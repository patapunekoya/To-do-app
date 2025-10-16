import 'package:get_it/get_it.dart';
import 'logger.dart';

/// Service Locator dùng chung toàn app.
/// Các feature module sẽ đăng ký dependency thông qua sl.
final sl = GetIt.instance;

/// Danh sách initializer để module/feature có thể append.
/// Ví dụ: ở todos_data có hàm `registerTodosData()` thêm vào đây.
final List<Future<void> Function()> _initializers = [];

/// Đăng ký một initializer (mỗi module gọi một lần).
void registerModuleInitializer(Future<void> Function() initializer) {
  _initializers.add(initializer);
}

/// Đăng ký các service lõi (logger, configs...) và chạy toàn bộ module initializers.
/// Gọi hàm này rất sớm trong `main()` trước `runApp`.
Future<void> configureCoreDependencies({
  bool enableLogging = true,
  LogLevel minLevel = LogLevel.debug,
}) async {
  // Global logger
  if (!sl.isRegistered<Logger>()) {
    sl.registerLazySingleton<Logger>(
      () => Logger(tag: 'todo-mini', enabled: enableLogging, minLevel: minLevel),
    );
  }

  // Chạy lần lượt các initializer mà feature đã push vào.
  for (final init in _initializers) {
    await init();
  }
}
