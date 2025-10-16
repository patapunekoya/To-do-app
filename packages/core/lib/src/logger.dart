import 'dart:developer' as dev;

/// Mức log tối giản.
enum LogLevel { debug, info, warn, error }

/// Logger tối giản, không phụ thuộc package ngoài.
/// Có thể nâng cấp sau này (sentry, crashlytics...) mà không đổi nơi dùng.
class Logger {
  final String tag;
  final bool enabled;
  final LogLevel minLevel;

  const Logger({
    required this.tag,
    this.enabled = true,
    this.minLevel = LogLevel.debug,
  });

  void _log(LogLevel level, String message, [Object? error, StackTrace? stack]) {
    if (!enabled) return;
    if (level.index < minLevel.index) return;
    dev.log(
      message,
      name: tag,
      error: error,
      stackTrace: stack,
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warn => 900,
        LogLevel.error => 1000,
      },
    );
  }

  void d(String msg) => _log(LogLevel.debug, msg);
  void i(String msg) => _log(LogLevel.info, msg);
  void w(String msg, [Object? err, StackTrace? st]) => _log(LogLevel.warn, msg, err, st);
  void e(String msg, [Object? err, StackTrace? st]) => _log(LogLevel.error, msg, err, st);
}
