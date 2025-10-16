import 'package:hive_flutter/hive_flutter.dart';
import '../../models/todo_model.dart';

/// =====================================
/// Hive Adapters/Bootstrap cho local DB
/// =====================================
/// - Khởi tạo Hive cho Flutter.
/// - Đăng ký các Adapter một lần.
/// - Được gọi sớm trong DI (xem registerTodosDataModule).
class HiveAdapters {
  static Future<void> initAndRegister() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TodoModelAdapter());
    }
  }
}
