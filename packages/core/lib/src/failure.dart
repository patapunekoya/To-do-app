/// Base Failure to bubble domain/infrastructure errors up to application/UI.
abstract class Failure {
  final String message;
  final String? code;       // optional machine-readable code
  final Object? cause;      // original exception
  final StackTrace? stack;  // optional stack for logging

  const Failure(this.message, {this.code, this.cause, this.stack});

  @override
  String toString() => 'Failure(message: $message, code: $code, cause: $cause)';
}

/// Common families of failures (expand as needed).
class AppFailure extends Failure {
  const AppFailure(String message, {String? code, Object? cause, StackTrace? stack})
      : super(message, code: code, cause: cause, stack: stack);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code, Object? cause, StackTrace? stack})
      : super(message, code: code, cause: cause, stack: stack);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code, Object? cause, StackTrace? stack})
      : super(message, code: code, cause: cause, stack: stack);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code, Object? cause, StackTrace? stack})
      : super(message, code: code, cause: cause, stack: stack);
}
