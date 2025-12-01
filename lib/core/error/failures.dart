/// Base failure class for error handling
abstract class AppFailure {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const AppFailure(this.message, [this.error, this.stackTrace]);

  @override
  String toString() => 'AppFailure: $message';
}

/// Server-related failures
class ServerFailure extends AppFailure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    this.statusCode,
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error, stackTrace);
}

/// Network-related failures
class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'No internet connection. Please check your network.',
    super.error,
    super.stackTrace,
  ]);
}

/// Cache-related failures
class CacheFailure extends AppFailure {
  const CacheFailure([
    super.message = 'Failed to access cached data.',
    super.error,
    super.stackTrace,
  ]);
}

/// Authentication failures
class AuthFailure extends AppFailure {
  const AuthFailure([
    super.message = 'Authentication failed. Please login again.',
    super.error,
    super.stackTrace,
  ]);
}

/// Validation failures
class ValidationFailure extends AppFailure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(
    String message, {
    this.fieldErrors,
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error, stackTrace);
}

/// File operation failures
class FileFailure extends AppFailure {
  const FileFailure([
    super.message = 'File operation failed.',
    super.error,
    super.stackTrace,
  ]);
}

/// Download failures
class DownloadFailure extends AppFailure {
  final double? progress;

  const DownloadFailure(
    String message, {
    this.progress,
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error, stackTrace);
}

/// AI/API failures
class AIFailure extends AppFailure {
  const AIFailure([
    super.message = 'AI service unavailable. Please try again.',
    super.error,
    super.stackTrace,
  ]);
}

/// Unknown failures
class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'An unexpected error occurred.',
    super.error,
    super.stackTrace,
  ]);
}
